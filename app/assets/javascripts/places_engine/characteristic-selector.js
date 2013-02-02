function CharacteristicSelector(){

	// The id attribute of the div which contains all of DOM elements for this 
	this.divId = "";
	
	// The jQuery-wrapped DOM element of the div which contains all of DOM elements for this
	this.div = null;
	
	// The name and label attributes of the hidden field in which the selected ID(s) will be entered
	this.fieldName = "characteristic_name";
	this.fieldLabel = "";
	
	// The name attribute of the hidden input
	this.hiddenIdInputName = "characteristic_id";
	
	// The jQuery-wrapped DOM element of the hidden input which stores the selected ID(s)
	this.hiddenIdInput = null;
	
	// The jQuery-wrapped DOM element of the autocomplete text field input
	this.autocompleteInput = null;
	
	// Whether the popup has been initialized or not
	this.popupLoaded = false;

	// See the attribute documentation above for explanations of these arguments
	this.init = function(divId, options){
		var that = this;
		if(options.fieldName)			{ this.fieldName = options.fieldName; }
		if(options.fieldLabel)			{ this.fieldLabel = options.fieldLabel; }
		if(options.hiddenIdInputName)	{ this.hiddenIdInputName = options.hiddenIdInputName; }
		if(options.data)				{ this.data = options.data; }
		this.divId = divId;
		this.div = jQuery('#'+divId);
		this.div.html(
			(this.fieldLabel ? '<label for="'+this.fieldName+'">'+this.fieldLabel+'</label>' : '')+
			'<input type="text" name="'+this.fieldName+'" id="'+this.fieldName+'" />'+
			'<input type="hidden" name="'+this.hiddenIdInputName+'" id="'+this.hiddenIdInputName+'" />'
		);
		this.autocompleteInput = this.div.find('#'+this.fieldName);
		this.hiddenIdInput = this.div.find('#'+this.hiddenIdInputName);
		
		this.autocompleteInput.autocomplete({ source: this.data, 
			select: function (event, ui) { 
				that.hiddenIdInput.val(ui.item.value);
				that.treeNames.html('');
				that.treeRemove.hide();
				return false;
			}
		});

		this.objectList = [];
		for(var i in this.data){
			this.objectList[this.data[i].id] = this.data[i];
		}
		this.div.append('<br />Input type above or <a href="#" class="tree-link">select from list</a>'+
			'<span class="tree-names"></span> <a href="#" class="tree-remove">(remove)</a><span class="tree-loading" style="float:right;"></span>');
		this.treePopupId = this.divId+"_tree_popup";
		this.treeLink = this.div.find('.tree-link');
		this.treeRemove = this.div.find('.tree-remove');
		this.treeNames = this.div.find('.tree-names');
		this.treeLoading = this.div.find('.tree-loading');
		this.treeRemove.hide();
		jQuery('.tree-remove', this.div).on('click', function(){
			that.treeNames.html('');
			that.treeRemove.hide();
			that.hiddenIdInput.val('');
			return false;
		});
		this.treeLink.click(function(){
			jQuery('.draggable-popup').hide();
			if(!that.popupLoaded){
				that.loadPopup();
			}
			jQuery('#'+that.treePopupId).show();
			return false;
		});
	}
	
	this.loadPopup = function(){
		var that = this;
		this.treePopup = jQuery().draggablePopup({
			id: this.treePopupId,
			header: '',
			content: '',
			footer: '',
			width: 500,
			closeWith: 'hide'
		});
		var content = '<div style="font-size: 12px; line-height: 1.1em; height: 500px;"><br />'+
			'<div>Please select one or more characteristics from the list below.</div><br />'+
			'<form method="get" action="">'+
			'<div style="max-height: 400px; height:auto !important; height: 400px; overflow: auto;">'+
			this.getFormattedData()+
			'</div>'+
			'<br /><input type="submit" value="Select" /> <input type="button" value="Cancel" onclick="jQuery(this).parents(\'.draggable-popup:first\').hide(); return false;" />'+
			'</form>'+
			'</div>'
			;
		this.treePopup.setContent(content);
		this.treePopup.div.find('form:first').submit(function(){
			var ids = [];
			jQuery(this).find(':checkbox:checked').each(function(){
				ids.push(jQuery(this).val());
			});
			if(ids.length == 0){
			}else{
				var names = [];
				for(var i in ids){
					names.push(that.objectList[ids[i]].name);
				}
				that.hiddenIdInput.val(ids.join(','));
				that.autocompleteInput.val('');
				that.treeNames.html(':<br />'+names.join(', '));
				that.treeRemove.show();
			}
			jQuery('#'+that.treePopupId).hide();
			return false;
		});
		this.popupLoaded = true;
	};
	
	this.resetFields = function(){
		this.autocompleteInput.val('');
		this.hiddenIdInput.val('');
		this.treeNames.html('');
		this.treeRemove.hide();
		jQuery('#'+this.treePopupId).hide();
	};
	
	this.autocompleteFormatItem = function(item, i, max){
		return jQuery.trim(item.name);
	};
	
	this.autocompleteFormatMatch = function(item, i, max){
		return jQuery.trim(item.name);
	};
	
	this.autocompleteFormatResult = function(item, i, max){
		return item.id;
	};
		
	this.getFormattedData = function(){
		html = '<ul>';
		for(var i in this.data){
			var item = this.data[i];
			var element_id = this.fieldName+'_'+item.id;
			html += '<li><input type="checkbox" value="'+item.id+'" id="'+element_id+'" /> <label for='+element_id+'>'+item.name+'</label></li>';
		}
		html += '</ul>';
		return html;
	};

};