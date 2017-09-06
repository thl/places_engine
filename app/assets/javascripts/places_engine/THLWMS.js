OpenLayers.Layer.THLWMS = OpenLayers.Class(OpenLayers.Layer.WMS, {
	initialize: function(name, options){

		if(typeof options.geoserver_url != 'undefined'){
			this.geoserverUrl = options.geoserver_url;
        } else {
			this.setMapEnvironment();
        }
		
		if(typeof options.styles != 'undefined'){
			this.defaultStyleName = options.styles;
			// We need to put this into the form 'style_name,style_name,style_name', since we're using three layers (pt, poly, line)
			if(this.defaultStyleName.indexOf(',') == -1){
				this.defaultStyleName = this.defaultStyleName+','+this.defaultStyleName+','+this.defaultStyleName;
			}
			delete options.styles;
		}
		
		options = OpenLayers.Util.extend({
				layers: this.getPrimaryLayer(),
				transparent: true,
				sphericalMercator: true,
				projection: new OpenLayers.Projection("EPSG:900913"),
				units: "m",
        geoserverUrl: 'http://localhost:8080/thlib-geoserver',
				styles: this.placeNamesShown ? this.defaultStyleName : this.noNamesStyleName
				// The 'tiled' param enables metatiling in GeoServer, which will renders 3x3 tiles into one big tile, thus eliminating
				// most duplicate labels
				//tiled: 'true',
				//tilesOrigin : map.maxExtent.left + ',' + map.maxExtent.bottom
			}, options);
		var display_options = {singleTile: true, ratio: 1.5, wrapDateLine: true}
		var newArguments = [name, this.geoserverUrl+"/wms", options, display_options];
		OpenLayers.Layer.WMS.prototype.initialize.apply(this, newArguments);
		
		this.events.register("loadend", this, function() {
			this.isLoaded = true;
		});

	},
	
	afterAdd: function(){
		if(this.params.CQL_FILTER){
			var cql = this.params.CQL_FILTER;
			this.mergeNewParams({
				CQL_FILTER: cql+';'+cql+';'+cql
			});
		}
	},
	
	isLoaded: false,
	
	isLanguageDependent: true,
	
	mapEnvironment: 'production',
	
	geoserverUrl: null,
	
	defaultStyleName: null,
	
	noNamesStyleName: 'thl_no_names,thl_no_names',
	
	placeNamesShown: false,
	
	placeNamesOverride: false,
	
	language: 'roman.popular',
	
	languageLayerNames: {
		'roman.popular': 'roman_popular',
		'roman.scholar': 'roman_scholarly',
		'simp.chi': 'simple_chinese',
		'trad.chi': 'traditional_chinese',
		'pri.tib.sec.roman': 'tibetan_roman',
		'pri.tib.sec.chi': 'tibetan_chinese'
	},
	
	languageToLayerName: function(language){
		if(typeof this.languageLayerNames[language] == 'undefined'){
			return 'roman_popular';
		}
		return this.languageLayerNames[language];
	},
	
	showPlaceNames: function() {
		if(!this.placeNamesShown && this.isLanguageDependent) {
			this.mergeNewParams({
				STYLES: this.defaultStyleName
			});
			this.placeNamesShown = true;
		}
	},
	
	hidePlaceNames: function() {
		if(this.placeNamesShown && this.isLanguageDependent) {
			this.mergeNewParams({
				STYLES: this.noNamesStyleName
			});
			this.placeNamesShown = false;
		}
	},
	
	togglePlaceNames: function(show) {
		if(this.isLanguageDependent){
			if(show) {
				this.params.STYLES = this.defaultStyleName;
			} else {
				this.params.STYLES = this.noNamesStyleName;
			}
			this.placeNamesShown = show; 
		}
	},
	
	setLanguage: function(language) {
		if(this.isLanguageDependent){
			this.language = language;
			this.mergeNewParams({
				layers: this.getPrimaryLayer()
			});
		}
	},
	
	setLanguageDependent: function(isLanguageDependent){
		this.isLanguageDependent = isLanguageDependent;
		this.params.STYLES = this.defaultStyleName;
	},
	
	setMapEnvironment: function(){
    return null;
		// Determine the map's environment
		if(window.location.host.indexOf('localhost') == 0){
			this.mapEnvironment = 'local';
		}else if(window.location.host.indexOf('dev.thlib') == 0){
			this.mapEnvironment = 'dev';
		}else{
			this.mapEnvironment = 'production';
		}

		// Set variables that depend on the map's environment
		switch(this.mapEnvironment){
			case 'local':
				//this.geoserverUrl = 'http://dev.thlib.org:8080/thlib-geoserver';
				this.geoserverUrl = 'http://localhost:8080/thlib-geoserver';
				break;
			case 'dev':
				//this.geoserverUrl = 'http://dev.thlib.org:8080/thlib-geoserver'; /* Does not work (ndg, 1-17-11) */
				this.geoserverUrl = 'http://www.thlib.org:8080/thdl-geoserver';
				break;
			case 'staging':
				this.geoserverUrl = 'http://staging.thlib.org:8080/thlib-geoserver';
				break;
			case 'production':
				this.geoserverUrl = 'http://www.thlib.org:8080/thdl-geoserver';
				break;
		}
	},
	
	getPrimaryLayer: function(){
		// The "thl_no_names" style is only available in roman_popular
		var layer_name = this.languageToLayerName(this.language);
		if(!this.placeNamesShown){
			layer_name = 'roman_popular';
		}
		return 'thl:'+layer_name+'_poly,thl:'+layer_name+'_pt,thl:'+layer_name+'_line';
	},
	
	getLayerCqlFilter: function(){
		var cql = this.params.CQL_FILTER;
		var cql_split = cql.split(';');
		if(cql_split.length == 2 && cql_split[0] == cql_split[1]){
			return cql_split[0];
		}
		return false;
	},

	zoomToLayer: function(){
		var cql_filter = this.getLayerCqlFilter();
		if(cql_filter){
			this.zoomToCqlFilter(cql_filter);
		}
	},
	//render location marker using vector layer
	//lonLat: instance of OpenLayers.LonLat
	RenderLocationMarker: function(lonlat){
        var layer_style = OpenLayers.Util.extend({}, OpenLayers.Feature.Vector.style['default']);
        layer_style.fillOpacity = 0.4;
        layer_style.graphicOpacity = 1;
		var vectorLayer = new OpenLayers.Layer.Vector("LocationMarker", {style: layer_style});
		
		this.map.addLayer(vectorLayer);

		var style_red = OpenLayers.Util.extend({}, layer_style);
		style_red.strokeColor = "black";
		style_red.fillColor = "#00AEFF";
		style_red.graphicName = "circle";
		style_red.pointRadius = 7;
		style_red.strokeWidth = 2;		
		style_red.strokeLinecap = "butt";
		
        var point = new OpenLayers.Geometry.Point(lonlat.lon, lonlat.lat);
        var pointFeature = new OpenLayers.Feature.Vector(point,null,style_red);
		
		vectorLayer.addFeatures([pointFeature]);		
		this.map.events.register("zoomend", this.map, this.ZoomOutEventHandler);
	},
	//show location marker only of the curZoomLevel is lower than 9
	ZoomOutEventHandler: function(evt){
		var Layers=this.getLayersByName("LocationMarker");
		var vectorLayer=Layers[0];
		if (vectorLayer)
		{
			var curZoomLevel=this.getZoom();
			vectorLayer.setVisibility((parseInt(curZoomLevel)< 9));
		}
	},
	zoomToCqlFilter: function(cql_filter){
		var max_zoom = 3;
		var min_zoom = 0;
		serverUrl = this.geoserverUrl+
			'/wfs?service=wfs&version=1.1.0&request=GetFeature&typename=thl:bbox&cql_filter='+cql_filter+
			'&projection=EPSG:4326&SRS=EPSG:4326&outputFormat=json';
		var cur=this; //marker for current instance
		var curMap = this.map;
		var request = OpenLayers.Request.GET({
			url: serverUrl,
			callback: function(data) {
				data = data.responseText;
				if(data){
					var parser = new OpenLayers.Format.JSON();
					data = parser.read(data);
					if(data){
						var bounds = data.bbox;
						bounds = new OpenLayers.Bounds.fromArray([ bounds[1], bounds[0], bounds[3], bounds[2] ]);
						bounds = bounds.transform(new OpenLayers.Projection("EPSG:4326"), new OpenLayers.Projection("EPSG:900913"));
						cur.RenderLocationMarker(bounds.getCenterLonLat());
						curMap.zoomToExtent(bounds);
						if(curMap.zoom > max_zoom){
							curMap.zoomTo(max_zoom);
						}
						if(curMap.zoom < min_zoom){
							curMap.zoomTo(min_zoom);
						}
					}
				}
			}
		});		
	},
	
	CLASS_NAME: "OpenLayers.Layer.THLWMS"
});
