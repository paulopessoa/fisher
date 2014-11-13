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

  def self.fish_file(url)
    # url path de um arquivo
    if save_url(url, nil)
      puts "Arquivo encontrado: '#{url}'"
    else
      puts "Nenhum arquivo encontrado."
    end
  rescue Exception => e
    puts e.message
    # puts e.backtrace.inspect
  end


  # Pega imagens de uma pagina a partir da URL
  def self.fish_images(url)
    contents = URI.parse(url).read
    # puts contents
    i=0
    contents.scan(/(<img.*src=\")(.*)\">/) do |tag, path|
      # puts path
      filename = path[path.rindex('/')+1..-1]
      save_url(path, filename)
      i+=1
    end
    puts "#{i} arquivos encontrados."
  rescue Exception => e
    puts e.message
    # puts e.backtrace.inspect
  end


  # Pega imagens de um css
  def self.fish_css(url)
    contents = URI.parse(url).read
    i=0
    contents.scan(/url\(\"?(.*)\"?\)/) do |path|
      path = path.to_s.gsub("\"","").gsub("[","").gsub("]","").gsub("\\","")
      path = "http://www.stjunior.stj.jus.br#{path.to_s}"

      filename = path["#{path}".rindex('/')+1..-1]
      save_url(path, filename)
      i+=1
    end
    puts "#{i} arquivos encontrados."
  rescue Exception => e
    puts e.message
    puts e.backtrace.inspect
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

  # Salva arquivo a partir da URL
  def self.save_url(url, filename)

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
        if !io.meta["content-disposition"].nil?
          filename = io.meta["content-disposition"].scan(/filename=\"(.*)\"/)[0][0]
        else
          puts "URL #{url} não é um arquivo."
          return false
        end
      end
      filename = "#{PATH_TO}#{filename}"

      File.open(filename,"wb") do |f|
        # if f.size > 0
          f.puts io.read
        # else
        #   false
        # end
      end
    end

    puts "Peguei #{filename}"
    true
  rescue Exception => e
    puts "Erro salvando URL #{url}: #{e.message}"
    e.backtrace.inspect
  end

end

# PRINCIPAL
# Fisher.fish_file "http://www.stjunior.stj.jus.br/portal_stj/admin/fotografias/cad_fotografias_download.wsp?tmp.id=334&tmp.tamanho=amostra"
# Fisher.fish_images "http://www.stjunior.stj.jus.br/portal_stj/publicacao/engine.wsp?tmp.area=1094"
# Fisher.fish_css "http://www.stjunior.stj.jus.br/portal_stj/site/css/18_default.css"
# Fisher.fish_css "http://www.stjunior.stj.jus.br/portal_stj/site/css/14_default.css"
