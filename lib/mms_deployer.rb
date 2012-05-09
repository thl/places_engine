module MediaManagementDeployer
  #  agent          :string(255)
  #  code           :string(255)     not null
  #  date_published :date
  #  title          :string(255)
  
  module Local
    class InfoSource < ActiveRecord::Base
    end  
  end
  
  def self.do_source_deployment
    Local::InfoSource.order('date_published, created_at').each do |info_source|
      info_source_title = info_source.title
      info_source_title = info_source.code if info_source_title.blank?
      document = Document.find_by_title(info_source_title)
      if document.nil?
        recording_note = info_source.agent.blank? ? nil : "<p>#{info_source.agent}</p>"
        document = Document.create(:taken_on => info_source.date_published, :recording_note => recording_note)
        Title.create(:language_id => 1, :medium_id => document.id, :title => info_source_title)
        Workflow.create(:medium_id => document.id, :original_medium_id => info_source.code) if !info_source.code.blank?
      end
      Citation.update_all("info_source_id = #{document.id}", ['info_source_id = ?', info_source.id])
    end
  end
end