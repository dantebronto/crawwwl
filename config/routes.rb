ActionController::Routing::Routes.draw do |map|
  
  map.resources :source_urls, 
    :except => [:edit],
    :member => { 
      :index_actions => :get,
      :extract_links => :get,
      :save_links => :post
    }
    
  map.resources :links,
    :member => { 
      :index_actions => :get,
      :assign_image => :put, 
      :upload_image => :put,
      :details => :get,
      :update_description => :put,
      :mark_as_bad => :put
    },
    :collection => {
      :next => :get
    }
    
  map.resources :posts,  
    :member => {
      :change_name => :put,
      :publish => :post,
      :poll_for_publish => :get
    }
  
  map.more_posts '/posts/more/:number', 
    :controller => :posts, 
    :action => :more, 
    :method => :get
    
  map.root :controller => "welcome"
end
