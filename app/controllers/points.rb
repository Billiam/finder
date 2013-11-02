AlFinder::App.controllers :points do
  layout :application

  get :index, map: '/', provides: [:html, :csv] do
    @title = ''
    case content_type
      when :csv then
         Point.enabled.to_csv
      else
        render 'points/index'
    end
  end
  # get :index, :map => '/foo/bar' do
  #   session[:foo] = 'bar'
  #   render 'index'
  # end

  # get :sample, :map => '/sample/url', :provides => [:any, :js] do
  #   case content_type
  #     when :js then ...
  #     else ...
  # end

  # get :foo, :with => :id do
  #   'Maps to url '/foo/#{params[:id]}''
  # end

  # get '/example' do
  #   'Hello world!'
  # end
  

end
