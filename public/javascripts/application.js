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
		settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
	});
})


jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})