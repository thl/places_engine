/*
Usage:
jQuery(document).ready(function(){
	jQuery('#container').ajaxSortable({
		action: '/admin/feature_names/prioritize',
		object_id: <%= @object.id.to_s %>
	});
});
*/

jQuery.fn.ajaxSortable = function(options){
	var global_this;
	this.defaults = {
		action: null,
		object_id: null
	};
	this.options = options = jQuery.extend(this.defaults, options);
	this.container_id = this.attr('id');
	this.init = function(){
		global_this = this;
		this.sortable({
			dropOnEmpty:false,
			items: 'tr:has(td)',
			scroll: true,
			helper: 'clone',
			cursor: 'pointer',
			update: function(event, ui){
				global_this.css('border', '3px dashed yellow');
				// Update the displayed priority values, if they exist
				var priority_elements = global_this.find('.sortable-priority-value');
				for(var i=0; i<priority_elements.length; i++){
					jQuery(priority_elements.get(i)).text(i+1);
				}
				// Make the AJAX request to change the priorities
				jQuery.ajax({
					type: 'post',
					data: global_this.sortable('serialize')+'&id='+global_this.options.object_id,
					dataType: 'script',
					url: global_this.options.action,
					complete: function(request){
						global_this.css('border', '3px solid transparent');
					}
				});
			}
		});
		// Preserve the element widths while they are being dragged
		this.find('tr').css('width', this.find('tr:first').width()+'px');
		return this;
	};
	this.init();
	return this;
}