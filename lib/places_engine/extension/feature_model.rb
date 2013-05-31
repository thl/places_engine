module PlacesEngine
  module Extension
    module FeatureModel
      extend ActiveSupport::Concern

      included do
        has_many :altitudes, :dependent => :destroy
        has_many :contestations, :dependent => :destroy
        has_many :shapes, :foreign_key => 'fid', :primary_key => 'fid'
      end

      def has_shapes?(options = {})
        use_log_in_status = options.has_key? :logged_in?
        shapes = self.shapes
        return use_log_in_status ? (options[:logged_in?] ? !shapes.empty? : shapes.any?(&:is_public?)) : !shapes.empty?
      end

      # Options take :logged_in?
      def closest_feature_with_shapes(options = {})
        feature_id = Rails.cache.fetch("features/#{self.fid}/closest_feature_with_shapes", :expires_in => 1.hour) do
          break self.id if self.has_shapes?(options)
          # check if geographical parent has shapes (township)
          geo_rel = Perspective.get_by_code('geo.rel')
          first_township_relation = self.all_parent_relations.where(:perspective_id => geo_rel.id).first
          if !first_township_relation.nil?
            node = first_township_relation.parent_node
            break node.id if node.has_shapes?(options)
          end
          # check if county parent has shapes (county)
          pol_admin = Perspective.get_by_code('pol.admin.hier')
          first_county_relation = self.all_parent_relations.where(:perspective_id => pol_admin.id).first
          if !first_county_relation.nil?
            node = first_county_relation.parent_node
            break node.id if node.has_shapes?(options)
          end
          nil
        end
        feature_id.nil? ? nil : Feature.find(feature_id)
      end

      def update_shape_positions
        shapes.reject{|shape| shape.position != 0}.inject(shapes.max{|a,b|a.position <=> b.position}.position+1) do |pos, shape|
          shape.update_attribute(:position, pos)
          pos + 1
        end
      end

      def kmap_path(type = nil)
        a = ['places', self.fid]
        a << type if !type.nil?
        a.join('/')
      end

      module ClassMethods
        def find_by_shape(shape)
          Feature.get_by_fid(shape.fid)
        end
      end
    end
  end
end