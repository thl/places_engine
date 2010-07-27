// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
jQuery(document).ready(function(){

	if(typeof(ToggleSideMenu) != "undefined"){
		ToggleSideMenu();
	}

	// Add authentication to AJAX POSTs made by jQuery 
	jQuery(document).ajaxSend(function(event, request, settings) {
		if (settings.type == 'GET') return;
		if (typeof(AUTH_TOKEN) == "undefined") return;
		settings.data = settings.data || "";
		// This was removed to prevent a bug in the search result pagination in Chrome, but
		// should be uncommented if any issue with AUTH_TOKEN arise.
		//settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
	});
})


jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})