require 'test/test_helper'

class DASTest < HDataTest
  context 'When an hData record is working with a DAS it' do
    setup do
      FakeWeb.register_uri(:get, "http://fakedas.local/.well-known/hostmeta", :response => 'test/fixtures/das_hostmeta.response')
      FakeWeb.register_uri(:post, "http://fakedas.local/host/resources", :response => 'test/fixtures/das_resource_details.response')
      FakeWeb.register_uri(:post, "http://fakedas.local/token", :response => 'test/fixtures/das_token.response')
      FakeWeb.register_uri(:post, "http://fakedas.local/host/validate_token", :response => 'test/fixtures/das_failed_validation.response')

      @record = Record.create
      @record.extensions.create(:type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', :requirement => 'mandatory')
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
      @section = @record.sections.find_by_path('allergies')
      @doc = SectionDocument.new(:title => 'Test Document')
      fixture_file = File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'allergy1.xml'))
      @doc.create_document(fixture_file.read, 'allergy1.xml', 'application/xml')
      @section.section_documents << @doc
    end
    
    should 'allow a DAS to be registered' do
      post "/records/#{@record.id}/add_das", {:das_url => 'http://fakedas.local'}
      rec = Record.find(@record.id)
      assert_equal 302, last_response.status
      assert_equal 'test_client', rec.discovery_authorization_service.client_id
    end
    
    should 'handle the redirect from the DAS' do
      @record.create_discovery_authorization_service(:host_token_uri => 'http://fakedas.local/token', :client_id => 'test_client')
      get "/records/#{@record.id}/am_redirect?code=1234"
      rec = Record.find(@record.id)
      assert_equal 302, last_response.status
      assert_equal 'super_sekret', rec.discovery_authorization_service.access_token
    end
    
    should 'protect a resource' do
      @record.create_discovery_authorization_service(:host_token_uri => 'http://fakedas.local/token', :client_id => 'test_client',
                                                     :host_token_validation_url => "http://fakedas.local/host/validate_token", :access_token => '1234',
                                                     :das_uri => "http://fakedas.local")
      get "/records/#{@record.id}/allergies"
      assert_equal 401, last_response.status
    end

    should 'protect a resource from a bad oauth token' do 
      @record.create_discovery_authorization_service(:host_token_uri => 'http://fakedas.local/token', :client_id => 'test_client',
                                                     :host_token_validation_url => "http://fakedas.local/host/validate_token", :access_token => '1234',
                                                     :das_uri => "http://fakedas.local")
      get "/records/#{@record.id}/allergies?oauth_token=garbage"
      assert_equal 403, last_response.status
    end
  end
end
