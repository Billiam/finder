AlFinder::Admin.controllers :points do

  get :index do
    @title = "Points"


    @filter = Point.get_filter(params[:filter] || 'unmoderated')
    @page = params[:page]
    @points = Point.filter(@filter).paginate :page => @page, :per_page => 25

    render 'points/index'
  end

  put :update, :with => :id do
    @title = pat(:update_title, :model => "point #{params[:id]}")
    @point = Point.find(params[:id])

    if @point
      if @point.update_attributes(params[:point], as: current_account.role.to_sym)
        flash[:success] = pat(:update_success, :model => 'Point', :id =>  "#{params[:id]}")
      else
        flash.now[:error] = pat(:update_error, :model => 'point')
      end
      redirect(url(:points, :index, page: params[:page], filter: params[:filter]))
    else
      flash[:warning] = pat(:update_warning, :model => 'point', :id => "#{params[:id]}")
      halt 404
    end
  end
end
