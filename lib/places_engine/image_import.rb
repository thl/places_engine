class ImageImport
  def self.do_image_import
    Feature.order(:fid).each do |f|
      puts "Checking feature #{f.fid}..."
      next if !f.illustration.nil?
      place = MmsIntegration::Place.find(f.fid) #MAKE TASK SPECIFIC TO SUBJECTS AND PLACES
      next if place.nil?
      pic = place.pictures.first
      next if pic.nil?
      puts "Adding picture #{pic.id}."
      f.create_illustration(:picture_id => pic.id, :picture_type => 'MmsIntegration::Picture', :is_primary => true)
    end
  end
end