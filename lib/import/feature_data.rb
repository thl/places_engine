require 'pp' # pp == prettyputs or prettyprint. Use like puts: pp object.inspect
require 'rubygems'
require 'hpricot'
require 'net/https'
#gem 'libxml-ruby'
#require 'xml/libxml_so'

class FeatureData
  
  
  def initialize(source)
    ## @source is either a file or 
    ## a url of the form "https://#{user}:#{pass}@subversion.lib.virginia.edu/repos/thdl/trunk/collections/cultgeo/gazetteer2/"
    @source=source
    
    @current_perspective = Perspective.find_or_create_by_name(
      :name=>'Contemporary Administrative Hierarchy',
      :code=>'cah'
    )
    
    #@current_perspective = "Contemporary Administrative Hierarchy"
    #@current_perspective_code = 'cah'
    
    @current_xml_document = nil
  end
  
  ## if @source starts with "http", you can assume it is a url
  def url?
    @source[0..3]=='http'
  end
  
  ## and if it is not a url, you can assume you're reading from disk
  def disk?
    ! url?
  end
  
  #
  # Returns an Hpricot instance
  # based on a document found at the given url or file path
  # and cache xml document in @current_xml_document
  def create_doc(path)
    doc = File.read(path)
    @current_xml_document = doc
    Hpricot.XML(doc)
  end

  # ##################################################################### #
  # Returns array of paths to create Hpricot docs from
  # Given a directory containing lots of xml files, 
  # create an array of the path to each xml file. 
  # Then, for each of these xml files, try to parse them with hpricot
  # If a file parses successfully, add it to an array called docs
  # Return docs, which now contains hpricot objects for all of the features
  # we want to import 
  #
  def fetch_feature_docs
    docs=[]
    d = Dir[@source + "/*.xml"]
    #puts d.inspect
    
    d.entries.each do |file|
        docs << file
    end
    #puts docs.inspect
    docs
  end

  # ##################################################################### #
  #
  # Returns Vocabulary objects popuplated with Terms (non-saved)
  #
  def fetch_thesauri
    doc = create_doc('gaz-thesauri/administrativeThesaurus.xml')
    ## loop through each <term> element in the thesaurus
    vocabs=[]
    (doc/"thesaurus/root/term").each do |term|
      STDOUT << puts 
      STDOUT << term.inspect
      STDOUT << puts 
      
    end
    vocabs
  end
  
  # ##################################################################### #
  # create and save the FeatureRelation object(s) from this hpricot document
  # this will need to throw an error if the parent object doesn't exist yet
  def extract_feature_relations(hpricot_doc, feature)
    doc = hpricot_doc
    # Is there a frel section in this document?
    if(doc/'/feature/frel')
      fr_array = (doc/'/feature/frel')
      fr_array.each do |fr|
        feature_relation = FeatureRelation.new()
        target_pid = (fr/'extref')[0].attributes['href']
        target_feature = Feature.find_or_create_by_pid(target_pid)
        feature_relation.child_node_id = feature.id
        feature_relation.parent_node_id = target_feature.id
        target_role = fr.attributes['role']
        
        #puts '------------'
        #puts 'Target Role is :: ' + target_role
        #puts '------------'
        
        # "partof" and "contains" are the default (child_node_id and parent_node_id)
        if target_role != 'partof'
          feature_relation.role = target_role.underscore
          #type = FeatureRelationType.find_or_create_by_code(target_role)
          # Set (and save) the FeatureRelationType name
          #type.update_attribute(:name, target_role)
          #feature_relation.feature_relation_type_id = type.id
        end
        
        feature_relation.perspective = @current_perspective#Perspective.find_or_create_by_code(@current_perspective_code)
        raise "FeatureRelation not saved!" unless feature_relation.save
        
        set_timespan(fr, feature_relation)
        extract_citations(fr, feature_relation)
        
      end
    end
  end
  
  # ##################################################################### #
  # create, save, and return the Feature object from this hpricot document
  def extract_feature(doc)
    raise "extract_feature was passed an empty doc!" if doc.nil?
    pid = (doc/'/feature')[0].attributes['id']
    puts "extract_feature() -> pid = #{pid}"
    description = (doc/'/feature/fdesc').inner_html
    feature = Feature.find_or_create_by_pid(pid)
    
    #if(description)
    feature.description = description.strip
    #end
    
    raise "Feature not saved!" unless feature.save
    return feature
  end

  # ##################################################################### #
  # Given an hpricot snippet, determine the writing system. (This may not always be possible.)
  # To add another code, just put in in the array in the appropriate place. 

  def determine_writing_system(doc)
    
    writing_system_codes = {
      "latin" => ["pinyin", "wylie", "eng","romanized","wyl","pin","nep.no-diacritics"],
      "tibetan" => ["tib"],
      "chi_simplified" => ["chi.simplified"],
      "chi_traditional" => ["chi.traditional"],
      "nep_diacritics" => ["nep.diacritics"],
      "nepalese" => ["nep"]
    }
    
    writing_system_codes.keys.sort.each do |key|  # sort the keys so latin comes before tibetan, otherwise, tib-wylie always matches on tibetan instead of latin
      writing_system_codes[key].each do |k|
        # Match on scheme first, to weed out all the transliterations (e.g., wylie, pinyin, romanized)
        # Then try the type attribute, because some records use that instead
        # Then, if it still hasn't found a match, assume that the value in lang also describes
        # the writing system
        if(doc.attributes['scheme'] =~ /#{k}/)
          writing_system = WritingSystem.find_or_create_by_code(key)
          return writing_system.id 
        elsif(doc.attributes['type'] =~ /#{k}/)
            writing_system = WritingSystem.find_or_create_by_code(key)
            return writing_system.id
        elsif(doc.attributes['lang'] =~ /#{k}/)
          writing_system = WritingSystem.find_or_create_by_code(key)
          return writing_system.id
        end
      end
    end
    return nil # If it hasn't matched anything yet, return nil
  end

  # ##################################################################### #
  # Given an hpricot snippet and a citable object, extract the citations
  # from the hpricot, create them in the db, and attach them to the object
  def extract_citations(doc, object)
    authorities = (doc/'/authority')
    authorities.each do |authority|
      is = Document.find(authority.inner_text)
      cit = Citation.create(:info_source_id => is.id, :citable=> object)
    end
  
  end

  
  # ##################################################################### #
  # create and save the FeatureName objects
  def extract_feature_names(doc, feature)
    elements = (doc/'//fname')
    elements.each do |e|
      fn = FeatureName.new
      
      fn.feature_id = feature.id
      fn.name = extract_geogname(e)
      fn.language_id = attach_language_id(e)
      fn.is_public = true
      fn.writing_system_id = determine_writing_system(e)
      
      raise "FeatureName #{fn.inspect} not saved!" unless fn.save
      
      set_timespan(e, fn)
      
      extract_citations(e, fn)
      
      # Does this FeatureName contain a translation or transliteration?
      if(e/'transliteration')
        secondary_fnames = extract_secondary_feature_names(e, feature, fn)
      end
    end
  end
  
  
  # ##################################################################### #
  # Given a snippet of XML defining a feature name, extract the secondary feature names, 
  # create FeatureName objects for them to tie them to their parent FeatureName, and
  # call this method again recursively if they contain a transliteration of their own
  def extract_secondary_feature_names(doc, feature, primary_feature_name)
    transliterations = (doc/'/transliteration|/altspell') # only get the top level transliterations, not *their* transliterations
                                                          # altspells are also treated as a FeatureName in their own right... treat
                                                          # them just like a <transliteration> element
    transliterations.each do |transliteration|
      fn = FeatureName.new
      
      fn.feature_id = feature.id
      fn.name = extract_geogname(transliteration)
      fn.language_id = primary_feature_name.language_id # a transliteration has the same language as its parent 
      fn.writing_system_id = determine_writing_system(transliteration)
      
      raise "Secondary FeatureName not saved!" unless fn.save
      
      set_timespan(transliteration, fn)
      
      extract_citations(transliteration, fn)
      
      # now relate this fn to its parent feature_name
      fnr = FeatureNameRelation.new
      fnr.child_node_id = fn.id
      fnr.parent_node_id = primary_feature_name.id
      
      
      # Is it orthographic, and if so what's the system?
      if(transliteration.attributes['type'] == 'orthographic')
        fnr.is_orthographic = true
        fnr.orthographic_system_id = OrthographicSystem.find_or_create_by_code(transliteration.attributes['scheme']).id
      end
      
      # Is it phonetic, and if so, what's the system?
      if(transliteration.attributes['type'] == 'phonetic')
        fnr.is_phonetic = true
        fnr.phonetic_system_id = PhoneticSystem.find_or_create_by_code(transliteration.attributes['scheme']).id
      end
      
      # Is it an altspelling, and if so, what's the system? 
      if(transliteration.name == 'altspell')
        fnr.is_alt_spelling = true
        fnr.alt_spelling_system_id = AltSpellingSystem.find_or_create_by_code(transliteration.attributes['type']).id
      end
      
      # Is it a translation? 
      # There are no translations in the current data set, so I'm not writing this in
      
      raise "FeatureNameRelation not saved!" unless fnr.save
      
      set_timespan(transliteration, fnr)
      extract_citations(transliteration, fnr)
      
      # Does this FeatureName contain a translation or transliteration?
      if(transliteration/'transliteration')
        secondary_fnames = extract_secondary_feature_names(transliteration, feature, fn) # Call this method recursively if any of these transliterations have their own transliterations
      end
    end
  end

  # ##################################################################### #
  # In the interest of staying DRY, keep all setting of isCurrent in one place
  # This method accepts an Hpricot:Elem and an object that implements dateable (i.e., has a timespan object)
  def set_timespan(doc, object)
    
    # For this import, assume everything is current, even if it isn't marked that way
    
    object.create_timespan if object.timespan.nil?
    object.timespan.update_attribute(:is_current, true)
    
    #puts 'updating timespan:::::' + object.class.to_s
    #if object.respond_to? :feature
    #  puts "Feature PID == #{object.feature.pid}"
    #end
    #puts "ERRORS == #{object.errors.inspect}"
    #result = object.timespan.nil? ? object.create_timespan(:is_current => true) : object.timespan.update_attribute(:is_current, true)
    #puts result.inspect
    
    #if(doc.attributes['isCurrent'])
    #  if(doc.attributes['isCurrent']=='yes')
    #    object.timespan = Timespan.new(:is_current => true)
    #  elsif(doc.attributes['isCurrent']=='no')
    #    object.timespan = Timespan.new(:is_current => false)
    #  end
    #end
  end
  
  # ##################################################################### #
  # extract, create and save all of the object types and associate them to the current feature 
  def extract_feature_object_types(doc, feature)
    # Tie this feature to a FeatureObjectType and through it an ObjectType
    admin_thesaurus_term = doc.at("/feature/fheader/fclass")['term']

    # Does an object type exist for this code yet? 
    ot = ObjectType.find_or_create_by_code(admin_thesaurus_term.downcase)

    # Create a FeatureObjectType to tie this feature to an ObjectType
    fot = FeatureObjectType.new
    fot.feature_id = feature.id
    fot.category_id = ot.id
    fot.perspective = @current_perspective#Perspective.find_or_create_by_code(@current_perspective_code)
    raise "FeatureObjectType not saved!" unless fot.save
    
    set_timespan(doc, fot)
    
    extract_citations(doc.at("/feature/fheader/fclass"), fot)
    
    
  end
  
  # ##################################################################### #
  # extract and return the top-level (i.e., not inside another object type) geogname
  def extract_geogname(doc)
    elements = (doc/'/geogname')
    if(elements.size > 0)
      return "unknown" if elements[0].inner_text.length < 1
      return elements[0].inner_text
    else
      return "unknown"
    end
  end
  
  # ##################################################################### #
  # find the language code, check to see if it exists already. If it doesn't
  # exist yet, create it. Then return the id of the language object. 
  def attach_language_id(hpricot_doc)
    doc = hpricot_doc
    lang_attribute = (doc).attributes['lang']

    # chop off anything with more than 3 characters
    if lang_attribute.length > 3: lang_attribute = lang_attribute[0,3]
    end
    
    language = Language.find_or_create_by_code(lang_attribute)
    return language.id
  end
  
  def store_xml_document(feature)
    xml = XmlDocument.new
    xml.feature_id = feature.id
    xml.document = @current_xml_document
    raise "XmlDocument not saved!" unless xml.save
  end

  # ##################################################################### #
  #
  # Creates Feature from doc: Given an hpricot doc (the kind produced by 
  # fetch_feature_docs, for example), parse the hpricot object into the 
  # relevant gazetteer type objects (Feature, FeatureName, FeatureRelation, etc.)
  # and write these to the database. 
  #
  def parse_document(file)
   
    hpricot_doc = create_doc(file)
    raise "Feature not saved!" if hpricot_doc.nil?
    
    feature = extract_feature(hpricot_doc)
    xml_document = store_xml_document(feature)
    
    feature_object_types = extract_feature_object_types(hpricot_doc, feature)
    feature_relations = extract_feature_relations(hpricot_doc, feature)
    
    #feature_names = extract_feature_names(hpricot_doc, feature)
    extract_feature_names(hpricot_doc, feature)
    
    # When a feature is saved, it caches all of its ancestor ids. 
    # You need to make sure this happens for all of the features every time
    # a new batch has been imported. 
    features = Feature.find(:all)
    features.each do |f|
      f.save
    end
  end
  
end