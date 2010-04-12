require 'test/test_helper'

class DocumentTest < HDataTest
  context "A document in an hData Record" do
    setup do
      @record = Record.create
      @record.extensions.create(:type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', :requirement => 'mandatory')
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
      @section = @record.sections.find_by_path('allergies')
      @doc = SectionDocument.new(:title => 'Test Document')
      fixture_file = File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'allergy1.xml'))
      @doc.create_document(fixture_file.read, 'allergy1.xml', 'application/xml')
      @section.section_documents << @doc
    end
    
    should "provide the document contents when issued a get request" do
      get "/records/#{@record.id}/#{@section.path}/#{@doc.id}"
      assert last_response.ok?
      doc = Nokogiri::XML.parse(last_response.body)
      product_element = doc.xpath('//allergy/product[text()="Cheese"]')
      assert !product_element.empty?
    end
    
    should "be able to delete a document" do
      delete "/records/#{@record.id}/#{@section.path}/#{@doc.id}"
      assert_equal 204, last_response.status
      assert_equal 0, @section.section_documents.count
    end
  end
end