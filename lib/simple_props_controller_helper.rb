#
# This helper forces the admin/simple_props views to be used for any < SimpleProp class controller
#
module SimplePropsControllerHelper
  
  def self.extended(base)
    
    base.helper 'Admin'
    
    base.class_eval do
      
      def render(*args)
        tpl = args.first[:action]
        # If there is no current HTTP authentication, bypass this template rendering...
        tpl ? super(:template=>"admin/simple_props/#{args.first[:action]}") : super(*args)
      end
      
      def collection
        @collection = model_name.classify.constantize.search(params[:filter], :page=>params[:page], :order=>"UPPER(name)")
      end
      
    end
    
  end
  
end