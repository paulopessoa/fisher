require 'pdf-reader'
require 'open-uri'

URL_PREFIX = "http://dpmm.mb/bpm/"
LOCAL_PREFIX = "#{File.expand_path(File.dirname(__FILE__))}"

SEARCH_STRING = ARGV.join(" ")

def search(uri, local=false)
  unless local
    puts "#{uri} - Remote searching..."
    io     = open('http://dpmm.mb/bpm/bpm172016.pdf')
    reader = PDF::Reader.new(io)
  else
    puts "#{uri} - Local searching..."
    reader = PDF::Reader.new(uri)
  end
  # puts "INFO=#{reader.info}"

  page = reader.page(334)
  # reader.pages.each do |page|
    found_lines = []
    n=0
    page.text.scan(/^.+/) do |line|
      n+=1
    # text.scan(SEARCH_STRING) do |found|
      found_lines << "page #{page.number} found line ##{n} = #{line}" unless line.scan(/#{SEARCH_STRING}/i).empty?
    end
    # puts "page #{page.number} found nothing" if found_lines.empty?
    print "." if found_lines.empty?
    print "\n" if (page.number%100 == 0)
    unless found_lines.empty?
      puts "\n"; puts found_lines
    end
  # end
end

def search_tomos
  (1..24).each do |x|
    url = "#{URL_PREFIX}bpm#{x}2016.pdf"
    search(url)
  end
end

def search_file
  search("#{LOCAL_PREFIX}\\fisher_files\\bpm172016.pdf", true)
end

# search_tomos
search_file

puts "FIM"