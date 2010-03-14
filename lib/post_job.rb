class PostJob < Struct.new(:post_id)
  def perform
    @post = Post.find_by_id(post_id)

    # build the template from haml
    template = %Q{
#crawwwl_post_holder{:style => 'width:' + (post.columns * (post.thumbnail_width.to_i + 12)).to_s + 'px;'}
  -post.ordered_links.each do |link|
    .crawwwl_link_thumb{:style => 'width:' + post.thumbnail_width + 'px;height:' + post.thumbnail_height + 'px;' }
      %a{:href => link.url}
        %img{:src => post.image_path_prefix + link.image.original_filename, :alt => link.description, :title => link.description}
    }

    # render the template
    rendered_template = Haml::Engine.new(template).
      render_proc(Object.new, :post).
      call :post => @post
    
    # create the directory
    tar_dir = File.join(RAILS_ROOT, 'public', 'posts', post_id.to_s, @post.name)
    FileUtils.mkdir_p tar_dir
    
    # copy in the images
    @post.ordered_links.each do |link|
      img_path = link.image.path(@post.thumbnail_dimension_name)
      FileUtils.cp(img_path, tar_dir)
    end
    
    # write the markup
    html_file = File.open(File.join(tar_dir, '_index.html'), 'w') { |file| file.puts rendered_template }

    # create the archive
    system "tar czf #{tar_dir}.tgz -C #{File.join(RAILS_ROOT, 'public', 'posts', post_id.to_s)} #{@post.name}"
    
    # establish links and update status
    @post.links = @post.ordered_links
    Link.update_all("status = 'live'", "post_id = #{@post.id}")
  end
end