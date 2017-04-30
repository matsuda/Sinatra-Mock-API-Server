module Stabilizer
  module OutputHelper
    def dump_request_headers
      request.env.each { |k,v| puts "#{k} = #{v}"}
    end

    def request_headers
      request.env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
    end

    def render_error(message = "server error")
      {:status => '10', :messages => [message], :results => {}}.to_json
    end

    def render_output(path, format = "json")
      dir, filename = File.split(path)
      ext = File.extname(filename)
      basename = File.basename(filename, ext)
      file_path = File.join('views', dir, "#{basename}.#{format}")
      puts "output file path=#{file_path}"
      File.read(file_path)
    end

    def render_output_file(file, dir, format = 'json')
      if dir
        path = File.join('views', dir, "#{file}.#{format}")
      else
        path = File.join('views', "#{file}.#{format}")
      end
      File.read(path)
    end

    def render_html_file(file, dir = nil)
      render_output_file(file, dir, 'html')
    end

    def write_data(filename, date)
      path = File.join(File.expand_path('../uploads', __FILE__), filename)
      File.open(path, 'wb') { |f| f.write(date) }
      puts "save to #{path}"
    end
  end

  module JSONOutputHelper
    include OutputHelper
    def render_json(base_url)
      path = request.path
      if path =~ %r{#{base_url}/(.*)}
        path = $1
      end
      render_output(path)
    end
    def render_json_file(file, dir = nil)
      render_output_file(file, dir)
    end
  end

  module XMLOutputHelper
    include OutputHelper
    def render_xml(base_url)
      path = request.path
      if path =~ %r{#{base_url}/(.*)}
        path = $1
      end
      render_output(path, "xml")
    end
    def render_xml_file(file, dir = nil)
      render_output_file(file, dir, 'xml')
    end
  end
end
