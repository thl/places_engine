module DescriptionsHelper
  
  def description_name(d)
		title = d.title.blank? ? 'Description' : d.title
		authors = join_with_and(d.authors.collect{|a| a.screen_name}) unless d.authors.blank?
		by = ' by ' unless authors.blank?
		last_updated = " (#{h(d.updated_at.to_date.to_formatted_s(:long))})"
		"<span class='title'>#{title}</span>"+
		"<span class='by'>#{by}</span>"+
		"<span class='content_by'>#{authors}</span>"+
		"<span class='last_updated'>#{last_updated}</span>"
  end
  
end
