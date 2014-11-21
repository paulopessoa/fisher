SOURCE = "source.html"
SOURCE_NEW = "source_new.txt"
DEST = "source_edited.html"

str = File.read SOURCE
dest = str.clone
str_new = File.read SOURCE_NEW

# TODO remover ultimos espacos brancos
PATT = /(\/portal_stj\/publicacao\/download.wsp\?tmp.arquivo=([0-9]+))/

i = 1
str.scan(PATT) do |link, id|
  i+=1

  patt_new = /\/file_source\/STJ\/Midias\/arquivos\/#{id}.*/
  newlink = str_new.match(patt_new)

  if !newlink.nil?
    puts "#{link} >>> #{newlink[0]}"
    dest.gsub!(link, newlink[0])
  else
    puts "Não encontrado correspondente." if newlink.nil?
  end

end

puts "#{i} links encontrados."

File.open(DEST, "wb") do |f|
  f.puts dest
end