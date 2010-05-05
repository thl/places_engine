class ConvertFeatureRelationTypes < ActiveRecord::Migration
  def self.up
    FeatureRelationType.destroy_all
    
    types = [
      {:role => '', :type => {:is_symmetric => false, :label => 'is a parent of', :asymmetric_label => 'is subordinate to'}},
      {:role => :adjacent, :type => {:is_symmetric => true, :label => 'is adjacent to'}},
      {:role => :intersects, :type => {:is_symmetric => true, :label => 'intersects with'}},
      {:role => :instantiation, :type => {:is_symmetric => false, :label => 'is an instantiation of', :asymmetric_label => 'has as an instantiation of it'}},
      {:role => :near, :type => {:is_symmetric => true, :label => 'is near'}},
      {:role => :located, :type => {:is_symmetric => false, :label => 'is contained by', :asymmetric_label => 'contains'}},
      {:role => :part, :type => {:is_symmetric => false, :label => 'is part of', :asymmetric_label => 'has as part of it'}},
      {:role => :related, :type => {:is_symmetric => true, :label => 'is related to'}},
      {:role => :admin_seat, :type => {:is_symmetric => false, :label => 'is administrative seat of', :asymmetric_label => 'has as an administrative seat'}},
      {:role => :admin_headquarters, :type => {:is_symmetric => false, :label => 'is administrative headquarters of', :asymmetric_label => 'has as an administrative headquarters'}},
      {:role => :conflict, :type => {:is_symmetric => true, :label => 'is in conflict with'}},
      {:role => :affiliated, :type => {:is_symmetric => true, :label => 'is affiliated with'}}
    ]
    
    types.each do |element|
      old_role = element[:role]
      type = element[:type]
      type[:asymmetric_label] = type[:label] if type[:is_symmetric]
      created_type = FeatureRelationType.create(type)
      # Do these values need to be sanitized?
      conditions = old_role == '' ? "role IS NULL OR role = ''" : "role = '#{old_role}'"
      FeatureRelation.update_all("feature_relation_type_id = #{created_type.id}", conditions)
    end
  end

  def self.down
    FeatureRelation.update_all("feature_relation_type_id = NULL")
    FeatureRelationType.destroy_all
  end
end