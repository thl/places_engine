class Page < ActiveRecord::Base
  attr_accessible :volume, :start_page, :start_line, :end_page, :end_line
  belongs_to :citation
  
  def to_s
    s = volume.nil? ? '' : "#{volume}: "
    s << start_page.to_s if !start_page.nil?
    s << ".#{start_line}" if !start_line.nil?
    if (!start_page.nil? || !start_line.nil?) && (!end_page.nil? || !end_line.nil?) && (start_page != end_page || start_line != end_line)
      s << " - "
      s << end_page.to_s if !end_page.nil?
      if !end_line.nil?
        s << '.' if !end_page.nil?
        s << end_line.to_s
      end
    end
    s
  end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: pages
#
#  id          :integer         not null, primary key
#  citation_id :integer
#  end_line    :integer
#  end_page    :integer
#  start_line  :integer
#  start_page  :integer
#  volume      :integer
#  created_at  :timestamp
#  updated_at  :timestamp