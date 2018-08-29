module TopicsHelper
  def category_feature_list(category_features)
    category_list = ""
    category_features.each do |cf|
      c = cf.category
      if !c.nil?
        values = []
        values << cf.string_value if !cf.string_value.blank?
        values << cf.numeric_value if !cf.numeric_value.nil?
        stack = cf.category_stack
        stack.push(link_to(stack.pop, c.get_url(nil, :format => '')))
        topic_stack = "#{stack.join(' > ')}"
        topic_stack += ":" if !values.empty?
        topic_stack += " #{values.join(', ')}" if !values.empty?
        category_list += content_tag(:li, "#{topic_stack} #{time_units_for(cf)} #{note_popup_link_for(cf)}".html_safe)
      end
    end
    category_list
  end
end
