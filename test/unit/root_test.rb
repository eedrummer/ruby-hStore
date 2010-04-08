require 'test/test_helper'

class RootTest < HDataTest
  context "The root of an hData Record" do
    setup do      
      @record = Record.create
    end
    
    should "return a response to a GET request" do
      get "/records/#{@record.id}"
      assert last_response.ok?
    end
    
    should "not allow a PUT" do
      put "/records/#{@record.id}"
      assert_equal 405, last_response.status
    end
    
    context "when receiving a POST" do
      should "not allow an incomplete request" do
        post "/records/#{@record.id}", {:type => 'extension'}
        assert_equal 400, last_response.status
      end
      
      should "allow the registration of a new extension" do
        post "/records/#{@record.id}", {:type => 'extension', :typeId => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', 
                                        :requirement => 'mandatory'}
        assert_equal 201, last_response.status
        @record.reload
        extension = @record.extensions.find_by_type_id('http://projecthdata.org/hdata/schemas/2009/06/allergy')
        assert extension
        assert_equal 'mandatory', extension.requirement
      end
      
      should "not allow the registration of a duplicate extension" do
        @record.extensions.create(:type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', :requirement => 'mandatory')
        post "/records/#{@record.id}", {:type => 'extension', :typeId => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', 
                   :requirement => 'mandatory'}
        assert_equal 409, last_response.status
      end
      
      should "allow the creation of a new section" do
        @record.extensions.create(:type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', :requirement => 'mandatory')
        post "/records/#{@record.id}", {:type => 'section', :typeId => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', 
                                        :path => 'allergies', :name => 'Allergies'}
        assert_equal 201, last_response.status
      end
    end
    
    should "provide a root.xml document describing the extensions and sections" do
      @record.extensions.create(:type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', :requirement => 'mandatory')
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
      
      get "/records/#{@record.id}/root.xml"
      assert last_response.ok?
      doc = Nokogiri::XML.parse(last_response.body)
      extension_element = doc.xpath('//hrf:root/hrf:extensions/hrf:extension[text()="http://projecthdata.org/hdata/schemas/2009/06/allergy"]', 
                                   {'hrf' => "http://projecthdata.org/hdata/schemas/2009/06/core"})
      assert !extension_element.empty?
      section_element = doc.xpath('//hrf:root/hrf:sections/hrf:section[@name="Allergies"]', {'hrf' => "http://projecthdata.org/hdata/schemas/2009/06/core"})
      assert !section_element.empty?
    end
  end
end