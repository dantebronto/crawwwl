class SourceUrlsController < ApplicationController
  before_filter :controller_js
  
  def controller_js
    @controller_js = "source_urls"
  end
  
  def index
    @source_urls = SourceUrl.all(:order => "url")
  end
  
  def show
    @source_url = SourceUrl.find_by_id(params[:id])
  end
  
  def create
    @source_url = SourceUrl.new(params[:source_url])
    
    if @source_url.save
      render :json => @source_url, :status => 200
    else
      render :json => { :errors => @source_url.errors.full_messages }, :status => 422
    end
  end
  
  def update
    @source_url = SourceUrl.find_by_id(params[:id])
    @source_url.url = params[:update_value]
    
    if @source_url.save
      render :text => @source_url.url, :status => 200
    else
      render :json => { :errors => @source_url.errors.full_messages }, :status => 422
    end
  end
  
  def destroy
    @source_url = SourceUrl.find_by_id(params[:id])
    @source_url.destroy if @source_url
    render :text => nil, :status => :ok
  end
  
  def index_actions
    @source_url = SourceUrl.find_by_id(params[:id])
    render :partial => 'index_actions', :locals => {:source_url => @source_url }
  end
  
  def extract_links
    @source_url = SourceUrl.find_by_id(params[:id])
    render :json => @source_url.extracted_links, :status => 200
  end
  
  def save_links
    Link.create_from_params(params)
    render :json => { :status => "ok" }
  end
end