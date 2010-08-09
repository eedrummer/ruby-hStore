require 'test/test_helper'

class RecordTest < Test::Unit::TestCase
  context "A record" do
    setup do      
      @record = Record.create
      @record.extensions.create(:extension_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
      @record.extensions.create(:extension_id  => 'http://projecthdata.org/hdata/schemas/2009/06/medication')
      @record.sections.create(:name => 'Allergies', :path => 'allergies', :extension_id  => 'http://projecthdata.org/hdata/schemas/2009/06/allergy')
    end
    
    should 'find an extension by extension_id' do      
      extension = @record.extensions.find_by_extension_id('http://projecthdata.org/hdata/schemas/2009/06/allergy')
      assert extension
      assert_equal 'http://projecthdata.org/hdata/schemas/2009/06/allergy', extension.extension_id
      assert_nil @record.extensions.find_by_extension_id('http://splat.com')
    end
    
    should 'know if an extension is registered under a extension_id' do
      assert @record.extensions.extension_id_registered?('http://projecthdata.org/hdata/schemas/2009/06/allergy')
      assert !@record.extensions.extension_id_registered?('http://foo.org')
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

class SectionDocumentTest < Test::Unit::TestCase
  context 'A Section Documend' do
    should 'save a document to GridFS' do
      doc = SectionDocument.new(:title => 'Test Document')
      doc.create_document('Text of a test document', 'test.txt', 'text/plain')
      
      file = Mongo::Grid.new(SectionDocument.db).get(BSON::ObjectID.from_string(doc.file_id))
      assert file
      assert_equal 'Text of a test document', file.data
      assert_equal 'test.txt', file.filename
      assert_equal 'text/plain', file.content_type
    end
    
    should 'retrieve a file from GridFS' do
      doc = SectionDocument.new(:title => 'Test Document')
      doc.create_document('Text of a test document', 'test.txt', 'text/plain')
      
      file = doc.grid_document
      assert file
      assert_equal 'Text of a test document', file.data
      assert_equal 'test.txt', file.filename
      assert_equal 'text/plain', file.content_type
    end
    
    should 'remove the file from GridFS when it is destroyed' do
      doc = SectionDocument.new(:title => 'Test Document')
      doc.create_document('Text of a test document', 'test.txt', 'text/plain')
      
      file_id = doc.file_id
      doc.destroy
      assert_raise Mongo::GridFileNotFound do
        Mongo::Grid.new(SectionDocument.db).get(BSON::ObjectID.from_string(file_id))
      end
    end
    
    should 'be able to replace the contents of a GridFS file' do
      doc = SectionDocument.new(:title => 'Test Document')
      doc.create_document('Text of a test document', 'test.txt', 'text/plain')
      doc.replace_grid_file('<switch>changed</switch>', 'test.xml', 'application/xml')
      
      file = doc.grid_document
      assert file
      assert_equal '<switch>changed</switch>', file.data
      assert_equal 'test.xml', file.filename
      assert_equal 'application/xml', file.content_type
    end

    should 'be able to create metadata from xml' do
      fixture_file = File.new(File.join(File.dirname(__FILE__), '..', 'fixtures', 'metadata1.xml'))
      ng = Nokogiri::XML(fixture_file)
      doc = SectionDocument.new()
      doc.create_metadata_from_xml(ng.root)
      assert_equal 'Random Title', doc.title
      assert_equal 'RandomDocumentId', doc.document_id
      assert_equal 2, doc.link_info.size
      assert_equal 'http://www.hl7.org/', doc.link_info.first
      assert_equal 1, doc.authors.size
      assert_equal 'Dr. John Doe', doc.authors.first

    end
  end
end
