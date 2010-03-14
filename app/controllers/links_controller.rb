class LinksController < ApplicationController
  before_filter :controller_js
  
  def controller_js
    @controller_js = "links"
  end
  
  def index
    @links = Link.list(params)
  end
  
  def show
    @link = Link.find_by_id(params[:id])
    @images = @link.images
  end

  def create
    @link = Link.new(params[:link])
    
    if @link.save
      render :json => @link, :status => 200
    else
      render :json => { :errors => @link.errors.full_messages }, :status => 422
    end
  end
  
  def update
    @link = Link.find_by_id(params[:id])
    @link.url = params[:update_value]
    
    if @link.save
      render :text => @link.url
    else
      render :json => { :errors => @link.errors.full_messages }, :status => 422
    end
  end
  
  def update_description
    @link = Link.find_by_id(params[:id])
    @link.description = params[:update_value]
    
    if @link.save
      render :text => @link.description
    else
      render :json => { :errors => @link.errors.full_messages }, :status => 422
    end
  end
  
  def index_actions
    @link = Link.find_by_id(params[:id])
    render :partial => 'index_actions', :locals => {:link => @link}
  end
  
  def details
    @link = Link.find_by_id(params[:id])
    render :partial => 'details', :locals => {:link => @link}
  end
  
  def destroy
    @link = Link.find_by_id(params[:id])
    @link.destroy if @link
    render :text => "deleted"
  end
  
  def assign_image
    @link = Link.find_by_id(params[:id])
    if @link.assign_image_and_description(params)
      render :text => nil, :status => 200
    else
      render :text => nil, :status => 422
    end
  end
  
  def upload_image
    @link = Link.find_by_id(params[:id])
    if @link.assign_image_and_description(params)
      redirect_to next_links_path
    else
      flash[:error] = "Problem uploading file"
      redirect_to @link
    end
  end
  
  def next
    if @link = Link.find_by_status("crawwwled", :select => "id")
      redirect_to @link
    else
      flash[:notice] = "No more uncrawwwled links!"
      redirect_to links_path
    end
  end
  
  def mark_as_bad
    @link = Link.find_by_id(params[:id])
    @link.update_attribute(:status, 'bad')
    render :text => "ok"
  end
  
end