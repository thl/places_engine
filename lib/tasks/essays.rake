namespace :essays do
  desc "Turn small descriptions into captions and summaries"
  task cleanup: :environment do
    description_ids = []
    default_author_id = ENV['DEFAULT_AUTHOR_ID']
    language_id = Language.get_by_code('eng').id
    if default_author_id.blank?
      puts "Syntax: rake essays:cleanup DEFAULT_AUTHOR_ID=author_id"
    else
      Description.order('id').each do |d|
        size = d.content.strip_tags.size
        author = d.authors.first
        author_id = author.nil? ? default_author_id : author.id
        if size<=140
          c = Caption.create language_id: language_id, content: d.content, author_id: author_id, feature_id: d.feature_id
          if !c.nil?
            description_ids << d.id
            d.destroy
          end
        elsif size<=750
          s = Summary.create language_id: language_id, content: d.content, author_id: author_id, feature_id: d.feature_id
          if !s.nil?
            description_ids << d.id
            d.destroy
          end
        end
      end
      puts "Deleted descriptions: #{description_ids.join(', ')}"
    end
  end
end
