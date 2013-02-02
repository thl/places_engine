$(document).ready(function() {
  
  // hide side column
  //$("#sideMenuLink").html('<img src="/testing-area/mark/images/nav-side-show.gif" alt="Show Menu" />');
  jQuery("#sideMenuLink").css("background-position", "0% 0%");
  jQuery("#fxSideMenu").fadeOut("fast");

  // set the initial focus on the search text field
  jQuery('#filter').focus();

  // set some highlighting for the search results
  jQuery('.featureRow').hover (
    function() { jQuery(this).addClass('rowHighlight')},
    function() { jQuery(this).removeClass('rowHighlight')}
  );
    
});
