/**
 * This files contains the javascript that initialize the flyout search
 * capabilities, the serach flyout uses typeahead a version of the
 * plugin created by dwardjgarret for kmaps, this plugin is based on twitter's
 * typeahead.
 *
 * This code is based on the code create for the drupal site:
 * modules/custom/shanti_kmaps_admin/js/shanti_kmaps_filter.js
 */
;(function ( $, window, document, undefined ) {
  "use strict";

  var pluginName = "flyoutKmapsTypeahead",
    defaults = {
      hostname: "http://localhost:8983/solr/",
      domain: 'places',
      filters_domain: 'subjects',
      root_kmap_path: null,
      features_path: '/features/',
      menu: ".listview > .view-wrap",
      filters_class: ".kmap-search-filter",
      goto_fid_input: "#goto-fid input",
      goto_fid_button: "#goto-fid button",
      scope_filter_selector: "input[name='search[scope]']",
      match_filter_selector: "input[name='search[match]']",
      root_kmapid: null,
      ancestors: 'off', //don't display ancestry in search results
      fields: 'ancestors', //get ancestors field for use in popover
      max_terms: 30,
      min_chars: 0,
      pager: 'on',
      empty_query: '*:*',
      empty_limit: 30,
      empty_sort: 'header_ssort ASC', // sortable header field
      sort: 'header_ssort ASC', // sort even when there's a search term
      shanti_kmaps_admin_solr_filter_query: '',
      autocomplete_field: 'name_autocomplete'
    };

  // The actual plugin constructor
  function Plugin( element, options ) {
    this.element = element;

    // jQuery has an extend method that merges the
    // contents of two or more objects, storing the
    // result in the first object. The first object
    // is generally empty because we don't want to alter
    // the default options for future instances of the plugin
    this.options = $.extend( {}, defaults, options) ;

    this._defaults = defaults;
    this._name = pluginName;

    this.init();
  }

  // local "globals"
  var filtered = {};

  // utility functions
  function extractKMapID(line) {
    var kmap_id = null;
    var rgx1 = /\s(\w?\d+)$/;
    var matches = rgx1.exec(line);
    if (matches != null) {
      var kmap_id = matches[1];
    }
    return kmap_id;
  }

  function pickFilter(namespace, type, suggestion,filters_domain) {
    var $box = $('#' + namespace + '-filter-box-' + type);
    var kmap_id = 'F' + suggestion.id;
    var item = {
      domain: filters_domain , // default subjects
      id: suggestion.id,
      header: suggestion.value,
      path: '{{' + suggestion.id + '}}'
    };
    if (!filtered[namespace][type][kmap_id]) {
      filtered[namespace][type][kmap_id] = item;
      var $el = $("<div/>").addClass('selected-kmap ' + kmap_id).appendTo($box);
      $("<span class='icon shanticon-close2'></span>").addClass('delete-me').addClass(kmap_id).appendTo($el);
      $("<span>" + item.header + " " + kmap_id + "</span>").addClass('kmap-label').appendTo($el);
      $el.attr({
        'data-kmap-id-int': item.id,
        'data-kmap-path': item.path,
        'data-kmap-header': item.header
      });
      //    Drupal.attachBehaviors($el); //Drupal adds all the behaviours for the current element, we have to check if there are some that we need and add them manually but what would be best is that all the event binding 'on' use the new jquery delegate
    }
  }

  function getNamespace($el, suffix) {
    return $el.attr('id').replace(suffix, '');
  }

  function getFilter(namespace, type) {
    return $('#' + namespace + '-search-filter-' + type);
  }

  function getFilterBox(namespace, type) {
    return $('#' + namespace + '-filter-box-' + type);
  }

  function getTypeahead(namespace) {
    return $('#' + namespace + '-search-term');
  }

  var search_key = '';
  Plugin.prototype = {
    init: function(){
      const plugin = this;
      //;;var $typeaheadExplorer = $('#kmaps-explorer-search-term');
      var $typeaheadExplorer = $(plugin.element);
      /* just for the close button */
      $('.kmap-typeahead-picker, .kmap-tree-picker').each(function () {
        var $xbtn = $('button.searchreset', this);
        var $srch = $(".kmap-search-term:not(.kmaps-tt-hint)", this);  // the main search input
        $srch.data("holder", $srch.attr("placeholder"));

        // click
        $xbtn.click(function () {
          if ($srch.hasClass('kmaps-tt-input')) { // typeahead picker
            $xbtn.addClass('resetting');
            $srch.kmapsTypeahead('setValue', '', false);
            window.setTimeout(function () {
              $xbtn.removeClass('resetting');
              $xbtn.hide();
            }, 300);
          }
          else { // tree picker
            $srch.val('');
            $xbtn.hide();
          }
        });

        // --- focusin - focusout
        $srch.focusin(function () {
          $srch.attr("placeholder", "");
          $xbtn.show();
        }).focusout(function () {
          $srch.attr("placeholder", $srch.data("holder"));

          // see http://stackoverflow.com/questions/13980448/jquery-focusout-click-conflict
          // and http://stackoverflow.com/questions/8981463/detect-if-hovering-over-element-with-jquery
          if (!$xbtn.hasClass('resetting') && $xbtn.parent().find('.searchreset:hover').length > 0) {
            if ($srch.hasClass('kmaps-tt-input')) { // typeahead picker
              $xbtn.addClass('resetting');
              $srch.kmapsTypeahead('setValue', '', false);
              window.setTimeout(function () {
                $xbtn.removeClass('resetting');
                $xbtn.hide();
              }, 300);
            }
            else { // tree picker
              $srch.val('');
              $xbtn.hide();
            }
          }
          else {
            var str = $srch.data("holder");
            if (str.indexOf($srch.val()) > -1) {
              $xbtn.hide();
            }
          }
        });
      });

      /* END - just for the close button */
      $typeaheadExplorer.kmapsTypeahead({
        term_index: plugin.options.hostname,
        domain: plugin.options.domain,
        menu: $(plugin.options.menu),
        root_kmapid: plugin.options.root_kmapid,
        ancestors: plugin.options.ancestors,
        fields: plugin.options.fields,
        max_terms: plugin.options.max_terms,
        min_chars: plugin.options.min_chars,
        pager: plugin.options.pager,
        empty_query: plugin.options.empty_query,
        empty_limit: plugin.options.empty_limit,
        empty_sort: plugin.options.empty_sort,
        sort: plugin.options.sort,
        filters: plugin.options.shanti_kmaps_admin_solr_filter_query ? plugin.options.shanti_kmaps_admin_solr_filter_query : '',
        autocomplete_field: plugin.options.autocomplete_field,
      }).bind('typeahead:asyncrequest',
        function () {
          search_key = $typeaheadExplorer.typeahead('val'); //get search term
        }
      ).bind('typeahead:select',
        function (ev, sel) {
          var id = sel.doc.id.substring(sel.doc.id.indexOf('-') + 1);
          window.location.href = plugin.options.features_path+sel.id;
          $typeaheadExplorer.typeahead('val', search_key); // revert back to search key
        }
      );

      $('.kmap-filter-box').each(function () {
        var type = $(this).attr('data-search-filter');
        var namespace = getNamespace($(this), '-filter-box-' + type);
        if (!filtered[namespace]) {
          filtered[namespace] = {};
        }
        filtered[namespace][type] = {}; // Init filters for this field
      });

      $('.kmap-filter-box').on('click', '.delete-me', function (e) {
        var $el = $(this).parent();
        var $box = $(this).closest('.kmap-filter-box');
        var type = $box.attr('data-search-filter'); //feature_type or associated_subject
        var namespace = getNamespace($box, '-filter-box-' + type);
        var $filter = getFilter(namespace, type);
        var $typeahead = getTypeahead(namespace);
        var others = [];
        if (filtered[namespace]) {
          others = Object.keys(filtered[namespace]);
          others.splice(others.indexOf(type), 1);
        }
        var kmap_id = extractKMapID($(this).next('span.kmap-label').html());
        var field = type + "_ids";
        var search = $filter.typeahead('val'); //get search term
        KMapsUtil.removeFilters($typeahead, field, filtered[namespace][type]);
        delete filtered[namespace][type][kmap_id];
        KMapsUtil.trackTypeaheadSelected($filter, filtered[namespace][type]);
        $el.remove();
        var fq = KMapsUtil.getFilters(field, filtered[namespace][type], $box.hasClass('kmaps-conjunctive-filters') ? 'AND' : 'OR');
        $typeahead.kmapsTypeahead('addFilters', fq).kmapsTypeahead('setValue', $typeahead.typeahead('val'), false);
        for (var i=0; i<others.length; i++) {
          getFilter(namespace, others[i]).kmapsTypeahead('refetchPrefetch', fq);
        }
        $filter.kmapsTypeahead('refacetPrefetch', fq);
        $filter.kmapsTypeahead('setValue', search, false); // 'false' prevents dropdown from re-opening
      });

      $(plugin.options.filters_class).each(function () {
        var $filter = $(this);
        var type = $filter.attr('data-search-filter'); //feature_type or associated_subject
        var namespace = getNamespace($filter, '-search-filter-' + type);
        var others = [];
        if (filtered[namespace]) {
          others = Object.keys(filtered[namespace]);
          others.splice(others.indexOf(type), 1);
        }
        $filter.kmapsTypeahead({
          term_index: plugin.options.hostname,
          domain: plugin.options.filters_domain, // Most of the times Filter by Subject
          filters: KMapsUtil.getFilterQueryForFilter(type),
          ancestors: 'off',
          min_chars: 0,
          selected: 'omit',
          prefetch_facets: 'on',
          prefetch_field: type + 's', //feature_types or associated_subjects
          //prefetch_filters: plugin.options.root_kmap_path ? ['tree:' + plugin.options.domain, 'ancestor_id_path:' + plugin.options.root_kmap_path] : ['tree:' + plugin.options.domain],
          prefetch_filters: ['tree: '+plugin.options.domain],
          max_terms: 50
        }).bind('typeahead:select',
          function (ev, suggestion) {
            if (suggestion.count > 0) { // should not be able to select zero-result filters
              var mode = suggestion.refacet ? 'AND' : 'OR';
              var $typeahead = getTypeahead(namespace);
              var $box = getFilterBox(namespace, type);
              var field = type + "_ids";
              KMapsUtil.removeFilters($typeahead, field, filtered[namespace][type]);
              pickFilter(namespace, type, suggestion,plugin.options.filters_domain);
              $box.toggleClass('kmaps-conjunctive-filters', mode == 'AND');
              $box.show();
              KMapsUtil.trackTypeaheadSelected($filter, filtered[namespace][type]);
              var fq = KMapsUtil.getFilters(field, filtered[namespace][type], mode);
              $typeahead.kmapsTypeahead('addFilters', fq).kmapsTypeahead('setValue', $typeahead.typeahead('val'), false);
              for (var i=0; i<others.length; i++) {
                getFilter(namespace, others[i]).kmapsTypeahead('refetchPrefetch', fq);
              }
              $filter.kmapsTypeahead('refacetPrefetch', fq);
              $filter.kmapsTypeahead('setValue', '', false); // reset filter after selection
            }
          }
        );
      });
      /* scope filters */
      $(plugin.options.scope_filter_selector).on('change',function(){
        const $filter = $(this);
        const namespace = 'kmaps-explorer';
        const $typeahead = getTypeahead(namespace);
        const autocompleteField = plugin.getScopeField();
        $typeahead.kmapsTypeahead('setAutocompleteField', autocompleteField);
        $typeahead.kmapsTypeahead('setValue', $typeahead.val(), false);
      });
      $(plugin.options.match_filter_selector).on('change',function(){
        const $filter = $(this);
        const filter_value = $filter.val();
        const namespace = 'kmaps-explorer';
        const $typeahead = getTypeahead(namespace);
        var autocompleteField = 'name_autocomplete';
        switch($filter.val()){
          case 'begins':
          case 'exactly':
            autocompleteField = 'name';
            $("#search-note").show();
            $typeahead.kmapsTypeahead('setCaseSensitive', true);
            break
          default:
            autocompleteField = 'name_autocomplete';
            $("#search-note").hide();
            $typeahead.kmapsTypeahead('setCaseSensitive', false);
        }
        $typeahead.kmapsTypeahead('setAutocompleteField', autocompleteField);
        $typeahead.kmapsTypeahead('setMatchCriterion',filter_value);
        $typeahead.kmapsTypeahead('setValue', $typeahead.val(), false);
      });
      /* Go to FID */
      const $gotoFidElement = $(plugin.options.goto_fid_input);
      const $gotoFidButton = $(plugin.options.goto_fid_button);
      $gotoFidElement.keyup(function(event){
        if(event.keyCode == 13){
          plugin.gotoFID($gotoFidElement);
        }
      });
      $gotoFidButton.on('click',function(){
        plugin.gotoFID($gotoFidElement);
      });
    },
    getScopeField: function(){
      const plugin = this;
      const scope = $(plugin.options.scope_filter_selector+":checked").val();
      var autocompleteField = '';
      switch(scope){
        case 'full_text':
          autocompleteField = 'text';
          $("#search_match_contains").click();
          $(plugin.options.match_filter_selector+":not(:checked)").parent('div').parent('label').hide();
          break;
        case 'name':
          autocompleteField = 'name_autocomplete';
          $(plugin.options.match_filter_selector).parent('div').parent('label').show();
          break;
        default:
          autocompleteField = 'name_autocomplete';
          $(plugin.options.match_filter_selector).attr('disabled',false);
      }
      return autocompleteField;
    },
    gotoFID: function(elem) {
      const plugin = this;
      const fid = elem.val();
      var params = {
        'q': 'id:'+plugin.options.domain+'-'+fid,
        'wt': 'json',
        'fl': 'id'
      };
      var callBack = function(data){
        if((data.response !== undefined) && (data.response.numFound !== undefined) && data.response.numFound > 0) {
          window.location.href = plugin.options.features_path+fid;
        } else {
          var msg = 'No results for <span class="kmaps-tt-query">' + fid + '</span>. ';
          $('.listview > .view-wrap .kmaps-tt-dataset').html('<div class="kmaps-tt-message kmaps-tt-no-results">' + msg + '</div>');
        }
      };
      $.ajax({
        url: plugin.options.hostname+"/select/",
        data: $.param(params,true),
        dataType: 'jsonp',
        jsonp: 'json.wrf',
        success: callBack,
        error: callBack,
      });
    },
  }
	// You don't need to change something below:
	// A really lightweight plugin wrapper around the constructor,
	// preventing against multiple instantiations and allowing any
	// public function (ie. a function whose name doesn't start
	// with an underscore) to be called via the jQuery plugin,
	// e.g. $(element).defaultPluginName('functionName', arg1, arg2)
	$.fn[pluginName] = function ( options ) {
		var args = arguments;

		// Is the first parameter an object (options), or was omitted,
		// instantiate a new instance of the plugin.
		if (options === undefined || typeof options === 'object') {
			return this.each(function () {

				// Only allow the plugin to be instantiated once,
				// so we check that the element has no plugin instantiation yet
				if (!$.data(this, 'plugin_' + pluginName)) {

					// if it has no instance, create a new one,
					// pass options to our plugin constructor,
					// and store the plugin instance
					// in the elements jQuery data object.
					$.data(this, 'plugin_' + pluginName, new Plugin( this, options ));
				}
			});

			// If the first parameter is a string and it doesn't start
			// with an underscore or "contains" the `init`-function,
			// treat this as a call to a public method.
		} else if (typeof options === 'string' && options[0] !== '_' && options !== 'init') {

			// Cache the method call
			// to make it possible
			// to return a value
			var returns;

			this.each(function () {
				var instance = $.data(this, 'plugin_' + pluginName);

				// Tests that there's already a plugin-instance
				// and checks that the requested public method exists
				if (instance instanceof Plugin && typeof instance[options] === 'function') {

					// Call the method of our plugin instance,
					// and pass it the supplied arguments.
					returns = instance[options].apply( instance, Array.prototype.slice.call( args, 1 ) );
				}

				// Allow instances to be destroyed via the 'destroy' method
				if (options === 'destroy') {
					$.data(this, 'plugin_' + pluginName, null);
				}
			});

			// If the earlier cached method
			// gives a value back return the value,
			// otherwise return this to preserve chainability.
			return returns !== undefined ? returns : this;
		}
	};
})( jQuery, window, document );
