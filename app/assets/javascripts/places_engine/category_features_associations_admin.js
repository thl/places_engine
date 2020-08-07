$(document).ready(function() {
  var categoryId = $('#category_features_association_js_data').data('featureId');
  if (categoryId) {
    categoryId = $('#category_features_association_js_data').data('tree') + "-" + categoryId;
  } else {
    categoryId = "";
  }
  var featureTypeSolrUtils = kmapsSolrUtils.init({
    termIndex: $('#category_features_association_js_data').data('termIndex'),
    assetIndex: $('#category_features_association_js_data').data('assetIndex'),
    featureId: $('#category_features_association_js_data').data('featureId'),
    featureId: categoryId,
    domain: $('#category_features_association_js_data').data('domain'),
    perspective: $('#category_features_association_js_data').data('perspective'),
    tree: $('#category_features_association_js_data').data('tree'), //places
    featuresPath: $('#category_features_association_js_data').data('featuresPath'),
  });
  $("#subject_tree_container").kmapsRelationsTree({
    featureId: categoryId,
    featuresPath: $('#category_features_association_js_data').data('featuresPath'),
    termIndex: $('#category_features_association_js_data').data('termIndex'),
    assetIndex: $('#category_features_association_js_data').data('assetIndex'),
    perspective: $('#category_features_association_js_data').data('perspective'),
    tree: $('#category_features_association_js_data').data('tree'), //places
    domain: $('#category_features_association_js_data').data('domain'), //places
    extraFields: ["header", "level_gen_i"],
    descendants: true,
    directAncestors: false,
    hideAncestors: false,
    descendantsFullDetail: false,
    displayPopup: false,
    initialScrollToActive: true,
    solrUtils: featureTypeSolrUtils,
    nodeMarkerPredicates: [{operation: 'markAll', mark: 'customActionNode'}], //A predicate is: {field:, value:, operation: 'eq', mark: 'nonInteractive'}
  });
  if($('#category_features_association_js_data').data('featureId')){
    $("#subject_name").html("Selected Feature Type: "+ $('#category_features_association_js_data').data('featureTypeName'));
  }
  $("#subject_tree_container").on("fancytreeactivate", function(event, data){
    var level = data.node.getLevel();
    $("#category_feature_category_id").val(data.node.key.replace($('#category_features_association_js_data').data('domain')+'-',''));
    $("#subject_name").html("Selected Feature Type: "+ data.node.title);
    if (level == 1) {
      if ($("#category_feature_show_parent").prop('checked') == true) {
        $("#category_feature_show_parent").trigger('click');
      }
      $("#category_feature_show_parent").attr("disabled", true);
      if ($("#category_feature_show_root").prop('checked') == true) {
        $("#category_feature_show_root").trigger('click');
      }
      $("#category_feature_show_root").attr("disabled", true);
    } else {
      $("#category_feature_show_parent").attr("disabled", false);
      $("#category_feature_show_root").attr("disabled", false);
    }
  });
});
