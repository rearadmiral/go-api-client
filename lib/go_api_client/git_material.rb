require_relative 'commit'

module GoApiClient

  class GitMaterial

    attr_reader :commits, :repository_url

    def initialize(root)
      @root = root
    end

    def parse!
      @repository_url = @root['url']
      @commits = @root.xpath('./modifications/changeset').collect do |changeset|
        Commit.new(changeset).parse!
      end
      @root = nil
      self
    end

  end


end
