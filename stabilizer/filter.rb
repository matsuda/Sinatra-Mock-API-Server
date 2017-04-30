require 'rexml/document'

module Stabilizer
  module JSONFilter
    def self.registered(base)
      if base.const_defined?(:BASE_URL)
        endPoint = base.const_get(:BASE_URL)
      else
        endPoint = "*"
      end

      # ==========================================
      # before
      # ==========================================
      base.before "#{endPoint}/*" do
        puts
        puts '################################'
        puts request.path
        puts '################################'
        # puts '=========== heders ==========='
        # p env
        # dump_request_headers

        # application/jsonの場合はJSONパーサーでパースして
        # paramsをアップデート
        if request.content_type =~ /application\/json/
          puts '=========== json ==========='
          request.body.rewind  # 既に読まれているときのため
          # p request.body.read
          body = request.body.read
          unless body.nil? || body.empty?
            data = JSON.parse(body)
          end
          params.merge!(data)
        end
        puts '=========== params ==========='
        params.each do |k, v|
          puts '-----------------------------------------'
          p "key=#{k}, value=#{v}"
        end
        content_type "text/json", :charset => 'utf-8'
        puts
      end
      # ==========================================
      # after
      # ==========================================
      # base.after "#{endPoint}/*" do
      #   if request.path =~ /\.(jpeg|jpg|png)$/
      #   else
      #     content_type "text/json", :charset => 'utf-8'
      #   end
      # end
    end
  end

  module XMLFilter
    def self.registered(base)
      if base.const_defined?(:BASE_URL)
        endPoint = base.const_get(:BASE_URL)
      else
        endPoint = "*"
      end

      # ==========================================
      # before
      # ==========================================
      base.before "#{endPoint}/*" do
        puts
        puts '################################'
        puts request.path
        puts '################################'
        # puts '=========== heders ==========='
        # p env
        # dump_request_headers

        # application/xmlの場合
        if request.content_type =~ /[\w]+\/xml/
          request.body.rewind  # 既に読まれているときのため
          # p request.body.read
          body = request.body.read
          unless body.nil? || body.empty?
            # 
          end
          puts '=========== xml ==========='
          p body
          doc = REXML::Document.new(body)
          doc.elements.each('customer_request/customer/customer_address/address_a') do |element|
            p element.text
          end
        end
        puts '=========== params ==========='
        params.each do |k, v|
          puts '-----------------------------------------'
          p "key=#{k}, value=#{v}"
        end
        content_type "application/xml", :charset => 'utf-8'
        puts
      end
      # ==========================================
      # after
      # ==========================================
      # base.after "#{endPoint}/*" do
      #   if request.path =~ /\.(jpeg|jpg|png)$/
      #   else
      #     if request.env['sinatra.error']
      #     else
      #       content_type "application/xml", :charset => 'utf-8'
      #     end
      #   end
      # end
    end
  end
end
