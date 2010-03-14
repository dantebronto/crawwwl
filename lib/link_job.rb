class LinkJob < Struct.new(:link_id)
  
  def perform
    begin
      link = Link.find_by_id(link_id)
      get_images(link) if link
    rescue Exception => e
      link.update_attribute(:status, 'bad') if link
      puts "Uncaught exception bubbled up: \n#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")} "
    end
  end
  
  def get_images(link)
    puts "\nProcessing: #{link.url}"
    
    if link.url.downcase.match(/jpg|jpeg|gif|tiff|png|bmp^/)
      img_urls = [link.url] 
    else
      puts "\nAttempting to get html for link ##{link.id} \n\n"
      html = open(link.url)
      raise "HTML retrieval FAIL" unless html
      doc = Nokogiri::HTML(html)
      description = doc.at("title").inner_text
      img_urls = extract_image_urls(link, doc)
    end
    
    raise "No image URLs found FAIL" if img_urls.nil? or img_urls.empty?
    
    puts "Fetching #{img_urls.length} image URLs:"
    
    image_dir = File.dirname(__FILE__) + "/../public/images/link/#{link.id}/"
    FileUtils.mkdir_p image_dir
    file_ara = []
    
    img_urls.each_with_index do |img_url,i|
      break if i > 200
      filename = "#{i}_#{img_url.to_s.sub(/^.*\//,'')}"
      filename.gsub!(/\?|\+|\;|\=|\%/,'') # remove stuff that messes with rails routing
      ((i+1) % 10 == 0) ? (print i+1) : (print '.')
      local_path = image_dir + filename
      public_path = "/images/link/#{link.id}/" + filename
      
      begin
        file = open(img_url)
        File.open(local_path, 'w') {|f| f.write(file) }
        
        if File.exist?(local_path)
          the_type = image_type(local_path)
          if the_type == "unknown"
            FileUtils.rm_f(local_path)
          else
            if not local_path.downcase.end_with?(the_type) # image has no extension
              public_path = "#{public_path}#{the_type}"
              FileUtils.mv(local_path, "#{local_path}#{the_type}")
            end
            file_ara << public_path
          end
        end
      rescue => e
        puts "Saving #{filename} failed \n#{e.class}: #{e.message}\n\t#{e.backtrace.join("\n\t")}"
      end
    end
    file_ara = file_ara.to_yaml
    puts "\n#{file_ara}"
    link.update_attributes(:status => 'crawwwled', :images => file_ara, :description => description)
    puts "Done!"
  end

  def parse(uri)
    begin
      retval = URI::parse(uri)
    rescue
      retval = URI::parse(URI.escape(URI.unescape(uri))) # if escaped chars, unescape, then re-escape
    end
    retval
  end
  
  def image_type(file)
    return 'unknown' unless File.exist?(file)
    case IO.read(file, 10)
    when /^GIF8/: '.gif'
    when /^\x89PNG/: '.png'
    when /^\211PNG/: '.png' # is this valid?
    when /^\xff\xd8\xff\xe0\x00\x10JFIF/: '.jpg'
    when /^\xff\xd8\xff\xe1(.*){2}Exif/: '.jpg'
    else 'unknown'
    end
  end
  
  def open(url)
    Curl::Easy.perform(url.to_s) do |c|
      c.follow_location = true
      c.headers["User-Agent"]= "Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1)" # IE7
    end.body_str
  end
  
  def extract_image_urls(link, doc)
    image_urls = doc.search('img').map {|tag| tag[:src] || tag[:SRC] }.compact.uniq
    image_urls.map! {|img| parse(img) }
    image_urls.reject! {|img| img.is_a? String } # didn't parse; not a valid URI?
    absolute_urls = image_urls.select {|img| img.absolute? }
    relative_urls = image_urls.select {|img| img.relative? }
    parent = parse(link.url)
    relative_urls.map! {|img| parent + img } # absolutize
    (absolute_urls + relative_urls).compact.uniq.reject {|img| img.to_s == "" }
  end
  
end