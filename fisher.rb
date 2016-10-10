# encoding: utf-8
require 'fileutils'
require 'open-uri'

#1. capturar html da pagina
#2. capturar urls com as extensoes (regexp)
#3. monta nome de arquivos
#4. salvar binario do arquivo
#5. voltar para #1 (loop)
#6. finish. ruby champion!
module Fisher

  PATH_TO = "#{Dir.pwd}/fisher_files/";
  IMG_REGEX = /<img.*src=\"(.*?)\"/;

  def self.fish_file(url)
    # url path de um arquivo
    if save_url(url)
      puts "Arquivo encontrado: '#{url}'"
    else
      puts "Nenhum arquivo encontrado."
    end
  end


  # Pega imagens de uma pagina a partir da URL
  def self.fish_images(url)
    fish(url, IMG_REGEX) do |path|
      if save_url(path)
        puts "***Peguei :)"
      else
        puts "***Não peguei :|"
      end
    end
  end


  # Pega imagens de um css
  def self.fish_css(url)
    fish(url, /url\(\"?(.*)\"?\)/) do |path|
      path = path.to_s.gsub("\"","").gsub("[","").gsub("]","").gsub("\\","")
      path = "http://www.stjunior.stj.jus.br#{path.to_s}"

      filename = path["#{path}".rindex('/')+1..-1]
      save_url(path, filename)
      i+=1
    end
  end

  # Pega conteudo de links
  def self.fish_links(url)
    contents = URI.parse(url).read
    i=0
    contents.scan(/<a.+?href=\"(.+?)\"/) do |path|
      path = path.to_s.gsub("\"","").gsub("[","").gsub("]","").gsub("\\","").to_s.strip

      if (!path.scan(/\.[\w]{3}$/).empty?) #tem extensao
        filename = path["#{path}".rindex('/')+1..-1]
      end

      if path != "#" and !path.include?("http")
        save_url("http://www.stjunior.stj.jus.br#{path}", filename)
        # puts path
      end
      i+=1
    end
    puts "#{i} arquivos encontrados."
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end

  private

  def self.fish(url, pattern_to_find)
    contents = URI.parse(url).read
    i=0
    contents.scan(pattern_to_find) do |path|
      yield path.join
      i+=1
    end
    puts "#{i} arquivos encontrados."
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
  end

  # Salva arquivo a partir da URL
  def self.save_url(url)
    puts "URL:#{url}"

    filename = url[url.rindex('/')+1..-1] #nome do arquivo no path
    # puts "FILENAME:#{filename}"

    if !File::directory?(PATH_TO)
      if !FileUtils.mkdir_p(PATH_TO)
        puts "Diretorio nao pode ser criado: #{PATH_TO}"
        return false
      end
    end

    if File::exists?(filename.to_s)
      puts "Ja existe arquivo: #{PATH_TO}#{filename}"
      return false
    end

    open(url) do |io|
      if filename.nil?
        puts "URL não é um arquivo."
        return false
      end
      filename = "#{PATH_TO}#{filename}"

      if !save_file(io, filename)
        false
      end
    end
    true

  rescue Exception => e
    puts "[ERROR] Erro salvando URL: #{e.message}"
    e.backtrace.inspect
    false
  end

  def self.save_file(io, filename)
    File.open(filename,"wb") do |f|
      # if f.size > 0
        f.puts io.read
      # else
      #   false
      # end
    end
    true

  rescue Exception => e
    puts "[ERROR] Erro salvando arquivo: #{e.message}"
    e.backtrace.inspect
    false
  end

end

# PRINCIPAL
# Fisher.fish_images "http://dsm.mb/organograma"
Fisher.fish_file "http://dpmm.mb/bpm/bpm172016.pdf"
Fisher.fish_file "http://dpmm.mb/bpm/bpm182016.pdf"
