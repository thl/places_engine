/*

NodeMenu creates an menu that lives on the right side of the screen, always stays within its container,
moves vertically to remain on the screen during page scroll, and can be expanded and collapsed.  It supports multiple
menu items, which can be toggled with an accordion-like setup.

The only necessary HTML is the following.  The toggle element and content wrapper div are created dynamically by the object. 

<div id="NodeMenu">
	<div class="node-menu-content">
		<h2>Menu Item 1</h2>
		<div>
			Menu item 1's content...
		</div>
		<h2>Menu Item 2</h2>
		<div>
			Menu item 2's content...
		</div>
	</div>
</div>


*/


var NodeMenu = {

	div_id: "",
	controller: "",
	// Width of the menu
	width: 270,
	// Width of the toggle switch
	toggle_width: 20,
	// Time in ms that toggling the menu takes
	toggle_speed: 500,
	// Time in ms that toggling menu items takes
	item_toggle_speed: 300,
	
	// The maximum y offset of the menu in its container during page scroll:
	max_container_offset_y: 400,
	
	// The default menu item's name (e.g. 'search') that should be open on initialization (set in init()'s options)
	default_item: false,
	
	// Whether the 'results' menu item should be shown on intialization
	show_results: false,
	
	// Generally for internal use only:
	div: null,
	content_div: null,
	toggle_div: null,
	page_offset_y: 0,
	page_offset_y_correction: 30,
	container_height: 0,
	resize_x: 0,
	resize_width: 0,
	hidden: false,
	mouse_is_down: false,
	menu_item_indexes: {
		'search' : 0,
		'results' : 1,
		'options' : 2,
		'browse' : 3
	},
	
	init: function(div_id, controller, options){
	
		if(typeof options == "undefined"){
			options = {}
		}
		if(options.default_item){ this.default_item = options.default_item; }
		if(options.show_results){ this.show_results = options.show_results; }
	
		// Set the object's attributes
		this.div_id = div_id;
		this.controller = controller;
		this.div = jQuery("#"+this.div_id);
		
		// Add the toggle switch
		this.div.prepend('<div class="node-menu-toggle"></div>');
		
		// Set more object attributes
		this.content_div = this.div.find(".node-menu-content");
		this.toggle_div = this.div.find(".node-menu-toggle");
		
		this.content_div.before('<span class="node-menu-resize" unselectable="on"></span>');
		this.resize_div = this.div.find(".node-menu-resize");
		
		// Set up the toggling events
		this.toggle_div.addClass("toggle-hide").click(function(){
			NodeMenu.toggleMenu();
		});
		this.div.find(".node-menu-title").click(function(){
			NodeMenu.toggleMenu();
		});
		
		// Set up the menu item toggling
		this.content_div.find("> div").addClass('item-contracted').hide();
		
		// Open the initial menu item
		if(this.default_item){
			this.showMenuItem(this.default_item, 0);
		}else{
			this.content_div.find("> div.default-item").addClass('item-expanded').show();
		}
		
		// Set up onclick events for the menu items to create accordion-like toggling
		this.content_div.find("> h2").click(function(){
			var sibling_div = jQuery(this).next();
			if(sibling_div.hasClass('item-contracted')){
				NodeMenu.toggleMenuItem(sibling_div, true);
				var menu_item_match = jQuery(this).attr('class').match(/(^|\s)menu-item-(\w+)($|\s)/);
				if(menu_item_match){
					NodeMenu.onMenuItemOpen(menu_item_match[2]);
				}
			}else{
				NodeMenu.toggleMenuItem(sibling_div, false);
			}
			NodeMenu.scrollToMenuTop();
		});
		
		// Set the initial widths
		this.div.width(this.width+"px");
		this.content_div.width((this.width-this.toggle_width-4)+"px");
		
		// Set up the resizing callback
		this.resize_div.mousedown(function(e){
			if(!NodeMenu.hidden){
				NodeMenu.resize_x = e.pageX;
				NodeMenu.resize_width = NodeMenu.div.width();
				NodeMenu.mouse_is_down = true;
				jQuery(document).bind("mousemove", NodeMenu.resize);
			}
		});
		
		// On mouseup, reset the changes made by this.resize_div.mousedown
        jQuery(document).mouseup(function(e){
                NodeMenu.resize_x = 0;
                NodeMenu.mouse_is_down = false;
                NodeMenu.resize_width = 0;
                jQuery(document).unbind("mousemove", NodeMenu.resize);
        });
		
		// Initialize values for use with moving the menu vertically
		this.page_offset_y = this.page_offset_y_correction + this.div.parent().position().top;
		this.container_height = this.div.parent().height();
		
		// Hide the search results item by default, unless it's the default_item (meaning that it's open by default)
		// or this.show_results is true
		if(!(this.default_item == 'results' || this.show_results)){
			jQuery('#NodeSearchResults').prev('h2').hide();
		}
		
		// Make old, hash-based links redirect to the appropriate new URL
		jQuery('a[href*=\\/features#]').livequery('click', function(){
			var id = this.href.match(/\/features#([\d]+)$/);
			if(id){
				id = id[1];
				window.location = NodeMenu.controller+id;
				return false;
			}
			return true;
		});

		jQuery('a[href*=\\/#]').livequery('click', function(){
			var id = this.href.match(/\/#([\d]+)$/);
			if(id){
				id = id[1];
				window.location = NodeMenu.controller+id;
				return false;
			}
			return true;
		});
		
		jQuery('a[href*=\\/\\?frame\\=destroy#]').livequery('click', function(){
			var id = this.href.match(/frame=destroy#([\d]+)$/);
			if(id){
				id = id[1];
				window.location = NodeMenu.controller+id;
				return false;
			}
			return true;
		});
		
		// Bind window scrolling to .moveMenu() 
		jQuery(window).bind("scroll", function(){NodeMenu.moveMenu();});
		
	},
	
	// Make the browser scroll to the top of the NodeMenu
	scrollToMenuTop: function(){
		// Only scroll if the page is not in an iframe
		if(typeof in_frame == "undefined" || !in_frame){
			jQuery('html, body').animate({scrollTop: (this.page_offset_y - 40)+'px'}, 'fast');
		}
	},
	
	// Methods for toggling menu items
	
	// Open the menu item at the specified index
	showMenuItemByIndex: function(index, speed){
		this.toggleMenuItem(this.content_div.find("> div").eq(index), true, speed);
	},
	
	showMenuItem: function(menu_item, speed){
		this.showMenuItemByIndex(this.menu_item_indexes[menu_item], speed);
	},
	
	// Either collapse or expand a menu item, depending on what show (boolean) is set to
	toggleMenuItem: function(div, show, speed){
		if(typeof speed == "undefined"){
			speed = this.item_toggle_speed;
		}
		if(show){
			this.content_div.find('.item-expanded')
				.removeClass('item-expanded')
				.addClass('item-contracted')
				.hide(speed);
			div.removeClass('item-contracted');
			div.addClass('item-expanded');
			div.show(speed);
		}else{
			div.removeClass('item-expanded');
			div.addClass('item-contracted');
			div.hide(speed);
		}
	},
	
	// Methods for toggling the menu
	toggleMenu: function(){
		if(this.toggle_div.hasClass("toggle-hide")){
			this.hideMenu();
		}else{
			this.showMenu();
		}
	},
	
	showMenu: function(){
		this.setWidth();
		this.toggle_div.removeClass("toggle-show").addClass("toggle-hide");
		this.div.animate({right: '0'}, this.toggle_speed);
		this.hidden = false;
	},
	
	hideMenu: function(){
		this.setWidth();
		this.toggle_div.removeClass("toggle-hide").addClass("toggle-show");
		this.div.animate({right: '-'+(this.width-this.toggle_width+2)+'px'}, this.toggle_speed);
		this.hidden = true;
	},
	
	// Set the with of the menu
	setWidth: function(){
		this.width = this.div.width();
	},
	
	// Resizes the menu on the west edge.  This is bound to mousemove after a this.resize_div.mousedown, and unbound on mouseup.
	resize: function(e){
		if(NodeMenu.mouse_is_down == true){
			NodeMenu.div.width(NodeMenu.resize_width-(e.pageX-NodeMenu.resize_x)+"px");
			NodeMenu.content_div.width(NodeMenu.resize_width-NodeMenu.toggle_width-4-(e.pageX-NodeMenu.resize_x)+"px");
		}
	},
	
	// Moves the menu during page scroll
	moveMenu: function(){
		var scroll_y = this.getViewportScrollY();
		var menu_height = this.div.height();
		if(scroll_y > this.page_offset_y){
			//this.div.css("margin-top", Math.min(scroll_y - this.page_offset_y, this.max_container_offset_y)+"px");
			this.container_height = this.div.parent().height();
			this.div.css("margin-top", Math.min(scroll_y - this.page_offset_y, this.container_height - (menu_height+20))+"px");
		}else{
			this.div.css("margin-top", "0px");
		}
	},
	
	// Returns the page's Y scroll offset
	getViewportScrollY: function(){
		var scrollY = 0;
		if( document.documentElement && document.documentElement.scrollTop ) {
			scrollY = document.documentElement.scrollTop;
		}else if( document.body && document.body.scrollTop ) {
			scrollY = document.body.scrollTop;
		}else if( window.pageYOffset ) {
			scrollY = window.pageYOffset;
		}else if( window.scrollY ) {
			scrollY = window.scrollY;
		}
		return scrollY;
	},
	
	// App-specific methods
	
	// Methods for searching
	beginSearch: function(loading_text){
		if(typeof loading_text == "undefined"){
			var loading_text = "Searching...";
		}
		this.content_div.find("#NodeSearchResults")
			.html('<img src="http://thlib.org/global/images/ajax-loader.gif" alt="" style="display:inline;" /> '+loading_text)
			.prev('h2').show();
		this.showMenuItem('results');
		this.onMenuItemOpen('results');
	},
	
	onPaginationClick: function(loading_text){
		if(typeof loading_text == "undefined"){
			var loading_text = "Loading results...";
		}
		this.content_div.find("#NodeSearchResults .pagination-info-cell")
			.html('<img src="http://thlib.org/global/images/ajax-loader.gif" alt="" style="display:inline;" /> '+loading_text);
		this.content_div.find('#NodeSearchResults td:not(.pagination-info-cell), #NodeSearchResults th').css('opacity', 0.3);
	},
	
	onPaginationLoad: function(){
		NodeMenu.content_div.find('#NodeSearchResults td:not(.pagination-info-cell), #NodeSearchResults th').css('opacity', 1);
	},
	
	beginFidSearch: function(){
		jQuery('#NodeSearch form').append('<img id="FidSearchSpinner" src="http://thlib.org/global/images/ajax-loader.gif" alt="Searching..." style="display:inline;margin-bottom:-3px;" />');
	},
	
	endFidSearch: function(){
		jQuery('#FidSearchSpinner').remove();
	},
	
	checkForFidSearch: function(){
		if(jQuery('#NodeSearch input[name=search_scope]:checked').val() == 'fid'){
			var id = jQuery('#NodeSearch input[name=filter]').val();
			this.beginFidSearch();
			jQuery.getJSON('/features/by_fid/'+id+'.json',
				function(response){
					NodeMenu.endFidSearch();
					var feature = response.features.feature;
					if(typeof feature != "undefined"){
						var id = feature.id;
						NodeTree.showNodeAndLoadExpandedTree(id);
					}else{
						NodeTree.showNode(0);
					}
				}
			);
			return false;
		}
		return true;
	},
	
	// Checks the window.location.hash for a node ID and then loads that node and the expanded tree if necessary
	loadLocation: function(){
		if(window.location.search){
			var search_params = ['context_id', 'filter', 'object_type', 'scope', 'search_scope'];
			var query = window.location.search.substr(1);
			var is_search = false;
			for(var i in search_params){
				if(query.indexOf(search_params[i]+'=') != -1){
					is_search = true;
				}
			}
			if(is_search){
				this.beginSearch();
				jQuery.ajax({
					type: 'POST',
					url: this.controller+'search',
					data: query,
					success: function(html){
						jQuery('#NodeSearchResults').html(html);
					}
				});
			}
			var menu_item = this.getUrlParam('menu_item');
			if(menu_item){
				this.showMenuItem(menu_item);
			}
		}
		this.loadLocationHash();
		return false;
	},
	
	getUrlParam: function(param){
		var query = window.location.search.substring(1);
		var vars = query.split("&");
		for (var i=0;i<vars.length;i++) {
			var pair = vars[i].split("=");
			if (pair[0] == param) {
				return pair[1];
			}
		}
		return false;
	},
	
	loadLocationHash: function(){
		if(window.location.hash){
			var id = window.location.hash.match(/^#([\d]+)$/);
			if(id){
				id = id[1];
				NodeTree.showNodeAndLoadExpandedTree(id);
			}
		}
		return false;
	},
	
	// App-specific functions and callbacks:
	
	onMenuItemOpen: function(menu_item){
		
		jQuery.ajax({
			type: 'POST',
			url: this.controller+'set_session_variables/0/',
			data: 'menu_item='+menu_item,
			success: function(){},
			error: function(){}
		});
		
		// When the Browse menu item is opened, scroll to the selected node after the menu item has
		// fully loaded
		if(menu_item == 'browse'){
			setTimeout('NodeTree.scrollToSelectedNode(0);', NodeMenu.item_toggle_speed+1);
		}
	}
	
};

