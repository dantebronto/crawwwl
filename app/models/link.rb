class Link < ActiveRecord::Base
  belongs_to :source_url
  belongs_to :post
  
  serialize :images
  
  validates_uniqueness_of :url
  validates_presence_of :url
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
  
  def self.style_hash 
    {
      :extra_small => "60x50>#",
      :small => "96x80>#",
      :medium => "120x100>#",
      :large => "144x120>#",
      :extra_large => "180x150>#",
      :huge => "192x160>#"
    }
  end
  
  has_attached_file :image, :styles => self.style_hash, :default_url => "/images/missing.png"
  
  %w(bad good uncrawwwled crawwwled live).each do |s, page| 
    named_scope s, 
      :order => "created_at desc",
      :conditions => { :status => s.to_s }
  end
  
  def self.create_from_params(params)
    params[:bad_links].each  {|l| self.create(:url => l, :status => "bad") } if params[:bad_links]
    
    if params[:good_links]
      params[:good_links].each do |l| 
        good_link = self.create(:url => l)
        Delayed::Job.enqueue LinkJob.new(good_link.id) if good_link.id
      end 
    end
  end
  
  def self.list(params)
    hsh = {:page => params[:page], :per_page => 30, :order => "updated_at desc" }
    case params[:status]
      when "good"
        return Link.good.paginate(hsh)
      when "bad"
        return Link.bad.paginate(hsh)
      when "uncrawwwled"
        return Link.uncrawwwled.paginate(hsh)
      else                  
        return Link.crawwwled.paginate(hsh)
    end
  end
  
  def assign_image_and_description(params) # returns boolean
    img = params[:link][:image]
    return false unless img
    desc = params[:link][:description]
    self.description = desc if desc
    
    if img == "/images/cancel.png"
      self.status = "bad"
    else
      self.status = "good"
      
      if img.is_a? String # image is a selection from those that are aleardy crawwwled
        file = File.join(RAILS_ROOT, "public", img)
        return false unless File.exist?(file)
        self.image.assign(File.open(file))
        self.original_image_path = img
      else # image was uploaded and params[:image].is_a?(TempFile)
        self.handle_upload(img)
      end
    end
    self.save
  end
  
  def self.more(params)
    good.all(
      :limit => params[:number].to_i, 
      :conditions => [ "id NOT IN (?)", params[:post_order].split(',') ],
      :order => "RANDOM()"
    )
  end
  
  def recrop_image(opts={})
    return if opts.blank?
    x1 = opts[:x1].to_i
    y1 = opts[:y1].to_i
    crop_width = opts[:w].to_i
    crop_height = opts[:h].to_i

    img = Magick::Image.read(File.join(RAILS_ROOT, 'public', self.original_image_path)).first
    img = img.crop(x1, y1, crop_width, crop_height) # values from thumbnailer script
    img.write(self.image.path) 
    file = File.open(self.image.path)
    self.image.assign(file)
    self.save
  rescue => e
    logger.warn "something went wrong in recrop_image for link ##{self.id}:"
    logger.warn e
  end
  
  protected
  
  def handle_upload(tempfile)
    self.image.assign(tempfile)
    self.save # paperclip creates the needed dir and file on save
    path = File.join(RAILS_ROOT, 'public', 'images', 'link', self.id.to_s)
    FileUtils.mkdir_p(path)
    FileUtils.cp(self.image.path, path)
    self.original_image_path = File.join('/images', 'link', self.id.to_s, self.image.original_filename)
    
    if self.images.nil?
      self.images = [self.original_image_path]
    else
      self.images << self.original_image_path
    end
    self.images.uniq!
  end
  
end