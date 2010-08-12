require 'csv'
class EssayImport
  
  def initialize
  end
  
  public
  
  def self.import_with_book_reader(source, options)
    reader_url = options[:reader_url] || "http://www.thlib.org/global/php/book_reader.php?url="
    public_url = options[:public_url] || ""
    essay_prefix = options[:prefix] || ""
    view_code = !options[:view_code].blank? ? options[:view_code].to_s : "roman.popular"
    dry_run = options.has_key?(:dry_run) ? options[:dry_run] : false
    limit = options[:limit].blank? ? false : options[:limit].to_i
    
    created_descriptions_filename = "tmp/created_descriptions.csv"
    created_descriptions_filename = "#{RAILS_ROOT}/#{created_descriptions_filename}"
    
    fids_not_found = []
    essays_not_found = []
    created_descriptions = []
    errors = []
    rows_done = 0
    
    view = View.find_by_code(view_code)
    if view.nil?
      puts "Sorry, a view with the specified code (\"#{view_code}\") couldn't be found.\n"
      return
    end
    
    if ['pri.tib.sec.roman', 'pri.tib.sec.chi'].include?(view_code)
      introduction_text = "[name]"
    else
      introduction_text = "[name] Introduction"
    end
    
    CSV.open(source, 'r', ",") do |columns|
      if !limit || (rows_done < limit)
        essay_id, fid = columns
        feature = Feature.find_by_fid(fid)
        feature = feature.first if feature.is_a?(Array)
        if feature.nil?
          fids_not_found << fid
        else
          content_url = "#{reader_url}#{essay_prefix}#{essay_id}"
          content = get_http_content(content_url)
          if content.match("file_get_contents")
            error = "ERROR: There was an error retrieving the content at #{content_url}!"
            errors << error
            puts error
          end
          content = extract_content(content)
          feature_name = feature.prioritized_name(view).to_s
          title = introduction_text.sub('[name]', feature_name)
          puts "\n\n\n#{content_url}:\n#{content[0..1000]}\n"
          if content.blank?
            essays_not_found << essay_id
          else
            unless dry_run
              description = Description.create({
                :feature_id => feature.id,
                :content => content,
                :is_primary => false,
                :title => title,
                :source_url => "#{public_url}#{essay_prefix}#{essay_id}"
              })
              created_descriptions << [feature.fid, description.id]
            end
          end
        end
      end
      rows_done += 1
    end
    unless created_descriptions.empty?
      created_descriptions_file = File.open(created_descriptions_filename, 'wb')
      # Add a list of all created description ids to the end for easy finds
      created_descriptions << created_descriptions.collect{|d| d[1]}
      CSV::Writer.generate(created_descriptions_file) do |csv|
        created_descriptions.each do |columns|
          csv << columns
        end
      end
    end
    puts "Number of FIDs that weren't found: #{fids_not_found.length} (FIDs: #{fids_not_found.join(', ')})\n" unless fids_not_found.empty?
    puts "Number of essays that weren't retrieved: #{essays_not_found.length} (IDs: #{essays_not_found.join(', ')})\n" unless essays_not_found.empty?
    puts "Added #{created_descriptions.length} essays to the database.\n" unless dry_run
    puts "Recorded the created essays' FIDs and IDs in:\n#{created_descriptions_filename}" unless created_descriptions.empty?
    puts "The following errors occurred:\n" + errors.join("\n") unless errors.empty?
  end
  
  def self.get_http_content(url)
    uri = URI.parse(URI.encode(url));
    
    requested_host = uri.host
    headers = {}
    
    # Check to see if the request is for a URL on thlib.org or a subdomain; if so, and if
    # this is being run on sds[3-8], make the appropriate changes to headers and uri.host
    if requested_host =~ /thlib.org/
      server_host = Socket.gethostname.downcase
      if server_host =~ /sds[3-8].itc.virginia.edu/
        headers = { 'Host' => requested_host }
        uri.host = '127.0.0.1'
      end
    end
    
    # Required for requests without paths (e.g. http://www.google.com)
    uri.path = "/" if uri.path.empty?
    
    path = uri.query.blank? ? uri.path : uri.path + '?' + uri.query 
    request = Net::HTTP::Get.new(path, headers)
    result = Net::HTTP.start(uri.host, uri.port) {|http|
      http.request(request)
    }
    
    result.body
  end
  
  def self.extract_content(content)
    content.sub!(/<!DOCTYPE.*?>[\s]*/im, '')
    content.sub!(/<div.*?class=.shell.*?>[\s]*/im, '')
    content.sub!(/[\s]*<!--Debugging info:.*?-->[\s]*/im, '')
    content.sub!(/<\/div>(?!.*<\/div>.*)/im, '')
    content.strip
  end
end