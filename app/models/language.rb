class Language < SimpleProp  
  #
  #
  # Associations
  #
  #
  
  #
  # Validation
  #
  #
  
  ## Language codes should all come from ISO 639-2 available at http://www.loc.gov/standards/iso639-2/php/code_list.php
  validates_format_of :code, :with => /^[a-z]{3}$/
  validates_uniqueness_of :code
  
  def is_chinese?
    code == 'chi'
  end
  
  def is_english?
    code == 'eng'
  end
  
  def is_nepali?
    code == 'nep'
  end
  
  def is_tibetan?
    code == 'tib'
  end
  
  def is_western?
    Language.is_western_id? self.id
  end

  def lacks_transcription_system?
    Language.lacks_transcription_system_id? self.id
  end
      
  def self.is_western_id?(language_id)
    @@western_ids ||= [:eng, :ger, :spa, :pol, :lat, :ita].collect{|code| self.get_by_code(code) }
    @@western_ids.include? language_id
  end
  
  def self.lacks_transcription_system_id?(language_id)
    @@lacks_transcription_system_ids ||= [:urd, :ara, :mya, :jpn, :kor, :pli, :pra, :san, :sin, :tha].collect{|code| self.get_by_code(code)}
    @@lacks_transcription_system_ids.include? language_id
  end
end

# == Schema Info
# Schema version: 20110923232332
#
# Table name: simple_props
#
#  id          :integer         not null, primary key
#  code        :string(255)
#  description :text
#  name        :string(255)
#  notes       :text
#  type        :string(255)
#  created_at  :timestamp
#  updated_at  :timestamp