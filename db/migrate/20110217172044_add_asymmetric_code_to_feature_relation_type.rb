class AddAsymmetricCodeToFeatureRelationType < ActiveRecord::Migration
  def self.up
    add_column :feature_relation_types, :asymmetric_code, :string
    FeatureRelationType.reset_column_information
    FeatureRelationType.all(:conditions => {:is_symmetric => false}).each { |type| type.update_attribute(:asymmetric_code, (type.label || type.asymmetric_label).downcase.squish.gsub( /\s/, '.' )) }
  end

  def self.down
    remove_column :feature_relation_types, :asymmetric_code
  end
end
