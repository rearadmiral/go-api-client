require "test_helper"

module GoApiClient
  class GitMaterialTest < Test::Unit::TestCase

    test "should parse a material xml with 2 changesets" do
      doc = Nokogiri::XML.parse %q{
  <material materialUri="https://go.thoughtworks.com/go/api/materials/18170.xml" type="GitMaterial" url="https://studios-scm.thoughtworks.com/saas" branch="master">
    <modifications>
      <changeset changesetUri="http://localhost:8153/go/api/materials/1/changeset/9f77888d7a594699894a17f4d61fc9dfac3cfb74.xml">
        <user><![CDATA[osito <osito@bonito.com>]]></user>
        <checkinTime>2012-02-21T15:42:30+05:30</checkinTime>
        <revision><![CDATA[9f77888d7a594699894a17f4d61fc9dfac3cfb74]]></revision>
        <message><![CDATA[Update README]]></message>
        <file name="README" action="modified"/>
      </changeset>
      <changeset changesetUri="http://localhost:8153/go/api/materials/1/changeset/abcd123.xml">
        <user><![CDATA[zorro <zorro@poms.net>]]></user>
        <checkinTime>2012-02-20T15:41:30+05:30</checkinTime>
        <revision><![CDATA[abcd123]]></revision>
        <message><![CDATA[fixin' the bugs]]></message>
        <file name="buggy_code.rb" action="modified"/>
      </changeset>
    </modifications>
  </material>

      }

      material = GitMaterial.new(doc.root).parse!

      assert_equal "https://studios-scm.thoughtworks.com/saas", material.repository_url
      assert_equal 2, material.commits.size
    end

  end
end
