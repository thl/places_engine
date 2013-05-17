module PlacesEngine
  module Extension
    module FeaturesController
      extend ActiveSupport::Concern

      included do
      end
      
      def gis_resources
        fids = params[:fids].split(/\D+/)
        fids.shift if fids.size>0 && fids.first.blank?
        features = fids.collect{|fid| Feature.get_by_fid(fid.to_i)}.find_all{|f| f && f.is_public==1}
        fids = features.collect{|f| f.pid.gsub(/[^\d]/, '')}
        if params[:contained] && params[:contained] == '1'
          contained_fids = features.collect{|feature| feature.descendants.collect{|f|f.pid.gsub(/[^\d]/, '')}}.flatten
          fids = fids | contained_fids
        end
        fids.collect!{|fid| "fid="+fid }
        render :text => "Sorry, this request includes too many features for us to currently be able to provide this data." and return if fids.length > 300
        cql_filter = fids.join("+OR+")

      	general_params = "version=1.0.0&typename=thl:roman_popular_poly,thl:roman_popular_pt&layers=thl:roman_popular_poly,thl:roman_popular_pt&styles=thl_noscale,thl_noscale&projection=EPSG%3A4326&srs=EPSG%3A4326&cql_filter=("+cql_filter+");("+cql_filter+")"

        case params[:format]
        when 'gml'
          service = 'wfs'
          params = "&service=wfs&request=GetFeature&outputformat=GML2"
          type = 'text/xml'
          name = 'thl_gis.gml'
        when 'kml'
          service = 'wms'
          params = "&service=wms&request=GetMap&width=1600&height=750&bbox=-180.0,-90.0,180.0,90.0&format=application/vnd.google-earth.kml%20XML"
          type = 'text/xml'
          name = 'thl_gis.kml'
        when 'kmz'
          service = 'wms'
          params = "&service=wms&request=GetMap&width=1600&height=750&bbox=-180.0,-90.0,180.0,90.0&format=application/vnd.google-earth.kmz%20XML"
          type = 'application/vnd.google-earth.kmz'
          name = 'thl_gis.kmz'
        when 'shp'
          service = 'wfs'
          params = "&service=wfs&request=GetFeature&outputformat=shape-zip"
          type = 'application/zip'
          name = 'thl_gis.zip'
        end

        # Find the proper instance of GeoServer, based on the current environment
        geoserver_base = case InterfaceUtils::Server.environment
        when InterfaceUtils::Server::DEVELOPMENT then 'http://localhost:8080/thlib-geoserver/'
        when InterfaceUtils::Server::PRODUCTION  then 'http://localhost:8080/thdl-geoserver/'
        else                                          'http://www.thlib.org:8080/thdl-geoserver/'
        end
        if service.nil?
          render :nothing => true
        else
          url = geoserver_base+service+"?"+general_params+params
          begin
            send_data(open(url).read, :filename => name, :type => type, :disposition => 'attachment')
          rescue => e
            render :nothing => true
          rescue OpenURI::HTTPError => e
            render :nothing => true
          rescue Timeout::Error => e
            render :nothing => true
          end
        end
      end
    end
  end
end
