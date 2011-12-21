
class TreeCache
    
  @@cache_dir = "#{ActionController::Base.cache_store.cache_path}/views/tree/"
  @@cache_file_prefix = 'node_id_'
  @@cache_file_suffix = '.cache'
  
  def self.reheat(fid, perspective_code, view_code)
    perspectives = perspective_code.blank? ? nil : [Perspective.get_by_code(perspective_code)]
    views = view_code.blank? ? nil : [View.get_by_code(view_code)]
    features = fid.blank? ? Feature.roots.reject(&:is_blank?).sort{|a, b| a.fid <=> b.fid} : [Feature.get_by_fid(fid)]
    self.generate(features, perspectives, views)
  end
  
  def self.cache_dir(f, p, v)
    "#{@@cache_dir}#{p}/#{v}/#{@@cache_file_prefix}#{f.id}#{@@cache_file_suffix}"
  end
  
  def self.already_cached(f, perspective_ids, view_ids)
    view_ids.all? { |v| perspective_ids.all? { |p| !Dir[cache_dir(f, p, v)].empty? } }
  end
  
  def self.generate(features, perspectives = nil, views = nil)
    perspectives = Perspective.all(:conditions => {:is_public => true}) if perspectives.blank?
    views = View.get_all if views.blank?
    view_ids = views.collect(&:id)
    perspective_ids = perspectives.collect(&:id)
    current_level = features
    done = []
    begin
      next_level = []
      current_level.each do |f|
        next if f.nil? || done.include?(f.fid)
        done << f.fid
        related_perspectives = f.parent_relations.all(:select => 'DISTINCT perspective_id', :conditions => {:perspective_id => perspective_ids}).collect(&:perspective_id)
        next_level += f.child_relations.all(:conditions => {:perspective_id => perspective_ids}).collect(&:child_node)
        next if related_perspectives.empty?
        view_ids.each do |v|
          related_perspectives.each do |p|
            dir = cache_dir(f, p, v)
            next if !Dir[dir].empty?
            url = "#{APP_URI}/features/node_tree_expanded/#{f.id}?view_id=#{v}&perspective_id=#{p}"
            begin
              open(url)
              puts "created: #{dir}"
            rescue => e
              puts "#{url} could not be fetched."
            rescue Timeout::Error => e
              puts "#{url} timed out."
            end
          end
        end
        puts "#{f.fid} cached."
      end
      current_level = next_level.sort{|a, b| a.fid <=> b.fid}
    end while !current_level.empty?
  end
end