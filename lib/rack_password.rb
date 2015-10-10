require 'rack_password/version'
require 'hmac-sha2'
require 'cgi'

module RackPassword
  class Block
    def initialize(app, options = {})
      @app = app
      @options = {
        :key => :staging_auth,
        :code_param => :code
        }.merge options
    end

    def call(env)
      request = Rack::Request.new env

      bv = BlockValidator.new(@options, request)
      return @app.call(env) if bv.valid?

      params = request.params
      if request.post? and bv.valid_code?(params[@options[:code_param].to_s]) # If post method check :code_param value
        domain = @options[:cookie_domain]
        domain ||= request.host == 'localhost' ? '' : ".#{request.host}"
      [301, {'Location' => request.path, 'Set-Cookie' => "#{@options[:key]}=#{request.params[@options[:code_param].to_s]}; domain=#{domain}; expires=30-Dec-2039 23:59:59 GMT"}, ['']] # Redirect if code is valid
      elsif request.get? && valid_token?(params['token'], params['valid_until'])
        [301, {'Location' => request.path, 'Set-Cookie' => "#{@options[:key]}_token=#{params['token']}@#{@options[:key]}_time#{CGI.escape(params['valid_until'])}; domain=#{domain}; expires=#{params['valid_until']}"}, ['']] # Redirect if token & time_until are valid
      elsif request.get? && bv.valid_code?(params['code'].to_s)
        success_token_response
      else
        success_rack_response
      end
    end

    def success_rack_response
      [200, {'Content-Type' => 'text/html'}, [read_success_view]]
    end

    def success_token_response
      valid_until = (Time.now.utc + 5 * 60).to_s
      token = time_token.generate(valid_until)
      [200, {'Content-Type' => 'text/html'}, ["?token=#{token}&valid_until=#{CGI.escape(valid_until)}"]]
    end

    private

    def valid_token?(token, valid_until)
      return false if token.nil? || valid_until.nil?
      token && valid_until && time_token.valid?(token, valid_until)
    end

    def time_token
      @time_token ||= TimeToken.new(@options[:auth_codes])
    end

    def read_success_view
      @success_view ||= File.open(File.join(File.dirname(__FILE__), "views", "block_middleware.html")).read
    end
  end

  class BlockValidator
    attr_accessor :options, :request

    def initialize(options, request)
      @options = options
      @request = request
    end

    def valid?
      valid_path? || valid_code?(@request.cookies[@options[:key].to_s]) || valid_ip? || valid_token?
    end

    def valid_ip?
      return false if @options[:ip_whitelist].nil?
      @options[:ip_whitelist].include? @request.ip.to_s
    end

    def valid_path?
      match = @request.path =~ /\.xml|\.rss|\.json/ || @request.path =~ @options[:path_whitelist]
      !!match
    end

    def valid_code?(code)
      return false if @options[:auth_codes].nil?
      @options[:auth_codes].include? code
    end

    def valid_token?
      token_cookie = @request.cookies["#{@options[:key]}_token"]
      return false if token_cookie.nil?
      token, valid_until = token_cookie.split("@#{@options[:key]}_time")
      return false if token.nil? || valid_until.nil?
      TimeToken.new(@options[:auth_codes]).valid?(token, CGI.unescape(valid_until))
    end
  end

  class TimeToken
    attr_accessor :code

    def initialize(auth_codes)
      @code = auth_codes.join(',')
    end

    def generate(valid_until)
      hmac.update("time=#{valid_until}").hexdigest
    end

    def valid?(token, time)
      return false if token.nil? || time.nil? || token != generate(time)
      Time.parse(time) >= Time.now.utc
    end

    private

    def hmac
      HMAC::SHA256.new(code)
    end
  end
end
