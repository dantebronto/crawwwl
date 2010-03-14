class Post < ActiveRecord::Base
  
  has_many :links
  
  validates_numericality_of :columns, :greater_than => 0
  validates_numericality_of :total_links, :greater_than => 0
  validates_presence_of :thumbnail_dimension, :columns, :total_links, :name
  validates_uniqueness_of :name
  
  def self.list(page=1)
    self.paginate({:page => page, :per_page => 10, :order => "created_at desc"})
  end
  
  def self.sorted_thumbnail_dimensions # for select box
    Link.style_hash.map do |k,v| 
      [ k.to_s.gsub('_', ' '), v.gsub('>#', '') ] 
    end.sort_by { |x| x.last.split('x').first.to_i }
  end
  
  def published?
    File.exist?(File.join(RAILS_ROOT, 'public', 'posts', self.id.to_s, "#{self.name}.tgz"))
  end
  
  def thumbnail_dimension_name
    Link.style_hash.invert["#{self.thumbnail_dimension}>#"]
  end
  
  def thumbnail_width
    thumbnail_dimension.split('x').first
  end
  
  def thumbnail_height
    thumbnail_dimension.split('x').last
  end
  
  def ordered_links
    if self.link_order.blank?
      return Link.good.all(:limit => self.total_links, :order => "RANDOM()")
    end
    
    id_ara = link_order.split(',')
    the_links = Link.all(:conditions => ["id in (?)", id_ara])
    
    id_ara.map do |id| 
      the_links.select {|link| link.id == id.to_i }.compact.first
    end
  end
  
end