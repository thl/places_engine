jQuery(document).ready(function(){

	// On the onclick of each <a> tag, decide how to properly treat the click in the iframe.
	// The first two clauses are dependent on the setup of the app; the last two clauses area
	// likely to be used in any context. 
	jQuery('a').live('click', function() {
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