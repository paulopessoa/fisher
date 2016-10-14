require 'pdf-reader'
require 'open-uri'

URL_PREFIX = "http://dpmm.mb/bpm/"
LOCAL_PREFIX = "#{File.expand_path(File.dirname(__FILE__))}"

unless ARGV[0]=="-p"
  PAGE = nil
  SEARCH_STRING = ARGV.join(" ")
else
  PAGE = ARGV[1];
  SEARCH_STRING = ARGV.drop(2).join(" ")
end

def search(uri, local=false)
  unless local
    puts "#{uri} - Remote searching... '#{SEARCH_STRING}'"
    io     = open('http://dpmm.mb/bpm/bpm172016.pdf')
    reader = PDF::Reader.new(io)
  else
    puts "#{uri} - Local searching... '#{SEARCH_STRING}'"
    reader = PDF::Reader.new(uri)
  end
  # puts "INFO=#{reader.info}"

  if PAGE
    page = reader.page(PAGE)
    search_in_page(page)
  else
    reader.pages.each do |page|
      search_in_page(page)
    end
  end

end

def search_in_page(page)
  found_lines = []
  n=0
  page.text.scan(/^.+/) do |line|
    n+=1
    found_lines << "page #{page.number} found line ##{n} = #{line}" unless line.scan(/#{SEARCH_STRING}/i).empty?
  end
  # puts "page #{page.number} found nothing" if found_lines.empty?
  print "." if found_lines.empty?
  print "\n" if (page.number%100 == 0)
  unless found_lines.empty?
    puts "\n"; puts found_lines
  end
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

if SEARCH_STRING.nil? or SEARCH_STRING.empty?
  puts "INFO: Um parâmetro de busca deve ser informado. ('case insensitive')"
  puts "@> ruby spy.rb <parametro de texto para busca>"
  puts "@> ruby spy.rb -p <numero-pagina> <parametro de texto para busca>"
  exit 0
end

# search_tomos
search_file

puts "FIM"