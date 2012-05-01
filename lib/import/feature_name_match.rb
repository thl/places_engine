require 'csv'
class FeatureNameMatch
  
  def initialize
  end
  
  public
  
  def self.match(source, options={})
    options[:matched_filename] ||= "tmp/matched_name_results.csv"
    options[:unmatched_filename] ||= "tmp/unmatched_name_results.csv"
    matched_filename = Rails.root(options[:matched_filename]).to_s
    unmatched_filename = Rails.root(options[:unmatched_filename]).to_s
    limit = options[:limit].blank? ? false : options[:limit].to_i
    matched_items = []
    unmatched_items = []
    rows_done = 0
    CSV.open(source, 'r', ",") do |columns|
      if !limit || (rows_done < limit)
        external_id = columns[0].strip
        name = format_name(columns[1])
        feature = find_feature_by_name(name)
        if feature.nil?
          second_name = format_name(columns[2]) unless columns[2].blank?
          feature = find_feature_by_name(second_name)
        end
        if feature.nil?
          unmatched_items << columns
        else
          matched_items.push([external_id, feature.fid])
        end
      end
      rows_done += 1
    end
    matched_file = File.open(matched_filename, 'wb')
    CSV::Writer.generate(matched_file) do |csv|
      matched_items.each do |columns|
        csv << columns
      end
    end
    matched_file.close
    unmatched_file = File.open(unmatched_filename, 'wb')
    CSV::Writer.generate(unmatched_file) do |csv|
      unmatched_items.each do |columns|
        csv << columns
      end
    end
    unmatched_file.close
    puts "- Found: #{matched_items.length}\n"
    puts "- Not found: #{unmatched_items.length}\n"
    puts "- Wrote matched results to:\n"
    puts "#{matched_filename}\n"
    puts "- Wrote unmatched results to:\n"
    puts "#{unmatched_filename}\n"
  end
  
  def self.find_feature_by_name(name)
    return nil if name.blank?
    feature = Feature.search(name, {:limit => 1, :page =>1}, {:scope => "name", :match => "exactly"})
    feature = feature.first if feature.is_a?(Array)
    feature
  end
  
  def self.format_name(name)
    return nil if name.blank?
    name.strip!
    name.gsub!(/(^\/|\/$)/, '') unless name.nil?
    name
  end
end