require "test_helper"

module GoApiClient
  class DependencyMaterialTest < Test::Unit::TestCase

    test "should parse properly" do

      doc = Nokogiri::XML.parse <<-XML
    <material materialUri="https://go.thoughtworks.com/go/api/materials/108307.xml" type="DependencyMaterial" pipelineName="acceptance-cupcake" stageName="acceptance">
      <modifications>
        <changeset changesetUri="https://go.thoughtworks.com/go/api/stages/353017.xml">
          <checkinTime>2014-07-07T10:43:05-07:00</checkinTime>
          <revision>acceptance-cupcake/931/acceptance/1</revision>
        </changeset>
      </modifications>
    </material>
XML

      dependency = DependencyMaterial.new(doc.root).parse!
      assert_equal 'acceptance-cupcake', dependency.pipeline_name
      assert_equal 'acceptance', dependency.stage_name
      assert_equal 'acceptance-cupcake/931/acceptance/1', dependency.identifier

    end

  end
end
