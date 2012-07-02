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

    return {
      :pipelines => pipelines.values,
      :latest_atom_entry_id => stages.empty? ? options[:latest_atom_entry_id] : feed.entries.first.id
    }
  end

  def self.build_in_progress?(options)
    return false unless options[:revision]
    
    options = {:stages => [:units, :functionals]}.merge(options)
    total_stages_count = [*options[:stages]].count

    pipelines = GoApiClient.runs(options)[:pipelines]
    return false if pipelines.empty?

    pipeline = pipelines.find do |pipeline|
      pipeline.commits.map(&:revision).include?(options[:revision])
    end

    built_stages = pipeline.stages

    if built_stages.count == total_stages_count
      false
    else
      built_stages.all?(&:passed?)
    end
  end

  def self.build_finished?(options)
    !build_in_progress?(options)
  end
  
  def self.schedule_pipeline(host)
    uri = URI("http://#{host}:8153/go/api/pipelines/defaultPipeline/schedule")
    Net::HTTP.post_form(uri, {})
  end
end
