xml.instruct! :xml, :version => '1.0'
xml.feed(:xmlns => "http://www.w3.org/2005/Atom") do
  xml.title("hData Record Id: #{@record.id}")
  xml.id(url_for("/records/#{@record.id}"))
  xml.updated(@record.updated_at.to_time.xmlschema)
  
  @record.sections.each do |section|
    xml.entry do
      xml.id(url_for("/records/#{@record.id}/#{section.path}"))
      xml.title(section.name)
      xml.author do
        xml.name("Tiny hData Store")
      end
      xml.updated(section.updated_at.to_time.xmlschema)
      xml.link(:rel => 'alternate', :href => url_for("/records/#{@record.id}/#{section.path}"))
    end
  end
end
