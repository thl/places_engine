require 'will_paginate'
require 'will_paginate/view_helpers'

WillPaginate::LinkRenderer.class_eval do
  
  def page_link_or_span(page, span_class, text = nil)
    text ||= page.to_s
    
    if page and page != current_page
      if @options[:custom] and @template.methods.include? 'generate_will_paginate_link'
        @template.generate_will_paginate_link(page, text)
      else
        classnames = span_class && span_class.index(' ') && span_class.split(' ', 2).last
        page_link page, text, :rel => rel_value(page), :class => classnames
      end
    else
      page_span page, text, :class => span_class
    end    
  end
end
