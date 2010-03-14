class PostsController < ApplicationController
  before_filter :controller_js, :except => [:show]
  
  def controller_js
    @controller_js = "posts"
  end
  
  def index
    @posts = Post.list
  end
  
  def new
    @post = Post.new
    @post.name = "post-from-#{Date.today}"
    @post.thumbnail_dimension = "60x50"
    @post.columns = 5
    @post.total_links = 25
  end
  
  def more
    @links = Link.more(params)
    render :partial => 'link', :collection => @links
  end
  
  def show
    @post = Post.find_by_id(params[:id])
  end
  
  def create
    @post = Post.new(params[:post])
    handle_builder_submits()
    
    if @post_saved
      redirect_to @post
    else
      render :action => 'new'
    end
  end
  
  def edit
    @post = Post.find_by_id(params[:id])
  end
  
  def update
    @post = Post.find_by_id(params[:id])
    @post.attributes = params[:post]
    handle_builder_submits()
    
    if @post_saved
      redirect_to @post
    else
      render :action => 'edit'
    end
  end
  
  def change_name
    @post = Post.find_by_id(params[:id])
    @post.update_attribute(:name, params[:update_value])
    render :text => params[:update_value]
  end
  
  def destroy
    Post.find_by_id(params[:id]).destroy
  end
  
  def publish
    @post = Post.find_by_id(params[:id])
    Delayed::Job.enqueue PostJob.new(@post.id)
    render :text => 'ok'
  end
  
  def poll_for_publish
    if Post.find_by_id(params[:id]).published?
      render :text => 'ok'
    else
      render :text => 'not ready yet', :status => 403
    end
  end
  
  protected
  
  def handle_builder_submits
    if params[:commit].downcase.include?('crop') # crop a link image
      link = Link.find_by_id(params[:link][:id])
      link.recrop_image(params[:thumbnail])
    elsif params[:commit].downcase.include?('upload') # crop a 
      link = Link.find_by_id(params[:link][:id])
      link.assign_image_and_description(params)
    elsif params[:commit].downcase.include?('link')
      @link = Link.new(params[:link])
      if @link.save
        @link.assign_image_and_description(params)
        @post.link_order << ",#{@link.id}"
      end
    elsif params[:commit].downcase.include?('post')
      @post_saved = @post.save
    end
  end
  
end