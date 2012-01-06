# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Required for truncate_html
  require 'rexml/parsers/pullparser'
  
  # overrides link_to_remote in vendor/rails/action_pack/lib/action_view/prototype_helper.rb
  def link_to_remote(name, options = {}, html_options = {})
    html_options.merge!({:href => url_for(options[:url])}) if ( html_options[:href].nil? || html_options[:href].blank? ) && !options[:url].blank?
    option_html = options.delete(:html)
    html_options.merge!(option_html) if !option_html.nil?
    link_to_function(name, remote_function(options), html_options)
  end

  def collection_name
    model_name ? model_name.humanize.downcase.pluralize : nil
  end
  
  #
  #
  #
  def blank_label; '-'; end
  
  def breadcrumb_separator
    "&nbsp;<span class='arrow'>&gt;</span>&nbsp;"
  end

  #
  # Creates a breadcrumb trail to the feature
  #
  def f_breadcrumb(feature)
    # content_tag :div, acts_as_family_tree_breadcrumb(feature, breadcrumb_separator) {|r| f_link(r, feature_path(r.fid), {}, {:s => true})}, :class => "breadcrumbs"
    content_tag :div, feature.closest_ancestors_by_perspective(current_perspective).collect{|r| f_link(r, feature_path(r.fid), {}, {:s => true})}.join(breadcrumb_separator), :class => "breadcrumbs"
  end
  
  #
  # Creates a breadcrumb trail to the feature name
  #
  def fname_breadcrumb(feature_name)
    acts_as_family_tree_breadcrumb(feature_name) {|r| fname_label(r)}
	end
	
	def concise_fname_breadcrumb(feature_name)
	  label = ""
	  feature_name.all_parents.size.times { label << "> "}
	  label << fname_label(feature_name)
    label
	end
  
  #
  # Accepts an instance of an ActsAsFamilyTree node and creates a breadcrumb trail from it's ancestors
  # Can pass a block for item formatting
  #
  def acts_as_family_tree_breadcrumb(aaft_instance, sep=' &gt; ')
    if aaft_instance.parent.nil?
      grandparent = aaft_instance.all_parent_relations.collect(&:parent_node).detect(&:parent)
      trail = grandparent.nil? ? [aaft_instance] : grandparent.all_parents + [grandparent, aaft_instance]
    else
      trail = aaft_instance.all_parents + [aaft_instance]
    end
    trail.collect do |r|
      block_given? ? yield(r) : r.to_s
    end.join(sep)
  end
    
  #
  # Returns the blank_label method output
  # if the path to the value is invalid or blank
  # Can specify a different default value by supplying a block
  #
  # def_if_blank(feature_name, :type, :name)
  # def_if_blank(feature_name, :type, :name){'-'}
  #
  def def_if_blank(*resource_path)
    default = block_given? ? yield : blank_label
    obj = resource_path.shift
    resource_path.each do |method|
      return default if ! obj.respond_to?(method)
      current = obj.send(method)
      return default if current.to_s.blank?
      obj = current
    end
    obj
  end
  
  #
  #
  #
  def formatted_date(*dates)
    sep = block_given? ? yield : ' - '
    dates.compact.collect {|date| date.to_formatted_s(:us_date)}.join(sep)
  end
  
  #
  #
  #
  def f_label(feature, html_attrs={})
    html_attrs[:class] = "#{html_attrs[:class]} feature_name"
    html_attrs[:title] ||= h(feature.name)
    content_tag(:span, fname_labels(feature), html_attrs)
  end
  
  #
  #
  #
  def f_link(feature, url, html_attrs={}, options={})
    html_attrs[:class] = "#{html_attrs[:class]} feature_name"
    html_attrs[:title] ||= h(feature.name)
    url = url_for :controller => 'features', :action => 'iframe', :id => feature.id if current_page?(:controller => 'features', :action => 'iframe')
    name = fname_labels(feature)
    name = name.s if !options[:s].nil? && options[:s] == true
    link_to(name, url, html_attrs)
  end
  
  #
  # This should be getting the class from the writing system, not language
  #
  def fname_labels(feature)
    #return feature.pid if feature.names.empty?
    #items = apply_name_preference feature.names.sort
    #items.collect do |item|
    #  fname_label(item)
    #end.join(' | ')
    name = feature.prioritized_name(current_view)
    if name.nil?
      feature.pid
    else
      fname_label(name)
    end
  end
  
  def fname_label(feature_name)
    css_class=feature_name.writing_system.nil? ? nil : feature_name.writing_system.code
    content_tag(:span, h(feature_name.to_s), {:class=>css_class})
  end
  
  def description_title(d)
    title = d.title.blank? ? "Essay" : d.title
    authors = d.authors.empty? ? "" : " <span class='by'> by </span><span class='content_by'>#{join_with_and(d.authors.collect(&:fullname))}</span>"
    date = " <span class='last_updated'>(#{h(d.updated_at.to_date.to_formatted_s(:long))})</span>"
    "#{title}#{authors}#{date}"
  end
  
  def description_simple_title(d)
    d.title.blank? ? "Essay" : d.title
  end
  
  #
  #
  #
  def note_popup_link_for(object, options={})
    unless options[:association_type].blank?
      if object.respond_to?(:association_notes_for) && object.association_notes_for(options[:association_type]).length > 0
        notes = object.association_notes_for(options[:association_type])
        link_url = polymorphic_url([object, :association_notes], :association_type => options[:association_type])
      end
    else
      if object.respond_to?(:notes) && object.public_notes.length > 0
        notes = object.public_notes
        link_url = polymorphic_url([object, :notes])
      end
    end
    unless notes.nil?
      link_title = notes.collect{|n| (n.title.nil? ? 'Note' : n.title) + (" by #{n.authors.collect(&:fullname).join(", ").s}" if n.authors.length > 0).to_s}.join(', ')
      link_classes = "draggable-pop no-view-alone overflow-y-auto height-350"
      "<span class='has-draggable-popups note-popup-link'>(" +
        link_to("", link_url, :class => "note-popup-link-icon "+link_classes, :title => h(link_title)) +
        link_to("See Note", link_url, :class => "note-popup-link-text "+link_classes, :title => h(link_title)) +
      ")</span>" +
      "<script type='text/javascript'>jQuery(document).ready(function(){ActivateDraggablePopups('.has-draggable-popups');})</script>"
    else
      ""
    end
  end
  
  #
  #
  #
  def note_popup_link_list_for(object, options={})
    unless options[:association_type].blank?
      if object.respond_to?(:association_notes_for) && object.association_notes_for(options[:association_type]).length > 0
        notes = object.association_notes_for(options[:association_type])
      end
    else
      if object.respond_to?(:notes) && object.public_notes.length > 0
        notes = object.public_notes
        link_url = polymorphic_url([object, :notes])
      end
    end
    if !notes.nil? && notes.length > 0 
      # Wrapping this in a <p /> makes its font size incorrect, so for now, we'll achieve the top margin with
      # a <br />.
      '<br />
      <strong>Notes:</strong>
      <ul class="note-popup-link-list">' +
        notes.collect{|n| "<li>#{note_popup_link(n)}</li>" }.join() +
      '</ul>'
    end
  end
  
  #
  #
  #
  def note_popup_link(note)
    note_title = note.title.nil? ? "Note" : note.title
    note_authors = " by #{note.authors.collect(&:fullname).join(", ").s}" if note.authors.length > 0
    note_date = " (#{formatted_date(note.updated_at)})"
    link_title = "#{note_title}#{note_authors}#{note_date}"
    link_url = polymorphic_url([note.notable, note])
    link_classes = "draggable-pop no-view-alone overflow-y-auto height-350"
    "<span class='has-draggable-popups'>
      #{link_to(link_title, link_url, :class => link_classes, :title => h(note_title))}
    </span>
    <script type='text/javascript'>jQuery(document).ready(function(){ActivateDraggablePopups('.has-draggable-popups');})</script>"
  end
  
  #
  #
  #
  def time_units_for(object, options={})
    if object.respond_to?(:time_units)
      time_units = object.time_units_ordered_by_date
      if time_units.length > 0
        time_units_list = time_units.collect{|tu| "#{tu}#{note_popup_link_for(tu)}" }.reject{|str| str.blank?}.join("; ")
        "<span class='time-units'>(#{time_units_list})</span>"
      end
    end
  end
  
  #
  # Allows for specification of what model names should be displayed as to users (e.g. "location" instead of "shape")
  #
  def model_display_name(str)
    names = {
      'association_note' => 'note',
      'description' => 'essay',
      'feature_geo_code' => 'geo_code',
      'feature_name' => 'name',
      'feature_object_type' => 'feature_type',
      'shape' => 'location',
      'time_unit' => 'date',
      'category_feature' => Topic.human_name #'kmap_characteristic'
    }
    names[str].nil? ? str : names[str]
  end
    
  #
  #
  #
  def yes_no(value)
    (value.nil? || value==0 || value=='false' || value == false) ? ts(:negation) : ts(:affirmation)
  end
  
  #
  #
  #
  def highlight(string)
    '<span class="highlight">' + string + '</span>'
  end
  
  def side_column_links
    str = "<h3 class=\"head\">#{link_to 'Place Dictionary', '#nogo', {:hreflang => 'Manages geographical features.'}}</h3>\n<ul>\n"
    str += "<li>#{link_to 'Home', root_path, {:hreflang => 'Search and navigate through places.'}}</li>\n"
	    str += "<li>#{link_to 'Help', '#wiki=/access/wiki/site/c06fa8cf-c49c-4ebc-007f-482de5382105/thl%20place%20dictionary%20end%20user%20manual.html', {:hreflang => 'End User Manual'}}</li>"
    str += "<li>#{link_to 'Edit', admin_admin_path, {:hreflang => 'Manage places.'}}</li>\n" if logged_in?
    str += "<li>#{link_to 'Editing Help', '#wiki=/access/wiki/site/c06fa8cf-c49c-4ebc-007f-482de5382105/thl%20place%20dictionary%20editorial%20manual.html', {:hreflang => 'Editorial Manual'}}</li>" if logged_in?
    str += "<li>#{link_to 'Feature Thesaurus', "#iframe=#{Category.get_url('20/children')}", {:hreflang => 'Feature Thesaurus'}}</li>"
    str += "</ul>"
    return str
  end

  def stylesheet_files
    super + ['public', 'jquery-ui-tabs']
  end

  def custom_secondary_tabs_list
    # The :index values are necessary for this hash's elements to be sorted properly
    {
      :place => {:index => 1, :title => "Place"},
      :descriptions => {:index => 2, :title => "Essays"},
      :related => {:index => 3, :title => "Related"}
    }
  end
  
  def custom_secondary_tabs(current_tab_id=:place)

    @tab_options ||= {}
    
    if @tab_options[:entity].blank?
      tabs = {}
    else
      tabs = custom_secondary_tabs_list
    end
    
    current_tab_id = :place unless (tabs.keys << :home).include? current_tab_id
    
    tabs = tabs.sort{|a,b| a[1][:index] <=> b[1][:index]}.collect{|tab_id, tab|
      remove_tab = false
      if tab[:url].blank? && !@tab_options[:entity].blank?
        entity = @tab_options[:entity]
        url = nil
        count = nil
        case tab_id
        when :place
          url = feature_path(entity.fid)
        when :descriptions
          if entity.descriptions.empty?
            remove_tab = true
          else
            url = feature_description_path(entity.fid, entity.descriptions.first)
            count = entity.descriptions.length
          end
        when :related
          url = related_feature_path(entity.fid)
          count = nil
        end
      else
        tab_url = tab[:url]
      end
      title = count.nil? ? tab[:title] : "#{tab[:title]} (#{count})"
      
      remove_tab ? nil : [tab_id, title, url]
    }.reject{|t| t.nil?}
    
    tabs
  end
    
  def shape_display_string(shape)
    return shape.geo_type unless shape.is_point?
    return "Latitude: #{shape.lat}; Longitude: #{shape.lng}"
  end
  
  def altitude_display_string(altitude)
    a = []
    a << altitude.estimate if !altitude.estimate.nil?
    a << "#{altitude.average} (average)" if !altitude.average.nil?
    a << "#{altitude.minimum} (minimum)" if !altitude.minimum.nil?
    a << "#{altitude.maximum} (maximum)" if !altitude.maximum.nil?
    a.empty? ? '' : a.join(', ')
  end
  
  # TODO: Add rules here based on language of name and perspective.
  def apply_name_preference(names)
    return [] if names.empty?
    filtered = []
    # FIXME: This should be cleaned up; most direct implementation to get something working
    latin_names = names.select {|n| !n.writing_system.blank? and n.writing_system.is_latin?}
    latin_names.each do |name|
      unless name.language.blank?
        filtered << name if name.language.is_english?
        if name.language.is_chinese?
          related_name = name.relations.select {|r| !r.phonetic_system.blank? and r.phonetic_system.is_pinyin? }
          filtered << related_name.first.child_node unless related_name.empty?
        end
        if name.language.is_nepali?
          related_name = name.relations.select {|r| !r.phonetic_system.blank? and r.phonetic_system.is_ind_transcrip? }
          filtered << related_name.first.child_node unless related_name.empty?
          filtered << name if name.is_original? and related_name.empty?
        end
        if name.language.is_tibetan?
          related_name = name.relations.select {|r| !r.phonetic_system.blank? and r.phonetic_system.is_thl_simple_transcrip? }
          filtered << related_name.first.child_node unless related_name.empty?
        end
      end
    end
    # TODO: improve fallback. For now names transcript in latin script are better than nothing.
    if filtered.empty?
      latin_names
    else
      filtered.uniq # in case any dupes get added
    end
  end
  
  def join_with_and(list)
    size = list.size
    case size
    when 0 then nil
    when 1 then list.first
    when 2 then list.join(' and ')
    when 3 then [list[0..size-2].join(', '), list[size-1]].join(', and ')
    end.s
  end
  
  # Custom HTML truncate for PD descriptions, which don't always validate
  def truncate_html(input, len = 30, extension = "...")
    output = input
    output.gsub!(/<\/p>\s*<p>/is, "<br /><br />")
    output = sanitize(input, :tags => %w(br h1 h2 h3 h4 h5 h6 ul ol li))
    output.gsub!(/<br.*?>/, "\v")
    if output.length < len
      return input
    end
    
    # We need to be able to call .s on the input, but not on the extension, so we
    # have to use a modified version of truncate() instead of truncate() itself.
    # output = truncate(input, :length => len, :omission => extension)
    l = len - extension.mb_chars.length
    chars = input.mb_chars
    # Temporarily removing .s, as it takes a while to run on long strings
    #output = (chars.length > len ? chars[0...l].s + extension : input).to_s
    output = (chars.length > len ? chars[0...l] + extension : input).to_s
    
    output.strip!
    output.gsub!(/\v/, "<br />")
    output
  end
  
  # HTML truncate for valid HTML, requires REXML::Parsers::PullParser
  def truncate_well_formed_html(input, len = 30, extension = "...")
    def attrs_to_s(attrs)
      return '' if attrs.empty?
      attrs.to_a.map { |attr| %{#{attr[0]}="#{attr[1]}"} }.join(' ')
    end

    p = REXML::Parsers::PullParser.new(input)
      tags = []
      new_len = len
      results = ''
      while p.has_next? && new_len > 0
        p_e = p.pull
        case p_e.event_type
      when :start_element
        tags.push p_e[0]
        results << "<#{tags.last} #{attrs_to_s(p_e[1])}>"
      when :end_element
        results << "</#{tags.pop}>"
      when :text
        results << p_e[0].first(new_len)
        new_len -= p_e[0].length
      end
    end

    tags.reverse.each do |tag|
      results << "</#{tag}>"
    end

    results.to_s + (input.length > len ? extension : '')
  end
  
  # Override the default page_entries_info from will_paginate
  def page_entries_info(collection, options = {})
    entry_name = options[:entry_name] ||
      (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
    
    if collection.total_pages < 2
      case collection.size
      when 0; "No #{entry_name.pluralize} found"
      when 1; "Displaying <b>1</b> #{entry_name}"
      else;   "Displaying <b>all #{collection.size}</b> #{entry_name.pluralize}"
      end
    else
      %{Showing #{entry_name.pluralize} <b>%d&nbsp;-&nbsp;%d</b> of <b>%d</b>} % [
        collection.offset + 1,
        collection.offset + collection.length,
        collection.total_entries
      ]
    end
  end
  
  def javascript_on_load(*args, &block)
    if block_given?
      concat(javascript_tag "$(document).ready(function(){#{capture(&block)}})")
    else
      javascript_tag "$(document).ready(function(){#{args.first}})"
    end
  end

   def google_maps_key
     hostname = Socket.gethostname.downcase
     if hostname== 'e-bhutan.bt'
       'ABQIAAAA-y3Dt_UxbO4KSyjAYViOChQYlycRhKSCRlUWwdm5YkcOv9JZvxQ7K1N-weCz0Vvcplc8v8TOVZ4lEQ'
     else
       'ABQIAAAAmlH3GDvD6dTOdZjfrfvLFxTkTKGJ2QQt6wuPk9SnktO8U_sCzxTyz_WwKoSJx63MPLV9q8gn8KCNtg'
     end
   end
     
end