# Adding the root dir to the load path for Ruby 1.9.2 compatiblilty
$: << File.join(File.dirname(__FILE__), '../..')

require 'test/test_helper'

class DocumentTest < HDataTest
  context "A document in an hData Record" do
    setup do
      @record = Record.create
      @record.extensions.create(:extension_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :extension_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
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
      product_element = doc.xpath('//a:allergy/a:product[text()="product0"]', 'a' => "http://projecthdata.org/hdata/schemas/2009/06/allergy")
      assert !product_element.empty?
    end

    should "update metadata when new metadata is POSTed" do
      metadata = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'metadata1.xml'), 'application/xml')
      post "/records/#{@record.id}/#{@section.path}/#{@doc.id}", {:metadata => metadata}
      assert_equal 201, last_response.status
      @doc.reload
      assert_equal 'Random Title', @doc.title
    end
    
    should "be able to delete a document" do
      delete "/records/#{@record.id}/#{@section.path}/#{@doc.id}"
      assert_equal 204, last_response.status
      assert_equal 0, @section.section_documents.count
    end
  end
end
