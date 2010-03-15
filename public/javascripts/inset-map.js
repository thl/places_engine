var InsetMap = {

	map: null,
	fid: null,
	language: null,
	layer: null,
	geoserverUrl: 'http://www.thlib.org:8080/thdl-geoserver',
	proxyUrl: '/proxy_engine/utils/proxy/?proxy_url=',
	nationObjectType: 29,
	
	init: function(){
		this.fid = this.getFid();
		if(this.fid){
			InsetMap.initMap(fid);		
			this.layer = InsetMap.addFeatureByFid(fid);
			this.language = this.getLanguage();
			if(this.language){
				this.layer.setLanguage(this.language);
			}
			this.layer.zoomToLayer();
		}
	},
	
	getFid: function(){
		var div = $('#inset_map');
		if(div.length > 0){
			var map_class = div.attr('class');
			if(map_class){
				var fid_match = map_class.match(/fid-([\d]+)/)
				if(fid_match){
					fid = fid_match[1];
					return fid;
				}
			}
		}
		return false;
	},
	
	getLanguage: function(){
		var div = $('#inset_map');
		if(div.length > 0){
			var map_class = div.attr('class');
			if(map_class){
				var fid_match = map_class.match(/language-([\w.]+)/)
				if(fid_match){
					fid = fid_match[1];
					return fid;
				}
			}
		}
		return false;
	},
	
	setLayerNameByFid: function(layer_id, fid, prefix, suffix){
		prefix = (typeof prefix == 'undefined') ? '' : prefix;
		suffix = (typeof suffix == 'undefined') ? '' : suffix;
		$.getJSON(OpenLayers.ProxyHost+escape('http://places.thlib.org/feature/'+fid+'.js'),
			function(data){
				data = data.feature;
				match = InsetMap.map.getLayer(layer_id);
				if(match != null){
					match.setName(prefix+data.header+suffix);
				}
			}
		);
	},
	
	addFeatureByFid: function(fid){
		var new_layer = new OpenLayers.Layer.THLWMS(name ? name : 'FID: '+fid, {
			CQL_FILTER: "fid="+fid+""
		});
		new_layer.showPlaceNames();
		// Many view codes aren't set up in GeoServer yet, so we'll have to wait to use setLanguage()
		//new_layer.setLanguage(current_view_code);
		new_layer.id = 'feature_fid_'+fid;
		InsetMap.map.addLayer(new_layer);
		// Not used, as we're not using a layer switcher yet
		//InsetMap.setLayerNameByFid(new_layer.id, fid);
		
		return new_layer;
	},

	initMap: function(){
	
		OpenLayers.ProxyHost = this.proxyUrl;
		OpenLayers.Util.onImageLoadErrorColor = "transparent";
		OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
	
		var mapOptions = {
			controls: [],
			projection: new OpenLayers.Projection("EPSG:900913"),
			units: "m",
			maxResolution: 156543.0339,
			maxExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34),
			restrictedExtent: new OpenLayers.Bounds(-20037508.34, -20037508.34, 20037508.34, 20037508.34),
			minZoomLevel: 1
		};
	
		InsetMap.map = new OpenLayers.Map('inset_map', mapOptions);
	
		InsetMap.map.addControl(new OpenLayers.Control.MouseDefaults({
			title:'Drag to pan, double-click to zoom in'
		}));
	
		InsetMap.map.addControl(new OpenLayers.Control.PanZoom());
		
		/*InsetMap.map.addControl(new OpenLayers.Control.MousePosition({
			displayProjection: new OpenLayers.Projection("EPSG:4326"),
			numDigits: 4
		}));*/
		
		/*InsetMap.map.addControl(new OpenLayers.Control.LayerSwitcher({
			'ascending': false
		}));*/
		
		var gsat = new OpenLayers.Layer.Google(
			"Google Satellite",
			{
				type: G_SATELLITE_MAP,
				sphericalMercator: true,
				isBaseLayer: true
			}
		);
	
		InsetMap.map.addLayers([gsat]);
	
		InsetMap.map.zoomToExtent(new OpenLayers.Bounds(4370000, 290000, 14230000, 5670000));
		InsetMap.map.zoomIn();
		
	},
	
	// Not yet implemented
	renderEnclosingNation: function(fid){
	
		var enclosing_nation_wfs_url = InsetMap.geoserverUrl+'/wfs?typename=thdl%3Atest2&layers=thdl%3Atest2&SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature'
			+'&outputFormat=json&MAXFEATURES=1&propertyname=geometry&CQL_FILTER=fid='+fid;
		
		$.getJSON(OpenLayers.ProxyHost+escape(enclosing_nation_wfs_url),
			function(data){
				var bounds = new OpenLayers.Bounds.fromString(data.bbox.join(','));
				
				// Unset data for performance reasons
				data = null;
				center = bounds.getCenterLonLat();
				var cql_filter = 'INTERSECT(geometry,POINT('+center.lon+' '+center.lat+')) AND (object_type='+InsetMap.nationObjectType+')';
				
				var new_layer = new OpenLayers.Layer.THLWMS('Enclosing country', {
					CQL_FILTER: cql_filter
				});
				new_layer.showPlaceNames();
				// Many view codes aren't set up in GeoServer yet, so we'll have to wait to use setLanguage()
				//new_layer.setLanguage(current_view_code);
				new_layer.id = 'bounding_nation';
				InsetMap.map.addLayer(new_layer);
				
				var info_url = new_layer.getFullRequestString({
					feature_count: 1,
					WIDTH: 1000,
					HEIGHT: 1000,
					outputFormat: 'text/json',
					propertyname: 'fid'
				});
				
				var clicked_geometry = new OpenLayers.Bounds(center.lon, center.lat, center.lon+0.00001, center.lat+0.00001);
				var geometryString = clicked_geometry.toGeometry().toString();
				
				cql_filter = 'INTERSECT(geometry,POINT('+center.lon+' '+center.lat+')) AND (object_type='+InsetMap.nationObjectType+')';
	
				var wfs_url = InsetMap.geoserverUrl+'/wfs?typename=thdl%3Atest2&layers=thdl%3Atest2&SERVICE=WFS&VERSION=1.0.0&REQUEST=GetFeature'
					+'&outputFormat=json&propertyname=fid&CQL_FILTER='+escape(cql_filter);
				$.getJSON(OpenLayers.ProxyHost+escape(wfs_url),
					function(data){
						var fid = data.features[0].properties.fid;
						InsetMap.setLayerNameByFid('bounding_nation', fid, '', ' (enclosing nation)');
					}
				);
			}
		);
		
	}
}