# == Schema Information
# Schema version: 20091102185045
#
# Table name: descriptions
#
#  id         :integer         not null, primary key
#  feature_id :integer         not null
#  content    :text            not null
#  is_primary :boolean         not null
#  created_at :timestamp
#  updated_at :timestamp
#  title      :string(255)
#

class Description < ActiveRecord::Base
    validates_presence_of :content, :feature_id
    #belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
    belongs_to :feature  
    has_and_belongs_to_many :authors, :class_name => 'User', :join_table => 'authors_descriptions', :association_foreign_key => 'author_id' 


    def self.search(filter_value, options={})
      options[:conditions] = build_like_conditions(
        %W(description.content),
        filter_value
      )
      paginate(options)
    end
end
