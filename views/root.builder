xml.instruct! :xml, :version => '1.0'
xml.root(:xmlns => "http://projecthdata.org/hdata/schemas/2009/06/core") do
  xml.documentId('1')
  xml.version('0.8')
  xml.created(@record.created_at.strftime("%Y-%m-%d"))
  xml.lastModified(@record.updated_at.strftime("%Y-%m-%d"))
  xml.extensions do
    @record.extensions.each do |extension|
      xml.extension(extension.type_id, :requirement => extension.requirement)
    end
  end
  xml.sections do
    @record.sections.each do |section|
      xml.section(:typeId => section.type_id, :path => section.path, :name => section.name)
    end
  end
end