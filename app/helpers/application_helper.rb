# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Required for truncate_html
  require 'rexml/parsers/pullparser'
  
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
    content_tag :div, acts_as_family_tree_breadcrumb(feature, breadcrumb_separator) {|r| f_link(r, features_path(:anchor => r.id), {}, {:s => true})}, :class => "breadcrumbs"
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
    (aaft_instance.all_parents + [aaft_instance]).collect do |r|
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
      if object.respond_to?(:notes) && object.notes.length > 0
        notes = object.notes
        link_url = polymorphic_url([object, :notes])
      end
    end
    unless notes.nil?
      link_title = notes.collect{|n| (n.title.nil? ? "Note" : n.title) + (" by #{n.authors.collect{|a| a.fullname}.join(", ")}" if n.authors.length > 0).to_s}.join(", ").to_s
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
      if object.respond_to?(:notes) && object.notes.length > 0
        notes = object.notes
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
    note_authors = " by #{note.authors.collect{|a| a.fullname}.join(", ")}" if note.authors.length > 0
    note_date = " (#{formatted_date(note.updated_at)})"
    link_title = "#{note_title}#{note_authors}#{note_date}"
    link_url = polymorphic_url([note.notable, note])
    link_classes = "draggable-pop no-view-alone overflow-y-auto height-350"
    "<span class='has-draggable-popups'>
      #{link_to(link_title, link_url, :class => link_classes, :title => h(link_title))}
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
  #
  #
  def yes_no(value)
    (value.nil? || value==0 || value=='false' || value == false) ? 'no' : 'yes'
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
    super + ['public']
  end
    
  def shape_display_string(shape)
    return shape.geo_type unless shape.is_point?
    s = "Latitude: #{shape.lat}; Longitude: #{shape.lng}"
    s << "; Altitude: #{shape.altitude}" if !shape.altitude.nil?
    s
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
    end
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
    output = (chars.length > len ? chars[0...l].s + extension : input).to_s
    
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

   # Get the URL of the main THL site, based on the current environment (is this defined elsewhere?).
   # This is currently used for loading JavaScript from the main THL site.
   def thl_url
     hostname = Socket.gethostname.downcase
     if hostname == 'dev.thlib.org'
       return 'http://dev.thlib.org'
     elsif hostname =~ /\.local/ && hostname !~ /^a/
       return 'http://localhost:90'
     else
       return 'http://www.thlib.org'
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