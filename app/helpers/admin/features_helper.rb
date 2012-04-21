module Admin::FeaturesHelper
  
  #
  # Standard admin helpers
  #
  include AdminHelper
  
  #
  # helper methods to build Features Tree
  #
  include ::FeaturesTreeHelper
  
  #
  # Creates the text value for a li node in the features tree
  # This gets called from ::FeaturesHelper.build_features_contextual_tree
  # and overrides ::FeaturesHelper.node_li_label
  #
  def node_li_value(node, target)
    return f_label(node, :class=>"selected") if target && target.id == node.id
    f_link(node, current_features_path(:context_id=>node.id, :filter=>params[:filter]))
  end
  
  #
  # A start on more a flexible search form:
  #
=begin
  def search_form(path, clear_path, hidden_field_params=[])
    html = "<div>"
    html += form_tag admin_features_path, :method=>:get
    html += text_field_tag :filter, h(params[:filter]), :class => :text
    hidden_field_params.each do |p|
      html += hidden_field_tag :context_id, h(params[:context_id])
    end
    html += submit_tag 'Search'
    html += ' '
    html += link_to 'clear', :context_id=>params[:context_id] if params[:filter]
    html += '</form></div>'
  end
=end
  
  #
  # creates the current features index path
  # either the index action or the locate_for_relation action
  #
  def current_features_path(*args)
    @locating_relation ? locate_for_relation_admin_feature_path(@object, *args) : admin_features_path(*args)
  end
  
  #
  #
  #
  def search_form
    html = "<div>"
    html += form_tag current_features_path, :method=>:get
    html += text_field_tag :filter, h(params[:filter]), :class => :text
    html += hidden_field_tag :context_id, h(params[:context_id])
    html += submit_tag 'Search'
    html += ' '
    html += link_to 'clear', :context_id=>params[:context_id] if params[:filter]
    html += '</form></div>'
    html.html_safe
  end
  
  #
  # Creates a message for the item list (index view)
  # using the context feature and search filter value
  #
  def context_search_message(context_feature)
    messages = []
    unless context_feature.nil?
      messages << "#{f_label(context_feature)} and descendants"
    end
    unless params[:filter].blank?
      messages << "<strong class='message'>[filter = #{h(params[:filter])}]</strong>"
    end
    if messages.blank?
      messages << 'Showing all'
    end
    messages.join(' ') if messages.size > 0
  end
  
end