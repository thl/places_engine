
class TreeCache
    
  @@cache_dir = "#{ActionController::Base.cache_store.cache_path}/views/tree/"
  @@cache_file_prefix = 'node_id_'
  @@cache_file_suffix = '.cache'
  
  def self.reheat( root_node )
    return if root_node.nil?

    if root_node == 0
      Feature.roots.each{ |n| self.generate(n.id) }
    else
      self.generate(root_node)
    end

  end
  
  def self.generate( root_node )
    n = Feature.find_by_id(root_node)
    unless n.nil?
      views = View.all.collect{|v| v.id}
      ds = [root_node]
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
                  open("#{APP_URI}/features/node_tree_expanded/#{d}?view_id=#{v}&perspective_id=#{p}")
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