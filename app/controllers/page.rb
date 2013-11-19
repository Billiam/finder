AlFinder::App.controllers :page do
  layout :application

  get :help, map: '/help' do
    render 'page/help'
  end
end
