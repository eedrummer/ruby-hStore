require 'test/test_helper'

class SectionTest < HDataTest
  context "A section of an hData Record" do
    setup do
      @record = Record.create
      @record.extensions.create(:type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', :requirement => 'mandatory')
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
    end
    
    should 'return an ATOM feed at the root' do
      get "/records/#{@record.id}/allergies"
      assert last_response.ok?
    end
    
    should 'allow the delete of a section' do
      delete "/records/#{@record.id}/allergies"
      assert_equal 204, last_response.status
      assert !@record.sections.path_exists?('allergies')
    end
    
    should 'allow the POSTing of a section document' do
      upload_file = Rack::Test::UploadedFile.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'allergy1.xml'), 'application/xml')
      post "/records/#{@record.id}/allergies", {:type => 'document', :content => upload_file}
      assert_equal 201, last_response.status
      section = @record.sections.find_by_path('allergies')
      assert_equal 1, section.documents.count
      assert_equal "http://localhost:4567/allergies/#{section.documents.first.id}", last_response.body
    end
    
  end
end