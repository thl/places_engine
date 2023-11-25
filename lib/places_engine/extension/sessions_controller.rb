module PlacesEngine
  module Extension
    module SessionsController
      extend ActiveSupport::Concern

      included do
      end
      
      def change_language
        case params[:id]
        when 'bo'
          session['language'] = 'bo'
          view = View.get_by_code('pri.tib.sec.chi')
          view = View.get_by_code('pri.tib.sec.roman') if view.nil?
          view = View.get_by_code(default_view_code) if view.nil?
          self.current_view_id = view.id
        when 'dz'
          session['language'] = 'dz'
          view = View.get_by_code('pri.tib.sec.roman')
          view = View.get_by_code(default_view_code) if view.nil?
          self.current_view_id = view.id
        when 'zh'
          session['language'] = 'zh'
          view = View.get_by_code('simp.chi')
          view = View.get_by_code(default_view_code) if view.nil?
          self.current_view_id = view.id
        when 'en'
          session['language'] = 'en'
          self.current_view_id = View.get_by_code(default_view_code).id
        end
        redirect_back fallback_location: root_url
      end
    end
  end
end
