require 'import/importation'

class EssayImport < Importation
  def initialize
  end
  
  def import_with_book_reader(source, options)
    reader_url = options[:reader_url] || "#{ThlSite.get_url}/global/php/book_reader.php?url="
    public_url = options[:public_url] || ""
    essay_prefix = options[:prefix] || ""
    view_code = !options[:view_code].blank? ? options[:view_code].to_s : "roman.popular"
    dry_run = options.has_key?(:dry_run) ? options[:dry_run] : false
    limit = options[:limit].blank? ? false : options[:limit].to_i
    
    created_descriptions_filename = "tmp/created_descriptions.csv"
    created_descriptions_filename = Rails.root.join(created_descriptions_filename).to_s
    
    fids_not_found = []
    essays_not_found = []
    created_descriptions = []
    errors = []
    rows_done = 0
    
    view = View.get_by_code(view_code)
    if view.nil?
      puts "Sorry, a view with the specified code (\"#{view_code}\") couldn't be found.\n"
      return
    end
    
    if ['pri.tib.sec.roman', 'pri.tib.sec.chi'].include?(view_code)
      introduction_text = "[name]"
    else
      introduction_text = "[name] Introduction"
    end
    self.do_csv_import(source) do
      break if limit && rows_done >= limit
      essay_id = self.fields.delete('descriptions.eid')
      fid = self.fields.delete('features.fid')
      # columns
      feature = Feature.get_by_fid(fid)
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
        if content.blank?
          essays_not_found << essay_id
        else
          if dry_run
            puts "\n\n\n#{content_url}:\n#{content[0..1000]}\n"            
          else
            source_url = "#{public_url}#{essay_prefix}#{essay_id}"
            attributes = {:content => content, :is_primary => false, :title => title}
            descriptions = feature.descriptions
            description = descriptions.where(:source_url => source_url).first
            if description.nil?
              description = descriptions.create(attributes.merge({:source_url => source_url}))
            else
              description.update_attributes(attributes)
            end
            prefix = 'descriptions'
            0.upto(2) do |i|
              author_key = i>0 ? "#{prefix}.author.#{i}.fullname" : "#{prefix}.author.fullname"
              author_name = self.fields.delete(author_key)
              if !author_name.blank?
                author = AuthenticatedSystem::Person.find_by_fullname(author_name)
                if author.nil?
                  puts "Author #{author_name} not found!"
                else
                  description.authors << author if !description.author_ids.include?(author.id)
                end
              end
            end
            self.add_date(prefix, description)
            created_descriptions << [feature.fid, description.id]
          end
        end
      end
      rows_done += 1
      if self.fields.empty?
        puts "#{Time.now}: #{essay_id} processed."
      else
        puts "#{Time.now}: #{essay_id}: the following fields have been ignored: #{self.fields.keys.join(', ')}"
      end
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
  
  def get_http_content(url)
    uri = URI.parse(URI.encode(url));
    
    requested_host = uri.host
    headers = {}
    
    # Check to see if the request is for a URL on thlib.org or a subdomain; if so, and if
    # this is being run on sds[3-8], make the appropriate changes to headers and uri.host
    if requested_host =~ /thlib.org/
      server_host = Socket.gethostname.downcase
      if server_host =~ /sds.+\.itc\.virginia\.edu/
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
  
  def extract_content(content)
    content.sub!(/<!DOCTYPE.*?>[\s]*/im, '')
    content.sub!(/<div.*?class=.shell.*?>[\s]*/im, '')
    content.sub!(/[\s]*<!--Debugging info:.*?-->[\s]*/im, '')
    content.sub!(/<\/div>(?!.*<\/div>.*)/im, '')
    content.strip
  end
end