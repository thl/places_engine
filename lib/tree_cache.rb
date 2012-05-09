class TreeCache
  CACHE_DIR = "#{ActionController::Base.cache_store.cache_path}/views/tree/"
  CACHE_FILE_PREFIX = 'node_id_'
  CACHE_FILE_SUFFIX = '.cache'
  TIME_FORMAT = '%.2f'
  
  def self.reheat(fid, perspective_code, view_code)
    perspectives = perspective_code.blank? ? nil : [Perspective.get_by_code(perspective_code)]
    views = view_code.blank? ? nil : [View.get_by_code(view_code)]
    features = fid.blank? ? Feature.roots.reject(&:is_blank?).sort{|a, b| a.fid <=> b.fid} : [Feature.get_by_fid(fid)]
    self.generate(features, perspectives, views)
  end
  
  def self.cache_dir(f, p, v)
    "#{CACHE_DIR}#{p}/#{v}/#{CACHE_FILE_PREFIX}#{f.id}#{CACHE_FILE_SUFFIX}"
  end
  
  def self.already_cached(f, perspective_ids, view_ids)
    view_ids.all? { |v| perspective_ids.all? { |p| !Dir[cache_dir(f, p, v)].empty? } }
  end
  
  def self.extended_open(url)
    # open(url) times out in one minute!
    site_url = URI.parse(url)
    http = Net::HTTP.new(site_url.host, site_url.port)
    http.read_timeout=360 # timeout in seconds. Yeah, that's 6 minutes.
    req = Net::HTTP::Get.new(site_url.request_uri)
    res = http.start {|web| web.request(req)}
    res.body
  end
  
  def self.generate(features, perspectives = nil, views = nil)
    perspectives = Perspective.where(:is_public => true) if perspectives.blank?
    views = View.get_all if views.blank?
    view_ids = views.collect(&:id)
    perspective_ids = perspectives.collect(&:id)
    current_level = features
    level_number = 0
    done = []
    cached_time = 0
    cached_items = 0
    start = Time.now
    begin
      level_start = Time.now
      puts "#{level_start}: Starting level #{level_number} with #{current_level.size} features."
      next_level = []
      current_level.each do |f|
        next if f.nil? || done.include?(f.fid)
        done << f.fid
        next_level += f.child_relations.where(:perspective_id => perspective_ids).collect(&:child_node)
        next if already_cached(f, perspective_ids, view_ids)
        related_perspectives = f.parent_relations.select('DISTINCT perspective_id').where(:perspective_id => perspective_ids).collect(&:perspective_id)
        next if related_perspectives.empty?
        view_ids.each do |v|
          related_perspectives.each do |p|
            next if !Dir[cache_dir(f, p, v)].empty?
            url = "#{APP_URI}/features/node_tree_expanded/#{f.id}?view_id=#{v}&perspective_id=#{p}"
            begin
              cache_start = Time.now
              extended_open(url)
              cached_items += 1
              cached_time += Time.now - cache_start
              puts "L#{level_number}: F#{f.fid} (perspective: #{p}, view: #{v}) cached (avg: #{TIME_FORMAT % (cached_time/cached_items)} secs/feature)."
            rescue => e
              puts "F#{f.fid}: #{url} could not be fetched."
            rescue Timeout::Error => e
              puts "F#{f.fid}: #{url} timed out."
            end
          end
        end
      end
      stop = Time.now
      puts "#{stop}: Done level #{level_number} taking #{TIME_FORMAT % (stop-level_start)} secs for #{current_level.size} features. #{done.size} features so far (avg: #{TIME_FORMAT % ((stop-start)/done.size)} secs/feature)."
      current_level = next_level.sort{|a, b| a.fid <=> b.fid}
      level_number += 1
    end while !current_level.empty?
  end
end