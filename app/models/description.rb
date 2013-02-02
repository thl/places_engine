class Description < ActiveRecord::Base
    attr_accessible :title, :content, :is_primary, :author_ids
    validates_presence_of :content, :feature_id
    #belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
    belongs_to :feature  
    has_and_belongs_to_many :authors, :class_name => 'AuthenticatedSystem::Person', :join_table => 'authors_descriptions', :association_foreign_key => 'author_id'
    accepts_nested_attributes_for :authors
  
    extend IsCitable
    extend IsNotable
    extend IsDateable

    def self.search(filter_value)
      self.where(build_like_conditions(%W(description.content), filter_value))
    end
    
    def to_s
      title
    end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: descriptions
#
#  id         :integer         not null, primary key
#  feature_id :integer         not null
#  content    :text            not null
#  is_primary :boolean         not null
#  source_url :string(255)
#  title      :string(255)
#  created_at :timestamp
#  updated_at :timestamp