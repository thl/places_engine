
class TreeCache
    
  @@cache_dir = "#{ActionController::Base.cache_store.cache_path}/views/tree/"
  @@cache_file_prefix = 'node_id_'
  @@cache_file_suffix = '.cache'
  
  def self.reheat( fid )
    if fid.blank?
      Feature.roots.each{ |n| self.generate(n.fid) }
    else
      self.generate(fid)
    end

  end
  
  def self.generate( fid )
    n = Feature.get_by_fid(fid)
    unless n.nil?
      views = View.all.collect{|v| v.id}
      ds = [n.id]
      desc = n.descendants
      ds += desc.collect{ |d| d.id } unless desc.empty? or desc.nil?
      ds.each do |d|
        f = [Feature.find(d)].flatten
        f.each do |i|
          perspectives = i.relations.collect(&:perspective_id).uniq 
          unless perspectives.empty?
            views.each do |v|
              perspectives.each do |p|
                dir = "#{@@cache_dir}#{p}/#{v}/#{@@cache_file_prefix}#{d}#{@@cache_file_suffix}"
                if Dir[dir].empty?
                  s = "#{APP_URI}/features/node_tree_expanded/#{d}?view_id=#{v}&perspective_id=#{p}"
                  puts s
                  open(s)
                  puts "created: #{dir}"
                else
                  #puts "cache file already existed for id: #{d} – perspective: #{p} – view: #{v}"
                end
              end
            end
          end
        end
      end
    end
  end
  
end