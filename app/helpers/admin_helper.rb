#
# THIS NEEDS TO BE INCLUDED IN OTHER HELPERS TO USE:
# include AdminHelper
#
module AdminHelper  
  def admin_textarea(form_builder, field, options={})
    options[:cols] ||= 70
    options[:rows] ||= 10
    form_builder.text_area(field, options)
  end
  
  #
  # Returns the base path of the current url (removes the query params)
  #
  def resolved_collection_path
    request.env['PATH_INFO']
  end
  
  def list_actions_for_item(item, options={})
    options[:edit_path] ||= edit_object_path(item)
    options[:view_path] ||= object_path(item)
    options[:delete_path] ||= object_path(item)
    items=[]
    items << edit_item_link(options[:edit_path], options[:edit_name]) unless options[:hide_edit]
    if !options[:manage_path].blank?
      items << manage_item_link(options[:manage_path], options[:manage_name]) unless options[:hide_manage]
    end
    items << view_item_link(options[:view_path], options[:view_name]) unless options[:hide_view]
    items << delete_item_link(options[:delete_path], options[:delete_name]) unless options[:hide_delete]
    '<span class="listActions">'+items.join(' | ')+'</span>'
  end
  
  def resource_nav
    resources = {
      'Admin Home'=>admin_admin_path,
      'Alt Spelling Systems'=>admin_alt_spelling_systems_path,
      'Blurbs'=>admin_blurbs_path,
      'Citations'=>admin_citations_path,
      'Features'=>admin_features_path,
      'Feature Geocodes'=>admin_feature_geo_codes_path,
      'Feature IDs Generator' => admin_feature_pids_path,
      'Feature Names'=>admin_feature_names_path,
      'Feature Name Relations'=>admin_feature_name_relations_path,
      'Feature Name Types'=>admin_feature_name_types_path,
      'Feature Relations'=>admin_feature_relations_path,
      'Feature Relation Types'=>admin_feature_relation_types_path,
      'Geocode Types'=>admin_geo_code_types_path,
      'Languages'=>admin_languages_path,
      'Notes'=>admin_notes_path,
      'Note Titles'=>admin_note_titles_path,
      'Orthographic Systems'=>admin_orthographic_systems_path,
      'People'=>admin_people_path,
      'Perspectives'=>admin_perspectives_path,
      'Phonetic Systems'=>admin_phonetic_systems_path,
      'Views' => admin_views_path,
      'Writing Systems'=>admin_writing_systems_path
    }.sort
    select_tag :resources, options_for_select(resources,  "/#{params[:controller]}"), :id=>:SelectNav
  end
  
  def resource_search_form(extra_hidden_fields={})
    #extra_hidden_fields[:page] = params[:page] # keep the current page when clearing?
    html = "<div>"
    html += form_tag '', :method=>:get
    html += text_field_tag :filter, h(params[:filter]), :class => :text
    extra_hidden_fields.each do |k,v|
      html += hidden_field_tag k, h(v)
    end
    html += submit_tag 'Search'
    html += ' '
    html += link_to('clear', resolved_collection_path, extra_hidden_fields) if params[:filter]
    html += '</form></div>'
  end
  
  #
  # This is set on top of the column headers in a list table
  #
  def pagination_row(options={})
    # switch between the pagination and a non-breaking space:
    content = @collection.total_pages > 1 ? will_paginate(@collection) : '&nbsp;'
    "<tr>
      <th style='text-align:right;' class='paginationHeader' colspan=#{options[:colspan]}'>
        <div style='position:absolute;'>#{@collection.total_entries} Total</div>
        #{content}
      </th>
    </tr>"
  end
  
  def parent_resource_dependency_message
    "A #{model_name.titleize} can only be created from a resource that uses one."
  end
  
  def empty_collection_message(message="No #{model_name.titleize.pluralize} found.")
    "<div class='info'>#{message}</div>"
  end
  
  #
  #
  #
  def page_title
    title = @page_title
    
    @page_title = 'THL Places Editor'
    unless respond_to? :model_name
      return [@page_title, title].join(': ')
    end
    
    # index, show, new, create, edit, update, delete
    name = model_name.titleize
    default = "#{params[:controller].sub(/admin\//,'').titleize}: #{params[:action].humanize.downcase}"
    map = {
      :index=>"Listing #{name.pluralize}",
      :show=>"Showing #{name}",
      :new=>"Creating #{name}",
      :create=>"Creating #{name}",
      :edit=>"Editing #{name}",
      :update=>"Editing #{name}",
      :delete=>"Deleting #{name}"
    }
    found = map[params[:action].to_sym]
    @page_title = [@page_title, (found.nil? ? default : found), title].join(': ')
  end
  
  #
  #
  #
  def yes_no_radios(form_builder, field, options={}, yes_options={}, no_options={})
    yes_value = 1
    no_value = 0
    if (form_builder.object.send field).nil?
      no_value = nil
    end
    "<div#{' class="'+options[:class]+'"' if options[:class]}>
      <label>
        #{form_builder.radio_button field, yes_value, yes_options} #{ts :affirmation}
      </label>
      <label>
        #{form_builder.radio_button field, no_value, no_options} #{ts :negation}
      </label>
    </div>"
  end
    
  #
  #
  #
  def feature_name_link(feature_name)
    link_to(feature_name, admin_feature_feature_name_path(feature_name.feature, feature_name))
  end
  
  #
  #
  #
  def features_link
    link_to_unless_current('features', admin_features_path)
  end
  
  #
  #
  #
  def model_label(model)
    case model.class.to_s
      when 'Feature'
        feature_label(model)
      else
        model.to_s
      end
  end
    
  #
  #
  #
  def model_link(model)
    case model.class.to_s
      when 'Feature'
        feature_link(model)
      else
        link_to(model.to_s.humanize, model_path(model))
      end
  end
  
  #
  # Wraps the block contents in a div
  # and adds a "Feature: " start crumb
  #
  def render_breadcrumbs
    #@breadcrumbs.unshift link_to_unless_current('features', admin_features_path)
    @breadcrumbs.to_a.join(' > ')
  end
  
  def add_breadcrumb_item(item)
    @breadcrumbs ||= []
    @breadcrumbs << item
  end
  
  def add_breadcrumb_items(*items)
    items.each {|item| add_breadcrumb_item item}
  end
  
  #
  # Pass in a set of root FeatureNames (having the same parent)
  # to build a ul list
  # "completed" is used only by this method
  #
  def feature_name_ul(feature, use_links=true, root_names=nil, completed=[])
    root_names = feature.names.roots if feature
    html=''
    root_names.each do |name|
      next if completed.include? name
      completed << name
      html += '<li style="margin-left:1em; list-style:square;">'
      html += (use_links ? link_to(name.name, admin_feature_name_path(name)) : name.name)
      html += feature_name_ul(nil, use_links, name.children, completed)
      html += '</li>'
    end
    html.blank? ? '' : "<ul style='margin:0;'>#{html}</ul>"
  end
  
  #
  # Pass in a set of root FeatureNames (having the same parent)
  # to build a ul list
  # "completed" is used only by this method
  #
  def feature_name_tr(feature, root_names=nil, completed=[])
    root_names = feature.names.roots if feature
    root_names = root_names.sort_by{ |i| i[:position] }
    html=''
    root_names.each do |name|
      next if completed.include? name
      completed << name
      
    	html += '<tr id="feature_name_'+name.id.to_s+'"><td class="centerText">';
    	if @locating_relation
    	  html += form_tag new_admin_feature_name_feature_name_relation_path(feature), {:method=>:get}
    		html += hidden_field_tag :target_id, name.id
    		html += submit_tag 'Select'
    	  html += '</form>'
    	else
    	  html += list_actions_for_item(name,
    				{
    				  :delete_path => admin_feature_feature_name_path(name.feature, name),
    				  :edit_path   => edit_admin_feature_feature_name_path(name.feature, name),
    				  :manage_path => admin_feature_feature_name_path(name.feature, name),
    				  :hide_view   => true
    			  }
    			)
    	end
    	html +=	'</td>'
    	padding = name.all_parents.size * 25
    	html +=	'<td style="padding-left: ' + padding.to_s + 'px">'
    	html += (name.name) + '</td>'
    	html += '<td>' + def_if_blank(name, :class).to_s + '</td>'
    	html += '<td>' + def_if_blank(name, :language).to_s + '</td>'
    	html += '<td>' + def_if_blank(name, :writing_system).to_s + '</td>'
    	html += '<td>' + fn_relationship(name).to_s + '</td>'
    	html += '<td>' + name.position.to_s + '</td>'
    	html += '<td>' + note_link_list_for(name) + '</td>'
    	html += '<td>' + new_note_link_for(name) + '</td>'
    	html += '<td>' + time_unit_link_list_for(name) + '</td>'
    	html += '<td>' + new_time_unit_link_for(name) + '</td>'
      html += '</tr>'
      html += feature_name_tr(nil, name.children, completed).to_s
    end
    html.blank? ? '' : "<ul style='margin:0;'>#{html}</ul>"
  end  
  #
  #
  #
  def feature_relations_link(feature_instance=nil)
    if feature_instance.nil?
      link_to('feature relations', admin_feature_relations_path)
    else
      link_to('relations', admin_feature_feature_relations_path(feature_instance))
    end
  end
  
  #
  #
  #
  def citations_link
    link_to 'citations', admin_citations_path
  end
  
  #
  #
  #
  def feature_label(feature)
    "<span class='featureLabel' title='#{h feature.name}'>#{fname_labels(feature)}</span>"
  end
  
  #
  #
  #
  def feature_link(feature, *args)
    link_to(fname_labels(feature), admin_feature_path(feature, *args), {:class=>:featureLabel, :title=>h(feature.name)})
  end
  
  def feature_names_sorted(feature_names)
    list = []
    feature_names.roots.each do |r|
      list << r
      load_child_names(r, list)
    end
    list
  end
  
  def load_child_names(feature_name, list)
    return if feature_name.children.empty?
    feature_name.children.find(:all, :order => 'position').each do |c|
      list << c
      load_child_names(c, list)
    end
  end
  
  #
  #
  #
  def feature_names_link(feature=nil)
    feature.nil? ? link_to('feature names', admin_feature_names_path) : link_to('names', admin_feature_feature_names_path(feature))
  end
  
  #
  #
  #
  def feature_names_prioritize_link(feature=nil)
    feature.nil? ? link_to('admin', admin_path) : link_to('prioritize names', '/admin/feature_names/prioritize/' + feature.id.to_s)
  end
  
  def feature_descriptions_link(feature=nil)
    feature.nil? ? link_to('admin', admin_path) : link_to('essays', admin_feature_descriptions_path(feature))
  end
  #
  #
  #
  def feature_name_relations_link(feature_name=nil)
    feature_name.nil? ? link_to('feature name relations', admin_feature_name_relations_path) : link_to('relations', admin_feature_name_feature_name_relations_path(feature_name))
  end
  
  #
  #
  #
  def feature_name_label(feature_name)
    '<span class="featureNameLabel">' + feature_name.to_s + '</span>'
  end

  #
  #
  #
  def feature_shapes_link(feature=nil)
    feature.nil? ? link_to('feature shapes', admin_feature_shapes_path) : link_to('shapes', admin_feature_shapes_path(feature))
  end
  
  #
  # Express the relationship relative to the "feature" arg node
  #
  def feature_relation_role_label(feature, relation, opts={})
    options={
      :use_first=>true,:use_second=>true,:use_relation=>true,
      :link_first=>true,:link_second=>true,:link_relation=>true
    }.merge(opts)
    relation.role_of?(feature) do |other,sentence|
      items=[]
      if options[:use_first]
        items << (options[:link_first] ? 
          (options[:use_names] ? f_link(feature, admin_feature_path(feature)) : feature_link(feature)) : 
          feature_label(feature))
      end
      if options[:use_relation]
        sentence = sentence
        items << (options[:link_relation] ? link_to(sentence, admin_feature_feature_relation_path(feature, relation)) : sentence)
      end
      if options[:use_second]
        items << (options[:link_second] ? 
          (options[:use_names] ? f_link(other, admin_feature_path(other)) : feature_link(other)) : 
          feature_label(other))
        if options[:show_feature_types]
          items << "(" + other.object_types.collect{|type| type.title }.join(", ") + ")"
        end
      end
      items.join(" ")
    end
  end
  
  def association_note_list_fieldset(association_type, options={})
    "<h4>General Notes</h4>
  	  #{highlighted_new_item_link new_polymorphic_path([:admin, @object, :association_note], :association_type => association_type), 'New Note'}
    	<br class='clear'/>
  	  #{render :partial => 'admin/association_notes/list', :locals => { :list => @object.association_notes_for(association_type, :include_private => true), :options => {:hide_type => true, :hide_type_value => true, :hide_association_type => true, :hide_empty_collection_message => true} }}"
  end
  
  def note_list_fieldset(object=nil)
    object ||= @object
    html = "<fieldset>
    	<legend>Notes</legend>
    	<div class='left highlight'>
    	  #{new_item_link(new_polymorphic_path([:admin, object, :note]), 'New Note')}
    	</div>
    	<br class='clear'/>
    	#{render :partial => 'admin/notes/list', :locals => { :list => object.notes, :options => {:hide_type => true, :hide_type_value => true} }}
    </fieldset>"
    html
  end
  
  def citation_list_fieldset(options={})
    object = options[:object] || @object
    html = "<fieldset>
    	<legend>Citations</legend>
    	<div class='left highlight'>
    	  #{new_item_link(new_polymorphic_path([:admin, object, :citation]), 'New Citation')}
    	</div>
    	<br class='clear'/>
    	#{render :partial => 'admin/citations/citations_list', :locals => { :list => object.citations, :options => {:hide_type => true, :hide_type_value => true} }}
    </fieldset>"
    html
  end
  
  def time_unit_list_fieldset(options={})
    object = options[:object] || @object
    html = "<fieldset>
    	<legend>Dates</legend>
    	<div class='left highlight'>
    	  #{new_item_link(new_polymorphic_path([:admin, object, :time_unit]), 'New Date')}
    	</div>
    	<br class='clear'/>
    	#{render :partial => 'admin/time_units/list', :locals => { :list => object.time_units, :options => {:hide_type => true, :hide_type_value => true} }}
    </fieldset>"
    html
  end
    
  def note_link_list_for(object)
    if object.respond_to?(:notes) && object.notes.length > 0
      object.notes.enum_with_index.collect{|n, i|
        note_title = n.title.blank? ? "Note" : n.title
        note_authors = " by #{n.authors.collect(&:fullname).join(", ").s}" if n.authors.length > 0
        link_to "Note #{i+1}", polymorphic_path([:admin, object, n]), :title => h("#{note_title}#{note_authors}")
      }.join(", ").to_s
    else
      ""
    end
  end
  
  def time_unit_link_list_for(object)
    if object.respond_to?(:time_units)
      time_units = object.time_units_ordered_by_date
      if time_units.length > 0
        time_units.enum_with_index.collect{|tu, i|
          time_unit_title = tu.to_s.blank? ? "Date" : tu.to_s
          link_to "Date #{i+1}", polymorphic_path([:admin, object, tu]), :title => h("#{time_unit_title}")
        }.join(", ").to_s
      else
        ""
      end
    else
      ""
    end
  end
    
  def new_note_link_for(object, options={})
    if object.respond_to?(:notes)
      new_item_link new_polymorphic_path([:admin, object, :note]), options[:include_text] ? "New Note" : ""
    else
      ""
    end
  end

  def new_time_unit_link_for(object, options={})
    if object.respond_to?(:time_units)
      new_item_link new_polymorphic_path([:admin, object, :time_unit]), options[:include_text] ? "New Date" : ""
    else
      ""
    end
  end
    
  def fn_relationship(feature_name)
    feature_name.display_string
  end

  def stylesheet_files
    ['yui','admin', 'interface_utils'] + super
  end
  
  def javascript_files
    super + ['admin']
  end
  
  def javascripts
    super + include_tiny_mce_if_needed
  end

end
