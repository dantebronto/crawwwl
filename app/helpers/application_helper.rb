module ApplicationHelper
  def filename(path) # really a link helper
    path.sub(/^.*\//,'')    
  end
end
