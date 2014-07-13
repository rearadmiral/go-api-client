require "test_helper"

module GoApiClient
  class PipelineTest < Test::Unit::TestCase

    def setup
      stub_request(:get, "http://localhost:8153/go/api/pipelines/defaultPipeline/1.xml").to_return(:body => file_contents("pipelines_1.xml"))
      stub_request(:get, "http://localhost:8153/go/api/pipelines/defaultPipeline/2.xml").to_return(:body => file_contents("pipelines_with_pipeline_materials.xml"))
    end

    test "should fetch the pipeline xml and populate itself" do
      link = "http://localhost:8153/go/api/pipelines/defaultPipeline/1.xml"
      pipeline = GoApiClient::Pipeline.from(link)

      assert_equal "1", pipeline.label
      assert_equal 99, pipeline.counter
      assert_equal "defaultPipeline", pipeline.name
      assert_equal "http://localhost:8153/go/api/pipelines/defaultPipeline/1.xml", pipeline.url
      assert_equal ["Update README", "Fixed build"], pipeline.materials.map { |material| material.commits.collect(&:message) }.flatten
      assert_equal "urn:x-go.studios.thoughtworks.com:job-id:defaultPipeline:1", pipeline.identifier
      assert_equal Time.parse('2012-02-23 11:46:15 UTC'), pipeline.schedule_time
    end

    test "should return a list of authors from the first stage" do
      link = "http://localhost:8153/go/api/pipelines/defaultPipeline/1.xml"
      pipeline = GoApiClient::Pipeline.from(link)
      author_foo = Atom::Author.new(nil, :name => 'foo', :email => 'foo@example.com', :uri => 'http://foo.example.com')
      author_bar = Atom::Author.new(nil, :name => 'bar', :email => 'bar@example.com', :uri => 'http://bar.example.com')

      pipeline.stages << OpenStruct.new(:authors => [author_foo, author_bar])
      assert_equal [author_foo, author_bar], pipeline.authors
    end

    test "should parse pipeline materias" do
      link = 'http://localhost:8153/go/api/pipelines/defaultPipeline/2.xml'
      pipeline = GoApiClient::Pipeline.from(link)

      assert_equal 1, pipeline.materials.size
      assert_equal 1, pipeline.dependencies.size

    end

  end
end
