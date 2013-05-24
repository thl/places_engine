# require 'pp'
# require 'test/unit'
# require File.expand_path(File.dirname(__FILE__) + '/../../../lib/import/feature_data.rb')
# require File.expand_path(File.dirname(__FILE__) + '/../../../lib/import/data_import.rb')
# ENV["RAILS_ENV"] = "test"
# require File.expand_path(File.dirname(__FILE__) + "/../../../config/environment")
# require 'test_help'
# require 'kmaps_engine/import/data_import'
# 
# class ImportTest < Test::Unit::TestCase
#   
#   # called before every single test
#   def setup
#     #url = "https://eos8d:password@subversion.lib.virginia.edu/repos/thdl/trunk/collections/cultgeo/gazetteer2/"
#     url = File.expand_path(File.dirname(__FILE__) + "/../../xml/")
#     
#     KmapsEngine::DataImport.minimum(url)
#     
#     @f0 = Feature.find_by_pid("f0")
#     @f1 = Feature.find_by_pid("f1")
#     @f2 = Feature.find_by_pid("f2")
#     @f899 = Feature.find_by_pid("f899")
#     @f4507 = Feature.find_by_pid("f4507")
#     @f6007 = Feature.find_by_pid("f6007")
#     
#   end
#   
#   # delete all test data
#   # called at the end of the tests
#   def teardown
#     #ObjectType.find(:all).each { |ft| ft.destroy }
#     #Feature.find(:all).each { |f| f.destroy }
#   end
#   
#   
#   def test_features_exist
#     feature = Feature.find_by_pid("f0")
#     assert_not_nil feature
#     fa = Feature.find(:all)
#     #assert fa.size == 5
#   end
#   
#   # f0 should have 4 associated FeatureNames
#   def test_f0_has_4_feature_names
#     fna = FeatureName.find_all_by_feature_id(@f0.id)
#     #assert fna.size == 4
#   end
#   
#   # related Features
#   def test_f0_related
# 
#     # f0 relates itself to nothing
#     assert_equal 0, @f0.parents.size
#     
#     # f1 relates itself to f0
#     assert_equal 1, @f0.children.size
#     # make sure it's a Feature
#     assert_equal Feature, @f0.children.first.class
#     
#     # f0 is related to f1 from f1
#     assert_equal @f1, @f0.children.first
#     
#     # f1 is relating to f0
#     assert_equal @f0, @f1.parents.first
#     
#     # f1 is related to f2 from f2
#     assert_equal @f1, @f2.parents.first
#     
#     # f2 is relating to f1
#     assert_equal @f1, @f2.parents.first
#     
#   end
#   
#   def test_find_i_am_a_part_of
#     assert_equal 0, @f0.parents.size
#     assert_equal 1, @f1.parents.size
#   end
#   
#   def test_f899_has_ancestors
#     assert_equal 1, @f899.parents.size
#     assert_equal 1, @f899.ancestors.size
#   end
#   
#   def test_object_types
#     assert @f899.object_types[0]['code'] == 'ditch'
#     
#     # This test can't pass right now because we aren't using a full data set
#     # Put it back in once we're ready to test all the data 
#     # ensure every feature has an object type
#     #eos#features = Feature.find(:all)
#     #eos#features.each do |f|
#     #eos#    assert f.object_types.size > 0, "#{f.pid} has no ObjectType"
#     #eos#end
#   end
#   
#   def test_feature_names_and_feature_name_relations
#     assert @f0.names.size == 7
#     assert @f1.names.size == 5
#     assert @f2.names.size == 5 # this tests to see if FeatureName is working recursively for transliterations of transliterations
#     assert @f6007.names.size == 6 # this tests whether altspells as well as transliterations are getting recorded 
#     
#     # If you find the FeatureName for ཀྲུང་གོ and krung go, does there exist a FeatureNameRelation tying them together such that krung go
#     # is an orthographic transliteration of ཀྲུང་གོ ? 
#     f0_tibetan = FeatureName.find_by_name('ཀྲུང་གོ')
#     f0_tib_wylie = FeatureName.find_by_name('krung go')
#     
#     f0_tibetan_transliteration = FeatureNameRelation.find_by_parent_node_id(f0_tibetan.id)
#     assert_equal f0_tibetan_transliteration.child_node_id, f0_tib_wylie.id
#     assert_equal f0_tibetan_transliteration.is_orthographic, true
#     assert_equal f0_tibetan_transliteration.orthographic_system_id, OrthographicSystem.find_by_code('tib-wylie').id
# 
#     # Test to make sure altspell is getting processed
#     f6007_fname1 = FeatureName.find_by_name('阿坝藏族羌族自治州')
#     
#     assert_equal true, f6007_fname1.timespan.is_current
#     assert_not_nil f6007_fname1.timespan
#     
#     f6007_fname2 = FeatureName.find_by_name('阿壩藏族羌族自治州')    
#     altspell = FeatureNameRelation.find(:first, :conditions=> [ "is_alt_spelling = 1"] )
#     assert_equal altspell.child_node_id, f6007_fname2.id
#     assert_equal altspell.alt_spelling_system_id, AltSpellingSystem.find_by_code('chi.traditional').id
#     assert_not_nil altspell.timespan
#     
#     # Check that is_current has been set
#     assert_equal true, altspell.timespan.is_current
#     
#     # Check that several writing_systems has been created and that f0 has names associated with them
#     latin_writing_system = WritingSystem.find_by_code('latin')
#     assert_not_nil latin_writing_system 
#     assert_not_nil @f0.names.find_by_writing_system_id(latin_writing_system.id)
#     
#     tibetan_writing_system = WritingSystem.find_by_code('tibetan')
#     assert_not_nil tibetan_writing_system
#     assert_not_nil @f0.names.find_by_writing_system_id(tibetan_writing_system.id)
#     
#     chi_simplified_writing_system = WritingSystem.find_by_code('chi_simplified')
#     assert_not_nil chi_simplified_writing_system
#     assert_not_nil @f0.names.find_by_writing_system_id(chi_simplified_writing_system.id)
#     #f0.names.find(:all, :conditions => [ "language_id = 4"])
#     
#     # Check nepalese writing systems
#     assert_equal 'nepalese', @f4507.names[0].writing_system.code
#     assert_equal 'nep_diacritics', @f4507.names[1].writing_system.code
#     assert_equal 'latin', @f4507.names[2].writing_system.code
#     
#     assert_equal 'tibetan', FeatureName.find_by_name('ཀྲུང་གོ').writing_system.code
#     assert_equal 'latin', FeatureName.find_by_name('krung go').writing_system.code
#     assert_equal 'chi_simplified', FeatureName.find_by_name('中国').writing_system.code
#     assert_equal 'latin', FeatureName.find_by_name('Zhongguo').writing_system.code
#     assert_equal 'chi_traditional', FeatureName.find_by_name('中國').writing_system.code
#     assert_equal 'latin', FeatureName.find_by_name('Zhongguo').writing_system.code
#     assert_equal 'latin', FeatureName.find_by_name('China').writing_system.code
#     
#     
#     # test some citations
#     
#     assert FeatureName.find_by_name('ཀྲུང་གོ').citations.size > 0
#     assert Citation.find(:all, :conditions => ["citable_type='FeatureNameRelation'"]).size > 0
#     assert Citation.find(:all, :conditions => ["citable_type='FeatureName'"]).size > 0
#     assert Citation.find(:all, :conditions => ["citable_type='FeatureName'"]).size > 0
#     
#     # Check for the things all objects should have 
#     features = Feature.find(:all)
#     ## add this back in after we've loaded all the features
#     #features.each do |feature|
#       #assert_not_nil feature.xml_document, "feature #{feature.pid} doesn't have an xml document"
#       #assert feature.object_types.size >=1
#     #end
#     
#     assert_not_nil @f0.feature_object_types[0].timespan
#     
#     
#     
#     ## once we're testing the entire data set, assert that each feature has at least one name
#   end
#   
# end