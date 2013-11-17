AlFinder::App.controllers :points do
  layout :application

  get :index, map: '/', provides: [:html, :csv], cache: true do
    expires_in 350

    @title = ''
    case content_type
      when :csv then
         Point.enabled.order_by(created_at: :desc).to_csv
      else
        render 'points/index'
    end
  end
end
