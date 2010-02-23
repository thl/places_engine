/*
ThlTabs is an abstraction of jQuery UI tabs that allows "codes" (identifiers) to be attached to tabs.
Tabs can then more easily be added, updated, and managed, regardless of their index, which is what
is usually used as the identifier for jQuery UI tabs.
*/

var ThlTabs = {

	// The id of the DOM element which holds the UI tabs
	tabs_id: null,
	
	// The internal list of tabs, which are objects with attributes code, index, label, and url
	tabs: null,
	
	// The jQuery wrapped div that holds the UI tabs
	div: null,
	
	// An object with code: label values that is used to look up UI tabs by label and use them to
	// set this.tabs on this.init()
	default_tab_codes: null,
	
	init: function(tabs_id, default_tab_codes){
		this.tabs_id = tabs_id;
		this.div = $('#'+this.tabs_id);
		this.setTabs();
	},
	
	// Populates this.tabs by looking for UI tabs that have labels in this.default_tab_codes
	setTabs: function(){
		
		this.tabs = [];
		
		$('#'+this.tabs_id+' > ul > li > a > span').each(function(index){
			var label = $(this).text();
			var code = ThlTabs.getDefaultCodeByLabel(label);
			if(code){
				ThlTabs.tabs.push({
					code: code,
					index: index,
					label: label,
					url: $(this).parents('a:first').attr('href')
				});
			}
		});
		
	},
	
	// Methods for manipulating tabs
	
	selectTab: function(tab){
		this.div.tabs('select', tab.index);
		this.scrollToTabs();
	},
	
	addTab: function(code, label, url){
		this.div.tabs('add', url, label);
		this.tabs.push({
			code: code,
			index: this.div.tabs( 'length' )-1,
			label: label,
			url: url
		});
	},
	
	loadTab: function(tab){
		this.div.tabs('load', tab.index);
	},
	
	addAndSelectTab: function(code, label, url){
		
		var tab = this.getTabByCode(code);
		
		if(tab){
			this.setTabUrl(tab, url);
		}else{
			this.addTab(code, label, url);
			tab = this.getTabByCode(code);
		}
		this.selectTab(tab);
		
	},
	
	// Getters
	
	getDefaultCodeByLabel: function(label){
		for(var i in this.default_tab_codes){
			if(this.default_tab_codes[i] == label){
				return i;
			}
		}
		return false;
	},
	
	getTabByCode: function(code){
		for(var i in this.tabs){
			if(this.tabs[i].code == code){
				return this.tabs[i];
			}
		}
		return false;
	},
	
	// Setters
	
	setTabUrl: function(tab, url){
		this.div.tabs('url', tab.index, url);
		for(var i in this.tabs){
			if(this.tabs[i].code == tab.code){
				this.tabs[i].url = url;
			}
		}
	},
	
	setTabUrlAndLoadByCode: function(code, url){
		var tab = this.getTabByCode(code);
		if(tab){
			this.setTabUrl(tab, url);
			this.loadTab(tab);
		}
	},
	
	// Utilities
	
	scrollToTabs: function(){
		// Only scroll if the page is not in an iframe.  in_frame is a global JS variable that's
		// set within iframes.
		if(typeof in_frame == "undefined" || !in_frame){
			var top = this.div.parent().position().top;
			jQuery('html, body').animate({scrollTop: top+'px'}, 'fast');
		}
	}
	
};

