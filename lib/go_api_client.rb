require 'nokogiri'

require 'net/http'

require 'go_api_client/version'
require 'go_api_client/helpers'
require 'go_api_client/http_fetcher'

require 'go_api_client/atom'
require 'go_api_client/pipeline'
require 'go_api_client/stage'
require 'go_api_client/job'
require 'go_api_client/commit'
require 'go_api_client/dependency_material'
require 'go_api_client/user'


module GoApiClient

  def self.runs(options)
    options = ({:protocol => 'http', :port => 8153, :username => nil, :password => nil, :latest_atom_entry_id => nil, :pipeline_name => 'defaultPipeline'}).merge(options)

    http_fetcher = GoApiClient::HttpFetcher.new(:username => options[:username], :password => options[:password])

    feed_url = "#{options[:protocol]}://#{options[:host]}:#{options[:port]}/go/api/pipelines/#{options[:pipeline_name]}/stages.xml"

    feed = GoApiClient::Atom::Feed.new(feed_url, options[:latest_atom_entry_id])
    feed.fetch!(http_fetcher)

    pipelines = {}
    stages = feed.entries.collect do |entry|
      Stage.from(entry.stage_href, :authors => entry.authors, :pipeline_cache => pipelines, :http_fetcher => http_fetcher)
    end

    pipelines.values.each do |p|
      p.stages = p.stages.sort_by {|s| s.completed_at }
    end

    return {
      :pipelines => pipelines.values.sort_by {|p| p.counter},
      :latest_atom_entry_id => stages.empty? ? options[:latest_atom_entry_id] : feed.entries.first.id
    }
  end

  def self.build_in_progress?(options)
    raise ArgumentError("Hostname is mandatory") unless options[:host]
    options = ({:protocol => 'http', :port => 8153, :username => nil, :password => nil}).merge(options)
    http_fetcher = GoApiClient::HttpFetcher.new(:username => options[:username], :password => options[:password])
    url = "#{options[:protocol]}://#{options[:host]}:#{options[:port]}/go/cctray.xml"
    doc = Nokogiri::XML(http_fetcher.get_response_body(url))
    doc.xpath("//Project[contains(@activity, 'Building')]").count > 0
  end

  def self.build_finished?(options)
    !build_in_progress?(options)
  end

  def self.schedule_pipeline(host)
    uri = URI("http://#{host}:8153/go/api/pipelines/defaultPipeline/schedule")
    Net::HTTP.post_form(uri, {})
  end
end
