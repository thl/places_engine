class ImageImport
  def self.do_image_import
    Feature.order(:fid).each do |f|
      next if !f.illustration.nil?
      place = MmsIntegration::Place.find(f.fid) #MAKE TASK SPECIFIC TO SUBJECTS AND PLACES
      pic = place.pictures.first
      next if pic.nil?
      f.create_illustration(:picture_id => pic.id, :picture_type => 'MmsIntegration::Picture', :is_primary => true)
    end
  end
end