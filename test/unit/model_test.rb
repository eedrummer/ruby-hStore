require 'test/test_helper'

class RecordTest < Test::Unit::TestCase
  context "A record" do
    setup do      
      @record = Record.create
      @record.extensions.create(:type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy', :requirement => 'mandatory')
      @record.extensions.create(:type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/medication', :requirement => 'mandatory')
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :type_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
    end
    
    should 'find an extension by type_id' do      
      extension = @record.extensions.find_by_type_id('http://projecthdata.org/hdata/schemas/2009/06/allergy')
      assert extension
      assert_equal 'http://projecthdata.org/hdata/schemas/2009/06/allergy', extension.type_id
      assert_nil @record.extensions.find_by_type_id('http://splat.com')
    end
    
    should 'know if an extension is registered under a type_id' do
      assert @record.extensions.type_id_registered?('http://projecthdata.org/hdata/schemas/2009/06/allergy')
      assert !@record.extensions.type_id_registered?('http://foo.org')
    end
    
    should 'know if a section is registered at a particular path' do
      assert @record.sections.path_exists?('allergies')
      assert !@record.sections.path_exists?('person_information')
    end
    
    should 'be able to find a section by path' do
      section = @record.sections.find_by_path('allergies')
      assert section
      assert_equal 'Allergies', section.name
    end
  end
end