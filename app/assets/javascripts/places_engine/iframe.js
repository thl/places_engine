// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require places_engine/jquery-form
//= require places_engine/jquery.livequery
//= require places_engine/sections/features
//= require places_engine/inset-map

jQuery(document).ready(function(){

	// On the onclick of each <a> tag, decide how to properly treat the click in the iframe.
	// The first two clauses are dependent on the setup of the app; the last two clauses area
	// likely to be used in any context. 
	jQuery('a').on('click', function() {
		var matches;
		
		// AJAX feature link: rewrite to use the iframe action instead
		if(matches = this.href.match(/\/features#([\d]+)/)){
			this.href = "/features/iframe/"+matches[1];
			
		// "/iframe/" link: don't change it
		}else if(matches = this.href.match(/\/iframe\//)){
		
		// Link with events already bound to it (e.g. AJAX): don't change it
		}else if( typeof (jQuery(this).data('events')) != 'undefined' ){
		
		// Otherwise: make the link open in the iframe's _parent
		}else{
			this.target = "_parent";
		}
		
		return true;
	});

});