class Importation < CsvImportation
  def self.to_complex_date(str, certainty_id = nil, season_id = nil)
    complex_date = nil
    dash = str.index('-')
    if dash.nil?
      date = self.to_date(str)
      complex_date = ComplexDate.new(:day => date[:day], :day_certainty_id => certainty_id, :month => date[:month], :month_certainty_id => certainty_id, :year => date[:year], :year_certainty_id => certainty_id, :season_id => season_id, :season_certainty_id => certainty_id)
    else
      start_date = self.to_date(str[0...dash].strip)
      end_date = self.to_date(str[dash+1..str.size].strip)
      complex_date = ComplexDate.new(:day => start_date[:day], :day_end => end_date[:day], :day_certainty_id => certainty_id, :month => start_date[:month], :month_end => end_date[:month], :month_certainty_id => certainty_id, :year => start_date[:year], :year_end => end_date[:year], :year_certainty_id => certainty_id, :season_id => season_id, :season_certainty_id => certainty_id)
    end
    return complex_date
  end
  
  def self.content_attributes(object)
    return nil if object.nil?
    h = object.attributes
    h.delete('id')
    h.delete('updated_at')
    h.delete('created_at')
    h
  end
  
  def add_date(field_prefix, dateable)
    date = self.fields.delete("#{field_prefix}.time_units.date")
    calendar_id = self.fields.delete("#{field_prefix}.time_units.calendar_id") || 1
    frequency_id = self.fields.delete("#{field_prefix}.time_units.frequency_id")
    season_id = self.fields.delete("#{field_prefix}.time_units.season_id")
    certainty_id = self.fields.delete("#{field_prefix}.time_units.certainty_id")
    if certainty_id.blank?
      start_certainty_id = self.fields.delete("#{field_prefix}.time_units.start.certainty_id")
      end_certainty_id = self.fields.delete("#{field_prefix}.time_units.end.certainty_id")          
    else
      start_certainty_id = certainty_id
      end_certainty_id = certainty_id
    end
    time_units = dateable.time_units
    if date.blank?
      start_date = self.fields.delete("#{field_prefix}.time_units.start.date")
      end_date = self.fields.delete("#{field_prefix}.time_units.end.date")
      if !start_date.blank? || !end_date.blank?
        if start_date==end_date
          complex_date = Importation.to_complex_date(start_date, start_certainty_id, season_id)
          if complex_date.nil?
            puts "Date #{date} could not be associated to #{dateable.class.class_name.titleize}."
          else
            if !time_units.blank?
              complex_date_attributes = Importation.content_attributes(complex_date)
              time_unit = time_units.detect{|t| Importation.content_attributes(t.date) == complex_date_attributes}
            end
            attrs = {:is_range => false, :calendar_id => calendar_id, :frequency_id => frequency_id}
            if time_unit.nil?
              time_unit = time_units.build(attrs.merge(:date => complex_date))
              if !time_unit.date.nil?
                time_unit.date.save
                time_unit.save
              end
            else
              time_unit.update_attributes(attrs)
            end
          end
        else
          complex_start_date = start_date.blank? ? nil : Importation.to_complex_date(start_date, start_certainty_id, season_id)
          complex_end_date = end_date.blank? ? nil : Importation.to_complex_date(end_date, end_certainty_id, season_id)
          if complex_start_date.nil? && complex_end_date.nil?
            puts "Date #{date} could not be associated to #{dateable.class_name.titleize}."
          else
            if !time_units.blank?
              complex_start_date_attributes = Importation.content_attributes(complex_start_date)
              complex_end_date_attributes = Importation.content_attributes(complex_end_date)
              time_unit = time_units.detect{|t| Importation.content_attributes(t.start_date) == complex_start_date_attributes && Importation.content_attributes(t.end_date) == complex_end_date_attributes}
            end
            attrs = {:is_range => true, :calendar_id => calendar_id, :frequency_id => frequency_id}
            if time_unit.nil?
              time_unit = time_units.build(attrs.merge(:start_date => complex_start_date, :end_date => complex_end_date))
              time_unit.start_date.save if !time_unit.start_date.nil?
              time_unit.end_date.save if !time_unit.end_date.nil?
              time_unit.save
            else
              time_unit.update_attributes(attrs)
            end
          end
        end
      else
        month = self.fields.delete("#{field_prefix}.time_units.month")
        day = self.fields.delete("#{field_prefix}.time_units.day")
        if month.blank? && day.blank?
          start_month = self.fields.delete("#{field_prefix}.time_units.start.month")
          start_day = self.fields.delete("#{field_prefix}.time_units.start.day")
          end_month = self.fields.delete("#{field_prefix}.time_units.end.month")
          end_day = self.fields.delete("#{field_prefix}.time_units.end.day")
          if start_month.blank? && start_day.blank? || end_month.blank? && end_day.blank?
            rabjung_id = self.fields.delete("#{field_prefix}.time_units.date.rabjung_id")
            if !rabjung_id.blank?
              complex_date = ComplexDate.create(:rabjung_id => rabjung_id)
              time_unit = time_units.build(:date => complex_date)
              time_unit.save
            end
          else
            if start_day==end_day && start_month==end_month
              complex_date_attributes = {:day => start_day, :day_certainty_id => start_certainty_id, :month => start_month, :month_certainty_id => start_certainty_id, :season_id => season_id, :season_certainty_id => start_certainty_id}
              time_unit = time_units.detect{|t| Importation.content_attributes(t.date) == complex_date_attributes} if !time_units.blank?
              attrs = {:is_range => false, :calendar_id => calendar_id, :frequency_id => frequency_id}
              if time_unit.nil?
                complex_date = ComplexDate.create(complex_date_attributes)
                time_unit = time_units.build(attrs.merge(:date => complex_date))
                time_unit.save
              else
                time_unit.update_attributes(attrs)
              end
            else
              complex_start_date_attributes = {:day => start_day, :day_certainty_id => start_certainty_id, :month => start_month, :month_certainty_id => start_certainty_id, :season_id => season_id, :season_certainty_id => start_certainty_id}
              complex_end_date_attributes = {:day => end_day, :day_certainty_id => end_certainty_id, :month => end_month, :month_certainty_id => end_certainty_id, :season_id => season_id, :season_certainty_id => end_certainty_id}
              time_unit = time_units.detect{|t| Importation.content_attributes(t.start_date) == complex_start_date_attributes && Importation.content_attributes(t.end_date) == complex_end_date_attributes} if !time_units.blank?
              attrs = {:is_range => true, :calendar_id => calendar_id, :frequency_id => frequency_id}
              if time_unit.nil?
                complex_start_date = ComplexDate.create(complex_start_date_attributes)
                complex_end_date = ComplexDate.create(complex_end_date_attributes)
                time_unit = time_units.build(attrs.merge(:start_date => complex_start_date, :end_date => complex_end_date))
                time_unit.save
              else
                time_unit.update_attributes(attrs)
              end
            end
          end
        else
          complex_date_attributes = {:day => day, :day_certainty_id => certainty_id, :month => month, :month_certainty_id => certainty_id, :season_id => season_id, :season_certainty_id => certainty_id}
          time_unit = time_units.detect{|t| Importation.content_attributes(t.date) == complex_date_attributes} if !time_units.blank?
          attrs = {:is_range => false, :calendar_id => calendar_id, :frequency_id => frequency_id}
          if time_unit.nil?
            complex_date = ComplexDate.create(complex_date_attributes)
            time_unit = time_units.build(attrs.merge(:date => complex_date))
            time_unit.save
          else
            time_unit.update_attributes(attrs)
          end
        end
      end
    else
      complex_date = Importation.to_complex_date(date, certainty_id, season_id)
      if complex_date.nil?
        puts "Date #{date} could not be associated to #{dateable.class.class_name.titleize}."
      else
        if !time_units.blank?
          complex_date_attributes = Importation.content_attributes(complex_date)
          time_unit = time_units.detect{|t| Importation.content_attributes(t.date) == complex_date_attributes}
        end
        attrs = {:is_range => false, :calendar_id => calendar_id, :frequency_id => frequency_id}
        if time_unit.nil?
          time_unit = time_units.build(attrs.merge(:date => complex_date))
          if !time_unit.date.nil?
            time_unit.date.save
            time_unit.save
          end
        else
          time_unit.update_attributes(attrs)
        end
      end
    end            
  end
end