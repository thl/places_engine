class InfoSource < ActiveRecord::Base
  has_many :citations
  has_many :feature_names
  has_many :feature_geo_codes
  
  # Validation
  validates_presence_of :code
  
  def self.search(filter_value, options={})
    options[:conditions] = build_like_conditions(
      %W(info_sources.code info_sources.title info_sources.agent),
      filter_value
    )
    paginate(options)
  end
  
  def self.get_by_code(code)
    if code.blank?
      info_source = nil
    else
      @cache_by_codes ||= {}
      info_source = @cache_by_codes[code]
      if info_source.nil?
        info_source = self.find_by_code(code)
        @cache_by_codes[code] = info_source if !info_source.nil?
      end
    end
    raise "Info source #{code} not found." if info_source.nil? && !code.blank?
    info_source
  end
end

# == Schema Info
# Schema version: 20110217172044
#
# Table name: info_sources
#
#  id             :integer         not null, primary key
#  agent          :string(255)
#  code           :string(255)     not null
#  date_published :date
#  title          :string(255)
#  created_at     :timestamp
#  updated_at     :timestamp