class DataImport
  
  require "ftools"
  
  def self.cleanup
    ext='.rb'
    Dir['app/models/*'].each do |n|
      next if n[-3,3]!=ext
      name = File.basename(n, ext)
      Kernel.const_get(name.classify).find(:all).map(&:destroy)
    end
    
    #Feature.find(:all).each {|f| f.destroy}
    #FeatureObjectType.find(:all).each {|f| f.destroy}
    #FeatureRelation.find(:all).each {|f| f.destroy}
    #FeatureName.find(:all).each {|f| f.destroy}
    #FeatureNameRelation.find(:all).each {|f| f.destroy}
    #Timespan.find(:all).each {|f| f.destroy}
    #ObjectType.find(:all).each {|ft| ft.destroy}
  end
  
  def self.load_thesaurus
    # I think we aren't using the thesaurus anymore, but just in case, I'm leaving this in. 
    #fd.fetch_thesauri.each do |feature_type|
    #  feature_type.save
    #end
    
    #puts "Vocabulary.find(:all).size = #{Vocabulary.find(:all).size}"
  end
  
  def self.all(datasource)
    #self.cleanup
    fd = FeatureData.new( datasource )
    fd.fetch_feature_docs.each do |feature_doc|
      puts "processing #{feature_doc}"
      fd.parse_document(feature_doc)
      `mv #{feature_doc} #{feature_doc + '.done'}`
    end
  end
  
  def self.minimum(url)
    
  end
  
end