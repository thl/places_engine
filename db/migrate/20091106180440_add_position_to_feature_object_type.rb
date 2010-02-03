class AddPositionToFeatureObjectType < ActiveRecord::Migration
  def self.up
    add_column :feature_object_types, :position, :integer, :default => 0, :null => false
    FeatureObjectType.update_all("position = 0")
    
    # The following code should set the proper position values for all feature object types, but it threw an error
    # ("Failed with 404 Not Found") after a long time running, and I wasn't about to debug it.
    # Find distinct features that have object types 
    feature_ids = FeatureObjectType.find(:all, :select => 'DISTINCT feature_id').collect{|fot| fot.feature_id}
    # Processing all of these features at once is tough on memory, so we'll process them in blocks of 100
    total = feature_ids.length
    limit = [ 100, total ].min
    0.step(total-1, limit) do |offset|
      Feature.find_all_by_id(feature_ids, :limit => limit, :offset => offset).each do |f|
        pos = 1
        f.feature_object_types.each do |fot|
          fot.update_attribute(:position, pos)
          pos += 1
        end
      end
    end
  end

  def self.down
    remove_column :feature_object_types, :position
  end
end