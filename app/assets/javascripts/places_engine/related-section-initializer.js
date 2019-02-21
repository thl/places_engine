$(function() {
  var relatedSolrUtils = kmapsSolrUtils.init({
    termIndex: $('#related_js_data').data('termIndex'),
    assetIndex: $('#related_js_data').data('assetIndex'),
    featureId: $('#related_js_data').data('featureId'),
    domain: $('#related_js_data').data('domain'),
    perspective: $('#related_js_data').data('perspective'),
    tree: $('#related_js_data').data('tree'), //places
  });
  var summaryLoaded = false;
  var collapsibleApplied = false;
  var popupsSet = false;
  var columnizedApplied = false;
  $('#summary-tab-link[data-toggle="tab"]').on('shown.bs.tab', function (e) {
  //Code for Summary
  if(!summaryLoaded){
    $("#relation_details .tab-content-loading").show();
    relatedSolrUtils.getPlacesSummaryElements().then(function(result){
      var feature_label = $($('#related_js_data').data('featureLabel'))[0].innerText;
      var feature_path = $('#related_js_data').data('featuresPath');
      relatedSolrUtils.addPlacesSummaryItems(feature_label,feature_path,'parent',result);
      relatedSolrUtils.addPlacesSummaryItems(feature_label,feature_path,'child',result);
      relatedSolrUtils.addPlacesSummaryItems(feature_label,feature_path,'other',result);

      if(!collapsibleApplied){
        $('ul.collapsibleList').kmapsCollapsibleList();
        collapsibleApplied = true;
      }
      if(!columnizedApplied){
      // Functionality for columnizer
        $('.kmaps-list-columns:not(.subjects-in-places):not(.already_columnized)').addClass('already_columnized').columnize({
          width: 330,
          lastNeverTallest : true,
          buildOnce: true,
        });
        //reapply kmapsCollapsibleList if the element has lost the kmapscollapsibleList plugin
        //columnizer seems to cause a bug when the clone doesn't keep the events previously assigned
        $('ul.collapsibleList').each(function(){
          if(!($(this).data('plugin_kmapsCollapsibleList'))) $(this).kmapsCollapsibleList();
        });
        columnizedApplied = true;
      }
      if(!popupsSet){
        jQuery('#relation_details .popover-kmaps').kmapsPopup({
          featuresPath: $('#related_js_data').data('featuresPath'),
          domain: $('#related_js_data').data('domain'),
          featureId:  "",
          mandalaURL: $('#related_js_data').data('mandalaPath'),
          solrUtils: relatedSolrUtils,
          language: $('#related_js_data').data('language'),
        });
        popupsSet = true;
       }
      $("#relation_details .tab-content-loading").hide();
      $("#relation_details .collapsible_btns_container").show();
      summaryLoaded = true;
    });
  }
  }); // END - Summary Tab on show action

  $(".collapsible_expand_all").on("click",function(e){
   $(".collapsible_collapse_all").removeClass("collapsible_all_btn_selected");
    if (!$(".collapsible_expand_all").hasClass("collapsible_all_btn_selected")) {
     $(".collapsible_expand_all").addClass("collapsible_all_btn_selected");
    }
    $('ul.collapsibleList').each(function(){
      $(this).kmapsCollapsibleList('expandAll',this);
    });
  });
  $(".collapsible_collapse_all").on("click",function(e){
   $(".collapsible_expand_all").removeClass("collapsible_all_btn_selected");
    if (!$(".collapsible_collapse_all").hasClass("collapsible_all_btn_selected")) {
     $(".collapsible_collapse_all").addClass("collapsible_all_btn_selected");
    }
    $('ul.collapsibleList').each(function(){
      $(this).kmapsCollapsibleList('collapseAll',this);
    });
  });

  $("#relation_tree_container").kmapsRelationsTree({
    featureId: $('#related_js_data').data('featureFid'),
    termIndex: $('#related_js_data').data('termIndex'),
    assetIndex: $('#related_js_data').data('assetIndex'),
    perspective: $('#related_js_data').data('perspective'),
    tree: $('#related_js_data').data('tree'), //places
    domain: $('#related_js_data').data('domain'), //places
    descendants: true,
    directAncestors: true,
    descendantsFullDetail: true,
    sortBy: "related_"+$('#related_js_data').data('domain')+"_header_s+ASC",
    displayPopup: true,
    solrUtils: relatedSolrUtils,
    language: $('#related_js_data').data('language'),
    featuresPath: $('#menu_js_data').data('featuresPath'),
  });
});
