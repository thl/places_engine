class AddPositionToShape < ActiveRecord::Migration
  def self.up
    add_column :shapes, :position, :integer, :default => 0, :null => false
    
    # Unlike the similar code for FeatureObjectType.position, this code did work locally for me.
    # Find distinct features that have shapes 
    feature_fids = Shape.select('DISTINCT fid').collect{|shape| shape.fid}
    # Processing all of these features at once is tough on memory, so we'll process them in blocks of 100
    total = feature_fids.length
    limit = [ 100, total ].min
    0.step(total-1, limit) do |offset|
      Feature.find_all_by_fid(feature_fids, :limit => limit, :offset => offset).each do |f|
        pos = 1
        f.shapes.each do |shape|
          shape.update_attribute(:position, pos)
          pos += 1
        end
      end
    end
  end

  def self.down
    remove_column :shapes, :position
  end
end
