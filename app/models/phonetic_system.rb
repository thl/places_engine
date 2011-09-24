class PhoneticSystem < SimpleProp
  
  def display_string
    return name unless name.blank?
    return code unless code.blank?
    ''
  end
  
  def is_pinyin?
    code == 'pinyin.transcrip'
  end
  
  def is_ind_transcrip?
    code == 'ind.transcrip'
  end
  
  def is_thl_simple_transcrip?
    code == 'thl_simple_transcrip'
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