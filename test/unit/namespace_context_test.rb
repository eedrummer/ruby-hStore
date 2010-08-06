require 'test/test_helper'

class NamespaceContextTest < Test::Unit::TestCase
  context "A NamespaceContext" do
    setup do
      fixture_file = File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'allergy1.xml'))
      ng = Nokogiri::XML(fixture_file)
      @ctx = NamespaceContext.new(ng.root, 'a' => 'http://projecthdata.org/hdata/schemas/2009/06/allergy',
				  'core' => 'http://projecthdata.org/hdata/schemas/2009/06/core')
    end

    should 'find a single node' do
      allergy_type = @ctx.first('/a:allergy/a:type')
      assert allergy_type
      assert_equal 'SNOMEDCT', allergy_type.attr('codeSystem')
    end

    should 'find a node set' do
      address = @ctx.evaluate('/a:allergy/core:informationSource/core:author/core:address')
      assert address
      assert_equal 2, address.size
    end

    should 'return nil when it can not find something' do
      foo = @ctx.first('/a:foo')
      assert foo.nil?
    end
  end
end
