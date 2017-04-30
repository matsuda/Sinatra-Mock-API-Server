require 'sinatra/base'
require 'sinatra/cookies'
require "json"
require 'pp'
require File.expand_path('stabilizer/stabilizer', File.dirname(__FILE__))

# $ gem install thin shotgun
# $ bundle exec shotgun config.ru -o 192.168.10.178 ( -p 4567 )

class ApiServer < Sinatra::Base
  error do
    puts 'errorrrrrrrrrrrr!!!!!!!!!!!!!!!!!'
    render_error
  end

  # ==========================================
  # Routes
  # ==========================================
  # get %r{#{BASE_URL}(/v[0-9]+)*(/[\w]+)*/([\w]+).?php(\.\d)?} do
  #   # sleep 1
  #   # return 401
  #   # return 500
  #   # halt 400, {:messages => ['error 400']}.to_json
  #   render_json(BASE_URL)
  # end
  # post %r{#{BASE_URL}(/v[0-9]+)*(/[\w]+)*/?} do
  #   # sleep 3
  #   #########
  #   # error #
  #   #########
  #   # return 403
  #   # return 500
  #   # return render_output("403")
  #   # halt 400, {:messages => ['error 400']}.to_json
  #   render_xml(BASE_URL)
  # end
  # get %r{#{BASE_URL}(/v[0-9]+)*(/[\w]+)*/?} do
  #   # sleep 3
  #   #########
  #   # error #
  #   #########
  #   # return 403
  #   # return 500
  #   # return render_output("403")
  #   # halt 400, {:messages => ['error 400']}.to_json
  #   render_xml(BASE_URL)
  # end

  get "/static/*" do
    render_html_file(request.path)
  end
end

