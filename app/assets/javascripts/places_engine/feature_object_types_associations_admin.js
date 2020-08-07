$(document).ready(function() {
  var categoryId = "subjects-20";
  var featureTypeSolrUtils = kmapsSolrUtils.init({
    termIndex: $('#feature_object_types_association_js_data').data('termIndex'),
    assetIndex: $('#feature_object_types_association_js_data').data('assetIndex'),
    featureId: categoryId,
    domain: $('#feature_object_types_association_js_data').data('domain'),
    perspective: $('#feature_object_types_association_js_data').data('perspective'),
    tree: $('#feature_object_types_association_js_data').data('tree'), //places
    featuresPath: $('#feature_object_types_association_js_data').data('featuresPath'),
  });
  $("#subject_tree_container").kmapsRelationsTree({
    featureId: categoryId,
    featuresPath: $('#feature_object_types_association_js_data').data('featuresPath'),
    termIndex: $('#feature_object_types_association_js_data').data('termIndex'),
    assetIndex: $('#feature_object_types_association_js_data').data('assetIndex'),
    perspective: $('#feature_object_types_association_js_data').data('perspective'),
    tree: $('#feature_object_types_association_js_data').data('tree'), //places
    domain: $('#feature_object_types_association_js_data').data('domain'), //places
    extraFields: ["header"],
    descendants: true,
    directAncestors: true,
    descendantsFullDetail: false,
    displayPopup: false,
    initialScrollToActive: true,
    solrUtils: featureTypeSolrUtils,
    nodeMarkerPredicates: [{operation: 'markAll', mark: 'customActionNode'}], //A predicate is: {field:, value:, operation: 'eq', mark: 'nonInteractive'}
  });
  function expandTree(tree, ancestors) {
    if (ancestors) {
      var ancestor = ancestors.shift();
      var node = tree.getNodeByKey("subjects-"+ancestor.id);
      var promise = node.setExpanded();
      promise.then(function(value){
        if (ancestors.length >= 1) {
          expandTree(tree,ancestors);
        } else {
          tree.activateKey("subjects-"+ancestor.id);
        }

      });
    }
  }
  $("#subject_tree_container").on("fancytreeinit", function() {
    var categoryId = $('#feature_object_types_association_js_data').data('featureId');
    if (categoryId) {
      categoryId = $('#feature_object_types_association_js_data').data('tree') + "-" + categoryId;
      var ancestors = $('#feature_object_types_association_js_data').data('ancestors');
      var tree = $.ui.fancytree.getTree("#subject_tree_container");
      expandTree(tree, ancestors);
    }
  });
  if($('#feature_object_types_association_js_data').data('featureId')){
    $("#subject_name").html("Selected Feature Type: "+ $('#feature_object_types_association_js_data').data('featureTypeName'));
  }
  $("#subject_tree_container").on("fancytreeactivate", function(event, data){
    var level = data.node.getLevel();
    $("#feature_object_type_category_id").val(data.node.key.replace($('#feature_object_types_association_js_data').data('domain')+'-',''));
    $("#subject_name").html("Selected Feature Type: "+ data.node.title);
    if (level == 1) {
      if ($("#feature_object_type_show_parent").prop('checked') == true) {
        $("#feature_object_type_show_parent").trigger('click');
      }
      $("#feature_object_type_show_parent").attr("disabled", true);
      if ($("#feature_object_type_show_root").prop('checked') == true) {
        $("#feature_object_type_show_root").trigger('click');
      }
      $("#feature_object_type_show_root").attr("disabled", true);
    } else {
      $("#feature_object_type_show_parent").attr("disabled", false);
      $("#feature_object_type_show_root").attr("disabled", false);
    }
  });
});
