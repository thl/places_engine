var floatYloc = -280; // take off the amount of pixels above the feature pane.
var browseHeight;
var heightAdj = -60;  // Amount to adjust height of display pane

$(window).scroll(function () { 
	var sctop = z_scrollTop();  // determine scroll amount
	newoffset = floatYloc + sctop;
	if(newoffset < 0) {newoffset = 20;}
	newoffset += "px";
	jQuery("#FeaturePanel ul.ui-tabs-nav").animate({paddingTop:newoffset},{duration:400,queue:false});
	jQuery("#FeatureTree").animate({marginTop:"-" + newoffset},{duration:401,queue:false});
});

$(document).ready(function () {
	setTimeout('scrollToSelected();',1000);
	// size the FeatureDetails InnerPane
	//browseHeight = (typeof window.innerHeight != 'undefined' ? window.innerHeight : document.body.offsetHeight) + heightAdj;
	//jQuery("#FeatureDetails").css("overflow","auto").css("border","3px inset #AAA").css("padding","3px");;
	//jQuery("#FeatureDetails").height(browseHeight);
});

// Scroll to selected element in the FeatureTree
function scrollToSelected() {
	if(typeof(jQuery("#FeatureTree span.selected")) == "object" && jQuery("#FeatureTree span.selected").length > 0) {
		var offset = jQuery("#FeatureTree span.selected").offset().top - 10;
		jQuery('html,body').animate({scrollTop: offset}, 200);
	}
}

// Set the Size of the Detail Pane
function sizeDetailPane() {
}

// Calculates the pixel amount scrolled in a browser-generic way
function z_scrollTop() {
	return z_filterResults (
		window.pageYOffset ? window.pageYOffset : 0,
		document.documentElement ? document.documentElement.scrollTop : 0,
		document.body ? document.body.scrollTop : 0
	);
}

// Filters results from z_scrollTop
function z_filterResults(n_win, n_docel, n_body) {
	var n_result = n_win ? n_win : 0;
	if (n_docel && (!n_result || (n_result > n_docel)))
		n_result = n_docel;
	return n_body && (!n_result || (n_result > n_body)) ? n_body : n_result;
}