class JSONApp < ApiServer
  BASE_URL = "/api/v1"

  configure do
    helpers Stabilizer::JSONOutputHelper
    register Stabilizer::JSONFilter
    helpers Sinatra::Cookies
  end

  # ==========================================
  # get
  # ==========================================
  get %r{#{BASE_URL}/(/v[0-9]+)*(/[\w]+)*/?} do
    headers "iOS-App-Version" => "1.0.0"

    #########
    # environment
    #########
    # puts request_headers.inspect
    # p env

    #########
    # params encoding
    #########
    # params.each do |k, v|
    #   p "key=#{k}"
    #   p "before encode >>> #{v}"
    #   p "encoding >>> #{v.encoding}"
    #   p "after encode >>> #{v.encode("SJIS")}"
    # end

    # sleep 3
    #########
    # error #
    #########
    # redirect 'https://www.yahoo.co.jp'
    # return 403
    # return 500
    # return render_output("403")
    # halt 400, {:message => "error 400"}.to_json

    #########
    # Cookie
    #########
    # puts "<<<<<< cookies >>>>>"
    # request.cookies.each { |k,v| puts "#{k} = #{v}"}
    # puts "<<<<<< cookies >>>>>"
    #
    # response.set_cookie 'mock', {
    #   :value => "sinatra",
    #   :expires => (Time.now + 60*60*24*7)
    # }
    # cookies[:mock] = "sinatra"

    #########
    # maintenance
    #########
    # status 503
    # body load_maintenance_json
    # return

    render_json(BASE_URL)
  end

  get '*.html' do
    # puts '=========== heders ==========='
    # p env
    # sleep 10
    content_type "text/html", :charset => 'utf-8'
    File.read(File.join('public', 'test.html'))
  end

  get '/static/*' do
    # puts '=========== heders ==========='
    # p env
    # sleep 10
    content_type "text/html", :charset => 'utf-8'
    File.read(File.join('public', 'test.html'))
  end

  # get '/images/:file.:ext' do |file, ext|
  #   filename = "#{file}.#{ext}"
  #   path = File.join('images', filename)
  #   unless File.exist?(path)
  #     return 404
  #   end
  #   content_type "image/#{ext}"
  #   send_file path
  # end

  get '/images/*' do
    file = params[:captures][0]
    if file.nil?
      return 404
    end

    path = File.join('images', file)
    unless File.exist?(path)
      return 404
    end

    dir, filename = File.split(path)
    ext = File.extname(filename).slice(1..-1)

    content_type "image/#{ext}"
    send_file path
  end

  get '/yahoo' do
    %Q{
      <html>
      <head></head>
      <body>
      <div style="width:200px; height:400px">
      <p style="font-size:200px;"><a href="https://www.yahoo.co.jp">Yahoo!</a></p>
      </div>
      </body>
      </html>
    }
    # '<a href="https://www.yahoo.co.jp">Yahoo!</a>'
  end

  def load_maintenance_json
    File.read(File.join('views', 'maintenance.json'))
  end
end


# ==========================================
# http://zip.cgis.biz
# ==========================================
class Zip < ApiServer
  BASE_URL = "/xml"

  configure do
    helpers Stabilizer::XMLOutputHelper
    register Stabilizer::XMLFilter
  end

  get "#{BASE_URL}/zip.php" do
    if params[:zn]
      if params[:zn].length > 5
        render_output_file('zip', 'zip_search', 'php')
      elsif params[:zn].length > 0
        render_output_file('zip_multi', 'zip_search', 'php')
      else
        render_output_file('zip_empty', 'zip_search', 'php')
      end
    else
      render_output_file('zip_error', 'zip_search', 'php')
    end
  end
end


class Photo < ApiServer
  BASE_URL = "/api/v2"

  configure do
    helpers Stabilizer::JSONOutputHelper
    register Stabilizer::JSONFilter
  end

=begin
  # ===============
  # 通常のmultipartで送信
  # ===============
  post "#{BASE_URL}/user/post_photo.?:format?" do
    request.body.rewind  # 既に読まれているときのため
    # data = JSON.parse request.body.read
    # p request.body.read

    # 画像
    unless params[:imgFile] &&
           (tmpfile = params[:imgFile][:tempfile]) &&
           (name = params[:imgFile][:filename])
      # @error = "No file selected"
      return render_error("No file is uploaded")
    end

    filename = DateTime.now.strftime('%s') + File.extname(params[:imgFile][:filename])
    write_data(filename, params[:imgFile][:tempfile].read)

    render_json_file('post_photo')
    # halt 500
    # sleep 30
  end
=end

=begin
  # ===============
  # 画像をまとめてJSONで送った場合
  # ===============
  post "#{BASE_URL}/user/post_photo.?:format?" do
    # request.body.rewind  # 既に読まれているときのため
    data = JSON.parse request.body.read
    # p request.body.read

    unless data['image']
      # @error = "No file selected"
      return render_error("No file is uploaded")
    end

    binary = data["image"].unpack("m*").first
    filename = DateTime.now.strftime('%s') + '.png'
    write_data(filename, binary)

    render_json('post_photo')
  end
=end

end

class Application < Sinatra::Base
  use JSONApp
  use Zip
  use Photo
end

#######################################################
# 自己証明書を利用する
#   $ bundle exec ruby app.rb で起動
#######################################################
=begin
require 'webrick/https'
require 'openssl'

CRT_FILE_NAME = 'server.crt'
RSA_FILE_NAME = 'server.key'

# 初期起動時に鍵を自動生成する
unless File.exists?(CRT_FILE_NAME) || File.exists?(RSA_FILE_NAME)
  crt, rsa = WEBrick::Utils::create_self_signed_cert(1024, [["CN", WEBrick::Utils::getservername]], 'Generated by Ruby/OpenSSL')
  File.open(CRT_FILE_NAME, "w") { |f| f.write crt}
  File.open(RSA_FILE_NAME, "w") { |f| f.write rsa}
end

webrick_options = {
  :Port               => 8443,
  :Logger             => WEBrick::Log::new($stderr, WEBrick::Log::DEBUG),
  :SSLEnable          => true,
  :SSLVerifyClient    => OpenSSL::SSL::VERIFY_NONE,
  :SSLCertificate     => OpenSSL::X509::Certificate.new(File.open(CRT_FILE_NAME).read),
  :SSLPrivateKey      => OpenSSL::PKey::RSA.new(File.open(RSA_FILE_NAME).read)
}

# WEBrickを自力で起動させる場合、Ctrl+Cで止めるには以下のトラップコードが必要
Rack::Handler::WEBrick.run Application, webrick_options do |server|
  shutdown_proc = ->( sig ){ server.shutdown() }
  [ :INT, :TERM ].each{ |e| Signal.trap( e, &shutdown_proc ) }
end
=end


################################################
# sample
################################################

=begin

# $ gem install thin shotgun
# $ shotgun config.ru -p 4567

require 'sinatra/base'

class SampleApp < Sinatra::Base
  get '/' do
    "Hello World!"
  end

  get '/api/v2/items' do
    content_type 'application/json', :charset => 'utf-8'
    builder :items
  end
end

# SampleApp.run! :host => 'localhost', :port => 4567

=end
