require 'test/test_helper'

class SectionTest < HDataTest
  context "A section of an hData Record" do
    setup do
      @record = Record.create
      @record.extensions.create(:extension_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :extension_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
    end
    
    should 'return an ATOM feed at the root' do
      get "/records/#{@record.id}/allergies"
      assert last_response.ok?
    end
    
    should 'allow the delete of a section' do
      delete "/records/#{@record.id}/allergies"
      assert_equal 204, last_response.status
      @record.reload
      assert !@record.sections.path_exists?('allergies')
    end
    
    should 'allow the POSTing of a section document' do
      upload_file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'allergy1.xml'), 'application/xml')
      post "/records/#{@record.id}/allergies", {:type => 'document', :content => upload_file}
      assert_equal 201, last_response.status
      section = @record.sections.find_by_path('allergies')
      assert_equal 1, section.section_documents.count
      assert_equal "/records/#{@record.id}/allergies/#{section.section_documents.first.id}", last_response.body
    end
    
    should 'allow the POSTing of a section document and metadata' do
      section_document = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'allergy1.xml'), 'application/xml')
      metadata = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'metadata1.xml'), 'application/xml')
      post "/records/#{@record.id}/allergies", {:type => 'document', :content => section_document, :metadata => metadata}
      assert_equal 201, last_response.status
      section = @record.sections.find_by_path('allergies')
      assert_equal 1, section.section_documents.count
      assert_equal "/records/#{@record.id}/allergies/#{section.section_documents.first.id}", last_response.body
      doc = section.section_documents.first
      assert_equal 'Random Title', doc.title
      assert_equal 'RandomDocumentId', doc.document_id
    end

  end
end
