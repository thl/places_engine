require_relative '../test_helper'

class FeaturesTest < ActionController::IntegrationTest
  fixtures :citations, :feature_geo_codes, :feature_name_relations, :feature_names, :feature_object_types, :feature_relations, :features, :info_sources, :simple_props, :timespans, :xml_documents
  
  def test_should_list_features
    get '/features'
    assert_response :success
    assert_template 'features/index'
  end
  
  def test_feature_url
    get '/feature', :feature_id => features(:china).fid
    # assert_response :success
    # assert_template 'features/show'
  end
  
end
