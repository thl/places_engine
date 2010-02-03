require File.dirname(__FILE__) + '/../test_helper'

class FeatureTest < Test::Unit::TestCase
  
  # We need to load all of the related data
  fixtures :features, :feature_names, :citations, :info_sources, :feature_relations
  
  def setup
    @f0 = Feature.find_by_fid(0)
    @f1 = Feature.find_by_fid(1)
    @f2 = Feature.find_by_fid(2)
  end
  
  def test_f2_feature_names_and_their_through_features
    assert_equal 2, @f2.names.size
    # puts "f2 name size: #{@f2.names.map(&:name)}"
    assert_equal 'lha sa', @f2.names.find_by_name('ལྷ་ས།').children.first.name
  end
  
  def test_f0_feature_name
    assert_equal Array, @f0.names.class
    assert @f0.names.include?( FeatureName.find_by_name('ཀྲུང་གོ') )
  end
  
  def test_f0_feature_citations
    assert_equal Array, @f0.citations.class
    assert @f0.citations.size == 1
  end
  
  # Just make sure we have the associations setup correctly
  def test_feature_relations_exists
    assert_equal Array, @f0.parent_relations.class
    assert_equal Array, @f0.parents.class
    
    assert_equal Array, @f0.child_relations.class
    assert_equal Array, @f0.children.class
    
    assert_equal Array, @f1.parent_relations.class
    assert_equal Array, @f1.parents.class
    
    assert_equal Array, @f1.child_relations.class
    assert_equal Array, @f1.children.class
    
    assert_equal Array, @f2.parent_relations.class
    assert_equal Array, @f2.parents.class
    
    assert_equal Array, @f2.child_relations.class
    assert_equal Array, @f2.children.class
  end
  
  # FeatureRelations
  def test_f0_relations
    # f0 relates itself to nothing
    assert_equal 0, @f0.parent_relations.size
    
    # f1 relates itself to f0
    assert_equal 1, @f0.child_relations.size
    # make sure it's a FeatureRelation
    assert_equal FeatureRelation, @f0.child_relations.first.class
  end
  
  def test_relation_child_and_parents
    # the relation's "parent" is f0
    assert_equal @f0, @f0.child_relations.first.parent_node
    
    assert_equal nil, @f0.parent_relations.first
  end
  
  # related Features
  def test_f0_children_and_parents
    # f0 relates itself to nothing
    assert_equal 0, @f0.parents.size
    
    # f1 relates itself to f0
    assert_equal 1, @f0.children.size
    # make sure it's a Feature
    assert_equal Feature, @f0.children.first.class
    
    # f0 is related to f1 from f1
    assert_equal @f1, @f0.children.first
    
    # f1 is relating to f0
    assert_equal @f0, @f1.parents.first
    
    # f1 is related to f2 from f2
    assert_equal @f1, @f2.parents.first
    
    # f2 is relating to f1
    assert_equal @f1, @f2.parents.first
    
  end
  
  def test_f0_is_not_a_part_of_any_other_features
    assert_equal 0, @f0.parents.size
  end
  
  def test_f0_has_f1_pointing_to_it_as_a_partof
    # reverse the relationship direction bypassing in true as the 2nd argument
    assert_equal 1, @f0.children.first.fid
  end
  
  def test_find_i_am_a_part_of
    assert_equal 0, @f0.parents.size
    assert_equal 1, @f1.children.size
  end
  
  def test_find_parts_of_me
    assert_equal 1, @f0.children.size
    # Test f2 here and make sure there are not partsof pointing to f2
    assert_equal 0, @f2.children.size
  end
  
  def test_search_method
    # simple filter search
    assert_equal 1, Feature.search('China', :page=>1).size
    # search on the word "private" with is_public==false
    assert_equal 1, Feature.search('private', :page=>1, :conditions=>['features.is_public = ?', 0]).size
    # search on the word "private" with is_public==true
    assert_equal 0, Feature.search('private', :page=>1, :conditions=>['features.is_public = ?', 1]).size
  end
  
  #
  # Test the contextual_search method
  # Ensure that the context Feature is returned as the first element
  # an the second the results.
  #
  def test_successful_contextual_search
    # Besure to build the hierachy first (builds ancestor_ids columns)
    [FeatureRelation, Feature, FeatureName, FeatureNameRelation].map(&:reset_ancestor_ids)
    context_id=name_to_id('node_1_1_2_1')
    context_feature, results = Feature.contextual_search(context_id, 'private', :page=>1)
    assert_equal context_feature.id, context_id
    assert_equal 1, results.size
  end
  
  #
  # Test that searching for a feature using "private" under the "china" feature
  # returns no results.
  #
  def test_failed_contextual_search
    context_feature, results = Feature.contextual_search(name_to_id('china'), 'private', :page=>1)
    assert_equal Feature, context_feature.class
    assert_equal 0, results.size
  end
  
end