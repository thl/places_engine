module Admin::AltitudesHelper
  def altitude_display_string(altitude)
    a = []
    a << altitude.estimate if !altitude.estimate.nil?
    a << "#{altitude.average} (average)" if !altitude.average.nil?
    a << "#{altitude.minimum} (minimum)" if !altitude.minimum.nil?
    a << "#{altitude.maximum} (maximum)" if !altitude.maximum.nil?
    a.empty? ? '' : a.join(', ')
  end
end
