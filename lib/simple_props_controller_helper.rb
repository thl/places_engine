#
# This helper forces the admin/simple_props views to be used for any < SimpleProp class controller
#
module SimplePropsControllerHelper
  
  def self.extended(base)
    
    base.helper 'Admin'
    
    base.class_eval do
      
      def render(*args)
        tpl = params[:action]
        # tpl = args.first[:action]
        # If there is no current HTTP authentication, bypass this template rendering...
        tpl ? super("admin/simple_props/#{tpl}") : super(*args)
      end
      
      def collection
        @collection = model_name.classify.constantize.search(params[:filter]).page(params[:page]).order('UPPER(name)')
      end
      
    end
    
  end
  
end