class SourceUrl < ActiveRecord::Base
  has_many :links, :dependent => :destroy
  
  validates_presence_of :url
  validates_format_of :url, :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/ix
  validates_uniqueness_of :url
  
  def extracted_links
    html = Curl::Easy.perform(self.url) do |c|
      c.follow_location = true
      c.headers["User-Agent"]= "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)"
    end.body_str

    doc = Nokogiri::HTML(html)
    links = (doc / :a).map {|x| x[:href] }.uniq
    
    links.reject! {|x| !Link.new(:url => x).valid? } # uniqueness
    
    parent = URI.parse(self.url)
    links.map! do |x|
      begin
        parent + x
      rescue
        puts "invalid uri!"
      end
    end
    links.compact.uniq.map(&:to_s)
  end
  
end
