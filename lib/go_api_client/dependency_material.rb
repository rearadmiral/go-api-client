module GoApiClient

  class DependencyMaterial

    attr_reader :pipeline_name, :stage_name, :identifier

    def initialize(root)
      @root = root
    end

    def parse!
      @pipeline_name = @root['pipelineName']
      @stage_name = @root['stageName']
      @identifier = @root.xpath('./modifications/changeset/revision').first.content
      @root = nil
      self
    end

  end

end
