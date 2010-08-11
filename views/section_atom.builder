xml.instruct! :xml, :version => '1.0'
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title(@section.name)
  xml.id(url_for("/records/#{@record.id}/#{@section.path}"))
  xml.updated(@section.updated_at.to_time.xmlschema)
  
  @section.section_documents.each do |document|
    xml.entry do
      xml.id(document.document_id)
      xml.link(:rel => "alternate", :href => url_for("/records/#{@record.id}/#{@section.path}/#{document.id}"))
      if document.link_info
      	document.link_info.each do |link|
	  xml.link(:rel => 'related', :href => link)
      	end
      end
      xml.title(document.title)
      document.authors.each do |author|
	xml.author do
	  xml.name(author)
	end
      end
      xml.updated(document.last_modified.to_time.xmlschema)
      xml.content(:type => "text/xml") do
        xml << strip_declarations(document)
      end
    end
  end
end
