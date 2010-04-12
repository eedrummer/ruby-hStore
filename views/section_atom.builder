xml.instruct! :xml, :version => '1.0'
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title(@section.name)
  xml.id(url_for("/records/#{@record.id}/#{@section.path}"))
  xml.updated(@section.updated_at.to_time.xmlschema)
  
  @section.section_documents.each do |document|
    xml.entry do
      xml.id(url_for("/records/#{@record.id}/#{@section.path}/#{document.id}"))
      xml.title(document.title)
      xml.author do
        xml.name("Tiny hData Store")
      end
      xml.updated(document.updated_at.to_time.xmlschema)
      xml.content(:type => "text/xml") do
        xml.DocumentMetaData(:xmlns => "http://projecthdata.org/hdata/schemas/2009/11/metadata") do
          xml.DocumentId(document.id)
          xml.RecordDate do
            xml.CreatedDateTime(document.created_at.to_time.xmlschema)
          end
        end
      end
    end
  end
end