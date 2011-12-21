
class TreeCache
    
  @@cache_dir = "#{ActionController::Base.cache_store.cache_path}/views/tree/"
  @@cache_file_prefix = 'node_id_'
  @@cache_file_suffix = '.cache'
  
  def self.reheat(fid, perspective_code, view_code)
    perspectives = perspective_code.blank? ? nil : [Perspective.get_by_code(perspective_code)]
    views = view_code.blank? ? nil : [View.get_by_code(view_code)]
    fids = fid.blank? ? Feature.roots.collect(&:fid) : [fid]
    fids.each{ |f| self.generate(f, perspectives, views) }
  end
  
  def self.cache_dir(f, p, v)
    "#{@@cache_dir}#{p}/#{v}/#{@@cache_file_prefix}#{f.id}#{@@cache_file_suffix}"
  end
  
  def self.already_cached(f, perspective_ids, view_ids)
    view_ids.all? { |v| perspective_ids.all? { |p| !Dir[cache_dir(f, p, v)].empty? } }
  end
  
  def self.generate(fid, perspectives = nil, views = nil)
    perspectives = Perspective.all(:conditions => {:is_public => true}) if perspectives.blank?
    views = View.get_all if views.blank?
    feature = Feature.get_by_fid(fid)
    return if feature.nil?
    view_ids = views.collect(&:id)
    perspective_ids = perspectives.collect(&:id)
    ([feature] + feature.descendants).each do |f|
      # next if already_cached(f, perspective_ids, view_ids)
      related_perspectives = f.parent_relations.all(:select => 'DISTINCT perspective_id', :conditions => {:perspective_id => perspective_ids}).collect(&:perspective_id)
      next if related_perspectives.empty?
      view_ids.each do |v|
        related_perspectives.each do |p|
          dir = cache_dir(f, p, v)
          next if !Dir[dir].empty?
          begin
            open("#{APP_URI}/features/node_tree_expanded/#{f.id}?view_id=#{v}&perspective_id=#{p}")
            puts "created: #{dir}"
          rescue
            puts "#{APP_URI}/features/node_tree_expanded/#{f.id}?view_id=#{v}&perspective_id=#{p} timed out."
          end
        end
      end
      puts "#{f.fid} cached."
    end
  end
end