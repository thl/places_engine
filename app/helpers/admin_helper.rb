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
    items << link_to(options[:edit_name] || 'edit', options[:edit_path]) unless options[:hide_edit]
    items << link_to(options[:view_name] || 'view', options[:view_path]) unless options[:hide_view]
    items << link_to(options[:delete_name] || 'x', options[:delete_path], :method=>:delete, :confirm=>'WAIT! Are you sure you want to DELETE this item?') unless options[:hide_delete]
    '<span class="listActions">'+items.join(' | ')+'</span>'
  end
  
  def resource_nav
    resources = {
      'Admin Home'=>admin_admin_path,
      'Blurbs'=>admin_blurbs_path,
      'Features'=>admin_features_path,
      'Feature Relations'=>admin_feature_relations_path,
      'Feature Names'=>admin_feature_names_path,
      'Feature Name Types'=>admin_feature_name_types_path,
      'Feature Name Relations'=>admin_feature_name_relations_path,
      'Feature Geocodes'=>admin_feature_geo_codes_path,
      'Geocode Types'=>admin_geo_code_types_path,
      'Citations'=>admin_citations_path,
      'Info Sources'=>admin_info_sources_path,
      'Perspectives'=>admin_perspectives_path,
      'Languages'=>admin_languages_path,
      'Notes'=>admin_notes_path,
      'Note Titles'=>admin_note_titles_path,
      'Writing Systems'=>admin_writing_systems_path,
      'Phonetic Systems'=>admin_phonetic_systems_path,
      'Orthographic Systems'=>admin_orthographic_systems_path,
      'Alt Spelling Systems'=>admin_alt_spelling_systems_path,
      'Users'=>admin_users_path,
      'Feature IDs Generator' => admin_feature_pids_path,
      'Views' => admin_views_path
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
        #{form_builder.radio_button field, yes_value, yes_options} Yes
      </label>
      <label>
        #{form_builder.radio_button field, no_value, no_options} No
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
    root_names = feature.names.current_roots if feature
    html=''
    root_names.each do |name|
      next if completed.include? name
      next unless name.is_current?
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
      next unless name.is_current?
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
    				  :view_path   => admin_feature_feature_name_path(name.feature, name),
    				  :view_name   => 'manage'
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
    	html += '<td>' + formatted_timespan(name.timespan).to_s + '</td>'
    	html += '<td>' + name.position.to_s + '</td>'
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
  def timespans_link
    link_to 'timespans', admin_timespans_path
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
    feature_names.current_roots.each do |r|
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
    feature.nil? ? link_to('admin', admin_path) : link_to('descriptions', admin_feature_descriptions_path(feature))
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
  # Uses the sentence labels found in FeatureRelation::ROLES
  #
  def feature_relation_role_label(feature, relation, opts={})
    options={
      :use_first=>true,:use_second=>true,:use_relation=>true,
      :link_first=>true,:link_second=>true,:link_relation=>true
    }.merge(opts)
    relation.role_of?(feature) do |other,sentence|
      sep = '&nbsp;'
      items=[]
      if options[:use_first]
        items << (options[:link_first] ? 
          (options[:use_names] ? f_link(feature, admin_feature_path(feature)) : feature_link(feature)) : 
          feature_label(feature))
      end
      if options[:use_relation]
        # join the sentences AND spaces with the sep variable
        sentence = sentence.join(sep).gsub(/ /, sep)
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
      items.join(sep)
    end
  end
  
  def note_list_fieldset(options={})
    object = options[:object] || @object
    html = "<fieldset>
    	<legend>Notes</legend>
    	<div class='left highlight'>
    	  #{link_to('New Note', new_polymorphic_path([:admin, object, :note]))}
    	</div>
    	<br class='clear'/>
    	#{render :partial => 'admin/notes/list', :locals => { :list => object.notes }}
    </fieldset>"
    html
  end
  
  def fn_relationship(feature_name)
    feature_name.display_string
  end

  def stylesheet_files
    ['yui','admin', 'language_support']
  end
  
  def javascript_files
    super + ['admin']
  end
  
  def javascripts
    super + include_tiny_mce_if_needed
  end

end