module Admin::FeatureObjectTypesHelper
  include AdminHelper

  def stylesheet_files
    uses_thickbox? ? super + ['thickbox', 'category_selector'] : super
  end
  
  def javascript_files
    uses_thickbox? ? super + ['thickbox-compressed', 'category_selector'] : super
  end
  
  private
  
  def uses_thickbox?
    ['new', 'edit'].include? params[:action]
  end
end