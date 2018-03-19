class Topic < SubjectsIntegration::Feature
  headers['Host'] = SubjectsIntegration::Feature.headers['Host'] if !SubjectsIntegration::Feature.headers['Host'].blank?
  self.element_name = 'feature'
end