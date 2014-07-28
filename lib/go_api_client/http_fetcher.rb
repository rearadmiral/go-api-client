require 'net/http'
require 'net/https'

module GoApiClient
  class HttpFetcher

    attr_reader :status_reporter

    class StatusReporter
      def on_request_start(url, options)
        @start_time = Time.now
        puts "[GoApiClient] fetching #{url}"
      end

      def on_request_success(response, url, options)
        seconds = Time.now - @start_time
        puts "[GoApiClient] fetched #{url} in #{seconds}sec"
      end
    end

    class QuietStatusReporter
      def on_request_start(*args); end
      def on_request_success(*args); end
    end

    def initialize(options={})
      @username = options[:username]
      @password = options[:password]
      @status_reporter = options[:status_reporter] || ENV['QUIET'] ? QuietStatusReporter.new : StatusReporter.new
    end

    def get(url, options={})
      uri = URI.parse(url)

      password = options[:password] || uri.password || @password
      username = options[:username] || uri.user     || @username
      params   = options[:params]   || {}

      uri.query = URI.encode_www_form(params) if params.any?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == 'https'

      status_reporter.on_request_start(uri, options)

      res = http.start do |http|
        req = Net::HTTP::Get.new(uri.request_uri)
        req.basic_auth(username, password) if username || password
        http.request(req)
      end

      case res
      when Net::HTTPSuccess
        status_reporter.on_request_success(res, uri, options.merge(:url => uri))
        return res
      end
      res.error!
    end

    def get_response_body(url, options={})
      get(url, options).body
    end
  end
end
