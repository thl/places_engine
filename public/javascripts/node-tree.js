/*

NodeTree creates a tree of nodes for use with AJAX interaction.  It assumes use with Rails, with the following actions
being defined (they should be in the controller specified by .controller):

- contracted/[id]
	a contracted node, with a "+" that calls NodeTree.expandNode()
- expanded/[id]
	an expanded node, listing the node, with a "-" that calls NodeTree.contractNode(), and 
	children of the node, which are rendered with the contracted/[id] action
- node_tree_expanded/[id]
	the tree, expanded only to show a branch that leads to the [id] node

The HTML for the tree should be of this form:
<ul>
	<li id="node_486_div">
		<a class="node-minus" href="#" onclick=""></a>
		<span class="node-name">
			<a href="#" onclick="">Node name</a>
		</span>
		<ul>
			<li id="node_489_div">
				<a class="node-minus" href="#" onclick=""></a>
				<span class="node-name">
					<a href="#" onclick="">Node name</a>
				</span>
			</li>
		</ul>
	</li>
</ul>

*/

var NodeTree = {
	
	// The following three attributes should be defined in init():
	div_id: "",
	list_div_id: "",
	controller: "",
	
	// Generally for internal use only:
	div: null,
	list_div: null,
	selected_node_id: null,
	page_offset_y: 0,
	
	init: function(div_id, list_div_id, controller){
	
		// Set the object's attributes
		this.div_id = div_id;
		this.list_div_id = list_div_id;
		this.controller = controller;
		this.div = jQuery("#"+this.div_id);
		this.list_div = jQuery("#"+this.list_div_id);
		
	},
	
	// This should be modified to perform whatever action is needed to display the information of a node when it is clicked
	showNode: function(id){
		NodeMenu.scrollToMenuTop();
		this.selectNode(id);
		this.loadFeatureTabs(id);
	},
	
	expandNode: function(id){
		jQuery('#node_'+id+'_div').load(this.controller+"expanded/"+id, function(){NodeTree.reselectNode();});
	},
	
	contractNode: function(id){
		jQuery('#node_'+id+'_div').load(this.controller+"contracted/"+id, function(){NodeTree.reselectNode();});
	},
	
	// This will remove .loading-node spinners, remove the previously highlighted node, and highlight the specified node 
	selectNode: function(id){
		jQuery('.selected-node').removeClass('selected-node');
		jQuery('#node_'+id+'_div > .node-name').addClass('selected-node');
		this.removeNodeLoading();
		this.selected_node_id = id;
	},
	
	// For use after expandNode() or contractNode() have been called, to be sure that the selected node is still selected after
	// those AJAX calls
	reselectNode: function(){
		jQuery('#node_'+this.selected_node_id+'_div > .node-name').addClass('selected-node');
	},
	
	// Scroll to the specified node
	scrollToNode: function(id, speed){
		if(typeof speed == "undefined"){
			speed = 300;
		}
		var node_element = jQuery('#node_'+this.selected_node_id+'_div > .node-name');
		if(node_element.length > 0) {
			var offset_within_tree = (node_element.offset().top + jQuery('#NodeTreeList').scrollTop() - jQuery('#NodeTreeList').offset().top) - 5;
			jQuery('#NodeTreeList').animate({scrollTop: offset_within_tree+'px'}, speed);
		}
	},
	
	// Scroll to the currently selected node
	scrollToSelectedNode: function(speed){
		var selected_node_id = this.getSelectedNodeId();
		if(selected_node_id){
			this.scrollToNode(selected_node_id, speed);
		}
	},
	
	// Get the ID of the currently selected node
	getSelectedNodeId: function(){
		var selected_node = jQuery('.selected-node:first');
		if(selected_node.length == 1){
			var id_match = selected_node.parents('li:first').attr('id').match(/node_([\d]+)_div/);
			if(id_match){
				var id = id_match[1];
				return id;
			}
		}
		return false;
	},
	
	// Add a spinner to the currently loading node
	addNodeLoading: function(id){
		jQuery('#node_'+id+'_div > .node-name').after('<span class="loading-node"></span>');
	},
	
	// Remove the spinner from the loaded node
	removeNodeLoading: function(){
		jQuery('.loading-node').remove();
	},
	
	// This can optionally be called before loadExpandedTree() to put a loading spinner in the tree list div
	beginNodeTreeLoading: function(){
		this.list_div.html('<img src="http://thlib.org/global/images/ajax-loader.gif" alt="Loading..." style="display:inline;" /> Loading...');
		NodeMenu.showMenuItemByIndex(3);
	},
	
	// Hides all branches that don't contain the listed ancestors.  The argument "ancestors" should be a comma-delimited
	// list of the ids of nodes which are ancestors of the shown node.  This is a JS-based alternative to reloading the entire
	// tree from scratch (which is what loadExpandedTree() does). 
	hideOtherBranches: function(ancestors){
		ancestors = ancestors.split(",");
		var id, branch_suffix = "";
		// For each ancestor, check the node tree at that level for any nodes that aren't in ancestors and remove them.
		for(var i=0; i<ancestors.length; i++){
			branch_suffix += " > li > ul";
			jQuery("#"+this.list_div_id+" > ul" + branch_suffix).each(function(){
				id = jQuery(this).parent().attr("id").split("_");
				id = id[1];
				if(!NodeTree.inArray(id, ancestors)){
					jQuery(this).parent().load(NodeTree.controller+"contracted/"+id);
				}
			});
		}
	},
	
	// Loads the entire node tree, expanded to the specified node 
	loadExpandedTree: function(id){
		this.list_div.load(this.controller+"node_tree_expanded/"+id, function(){
			NodeTree.selectNode(id);
			NodeTree.scrollToNode(id);
		});
	},
	
	// Will both show the specified node and load the expanded tree (only call this if the more 
	// efficient hideOtherBranches() isn't usable
	showNodeAndLoadExpandedTree: function(id){
		if(id != this.selected_node_id){
			this.beginNodeTreeLoading();
			this.loadExpandedTree(id);
			this.showNode(id);
		}
	},
	
	// Utilities
	inArray: function(mixed, array){
		for(var i in array){
			if(array[i] == mixed){
				return true;
			}
		}
		return false;
	},
	
	// Methods specific to the model 
	selectFeatureDetailsTab: function(){
		jQuery("#FeaturePanel").tabs('select', 1);
	},
	
	loadFeatureTabs: function(id){
		var panel = jQuery("#FeaturePanel");
		// If the Feature Detail and Related Features tabs haven't been added yet, add them
		if(panel.tabs("length") < 2){
			panel.tabs("add", "#FeatureTab1", "Feature Detail", 1);
			panel.tabs("add", "#FeatureTab2", "Related Features", 2);
		}
		panel.tabs("select", 1);
		panel.find("> div").eq(1).html('<img src="http://thlib.org/global/images/ajax-loader.gif" alt="Loading..." style="margin: 15px;" />');
		
		panel.tabs("url", 1, this.controller+"feature/"+id);
		panel.tabs("url", 2, this.controller+"related/"+id);
		if(panel.tabs("option", "selected") != 1){
			panel.tabs("select", 1);
		}else{
			panel.tabs("load", 1);
		}
		jQuery("#context_id").val(id);
	}
};