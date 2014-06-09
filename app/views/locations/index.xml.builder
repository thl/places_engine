xml.feature do
  xml.altitudes(:type => 'array') do
    @feature.altitudes.each do |altitude|
      xml.altitude do
        xml.id(altitude.id, :type => 'integer')
        xml.unit(altitude.unit.title)
        xml.average(altitude.average, :type => 'integer')
        xml.estimate(altitude.estimate)
        xml.maximum(altitude.maximum, :type => 'integer')
        xml.minimum(altitude.minimum, :type => 'integer')
      end
    end
  end
  xml.shapes(:type => 'array') do
    @feature.shapes.each do |shape|
      xml.shape do
        xml.altitude(shape.altitude, :type => 'integer')
        xml.display(shape_display_string(shape))
      end
    end
  end
  xml.resources do
    xml.gml_url(gis_resources_url(:fids => @feature.fid, :format => 'gml'))
    xml.kml_url(gis_resources_url(:fids => @feature.fid, :format => 'kml'))
    xml.shapefile_url(gis_resources_url(:fids => @feature.fid, :format => 'shp'))
  end
  descendants = @feature.descendants
  xml.resources_contained do
    xml.gml_url(gis_resources_url(:fids => @feature.fid, :format => 'gml', :contained => '1'))
    xml.kml_url(gis_resources_url(:fids => @feature.fid, :format => 'kml', :contained => '1'))
    xml.shapefile_url(gis_resources_url(:fids => @feature.fid, :format => 'shp', :contained => '1'))    
  end if !descendants.empty? && descendants.length < 300
end