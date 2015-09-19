require 'date'
require 'json'
require 'chartkick'

class CoffeePost
  METADATA_INDICATOR = "---"

  attr_reader :title, :subject, :date, :tags, :hours, :content

  def initialize(title, metadata, content)
    @title = title
    @subject = metadata[:subject]
    @date = metadata[:date]
    @tags = metadata[:tags]
    @hours = metadata[:hours].to_f
    @content = content
  end

  def to_json
    post_hash = {}
    instance_variables.each do |ivar|
      key = ivar.to_s.gsub("@", "")
      post_hash[key] = instance_variable_get(ivar)
    end
    post_hash.to_json
  end

  def self.get_coffee(limit = nil)
    posts = []

    post_count = 0
    Dir.foreach(POSTS_PATH) do |item|
      next if item == '.' or item == '..'
      posts << CoffeePost.build_post(item)
      post_count += 1
      break if limit && post_count >= limit
    end

    posts    
  end

  def self.build_post(post_filename)
    full_path = "#{POSTS_PATH}#{post_filename}"
    if File.exists?(full_path)
      the_file = File.open(full_path).read
      open_meta = false
      content = ""
      metadata = {}
      the_file.each_line do |line|
        open_meta = !open_meta if line.match(/^---/)
        if open_meta
          meta_line = line.split(": ")
          key = meta_line.first.to_sym
          value = meta_line.last.gsub("\n", "")
          case key
          when :tags
            value = value.split(" ")
          when :date
            value = date_to_date(value) # convert to Ruby Date
          end
          metadata[key] = value
        else
          content += line
        end

      end
      content = content.gsub("\n", "")
      content = content.gsub(METADATA_INDICATOR, "")

      CoffeePost.new(post_filename, metadata, content)
    end
  end

  def self.date_to_date(str_date)
    date_arr = str_date.gsub("\n", "").split("-")
    Date.new(date_arr[0].to_i, date_arr[1].to_i, date_arr[2].to_i)
  end
end