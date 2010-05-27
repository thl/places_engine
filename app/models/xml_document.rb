class XmlDocument < ActiveRecord::Base
  
  belongs_to :feature
  
end

# == Schema Info
# Schema version: 20100526225546
#
# Table name: xml_documents
#
#  id         :integer         not null, primary key
#  feature_id :integer         not null
#  document   :text            not null
#  created_at :timestamp
#  updated_at :timestamp