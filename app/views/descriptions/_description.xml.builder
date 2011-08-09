xml.description do
  xml.id(description.id, :type => 'integer')
  xml.title(description.title)
  xml.content(description.content)
  xml.source_url(description.source_url)
  xml.is_primary(description.is_primary, :type => 'boolean')
  xml.created_at(description.created_at, :type => 'timestamp')
  xml.updated_at(description.updated_at, :type => 'timestamp')
  description.authors.each { |author| xml.author(:id => author.id, :fullname => author.fullname) }
end