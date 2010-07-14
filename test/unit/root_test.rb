require 'test/test_helper'

class RootTest < HDataTest
  context "The root of an hData Record" do
    setup do      
      @record = Record.create
      @allergy_namespace = 'http://projecthdata.org/hdata/schemas/2009/06/allergy'
    end
    
    should 'allow the creation of a record with a POST' do
      post "/records"
      assert_equal 201, last_response.status
      record_id = last_response.body.sub('/records/', '')
      assert Record.find(record_id)
    end
      
    
    should "return a response to a GET request" do
      get "/records/#{@record.id}"
      assert last_response.ok?
    end
    
    should "not allow a PUT" do
      put "/records/#{@record.id}"
      assert_equal 405, last_response.status
      assert_equal 'GET, HEAD, POST', last_response.headers['Allow']
    end
    
    context "when receiving a POST" do
      should "not allow an incomplete request" do
        post "/records/#{@record.id}", {:type => 'extension'}
        assert_equal 400, last_response.status
      end
      
      should "allow the registration of a new extension" do
        post "/records/#{@record.id}", {:type => 'extension', 
	      :extensionId => @allergy_namespace}
        assert_equal 201, last_response.status
        @record.reload
        extension = @record.extensions.find_by_extension_id(@allergy_namespace)
        assert extension
      end
      
      should "not allow the registration of a duplicate extension" do
        @record.extensions.create(:extension_id => @allergy_namespace)
        post "/records/#{@record.id}", {:type => 'extension', :extensionId => @allergy_namespace}
        assert_equal 409, last_response.status
      end
      
      should "allow the creation of a new section" do
        @record.extensions.create(:extension_id  => @allergy_namespace)
        post "/records/#{@record.id}", {:type => 'section', :extensionId => @allergy_namespace, 
                                        :path => 'allergies', :name => 'Allergies'}
        assert_equal 201, last_response.status
      end
    end
    
    should "provide a root.xml document describing the extensions and sections" do
      @record.extensions.create(:extension_id => @allergy_namespace)
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :extension_id  => @allergy_namespace)
      
      get "/records/#{@record.id}/root.xml"
      assert last_response.ok?
      doc = Nokogiri::XML.parse(last_response.body)
      extension_element = doc.xpath("//hrf:root/hrf:extensions/hrf:extension[text()='#{@allergy_namespace}']", 
                                    {'hrf' => "http://projecthdata.org/hdata/schemas/2009/06/core"})
      assert !extension_element.empty?
      section_element = doc.xpath('//hrf:root/hrf:sections/hrf:section[@name="Allergies"]', 
				  {'hrf' => "http://projecthdata.org/hdata/schemas/2009/06/core"})
      assert !section_element.empty?
    end
  end
end
