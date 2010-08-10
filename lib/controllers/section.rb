module HStore
  module SectionController
    def self.included(mod)
      mod.module_eval do
        get '/records/:id/*' do
          @record = Record.find(params[:id])
          @section = @record.sections.find_by_path(params[:splat].first)
          if @section
            builder :section_atom
          else
            status 404
          end
        end
        
        post '/records/:id/*' do
          @record = Record.find(params[:id])
          @section = @record.sections.find_by_path(params[:splat].first)
          if @section
            doc = SectionDocument.new()
            doc.create_document(params[:content][:tempfile], params[:content][:filename], params[:content][:type])
	    if params[:metadata]
	      metadata = params[:metadata][:tempfile].read
	      doc.create_metadata_from_xml(Nokogiri::XML(metadata).root)
	      doc.store_metadata(metadata)
	    end
            doc.save
            @section.section_documents << doc
            status 201
            url_for("/records/#{@record.id}/#{@section.path}/#{doc.id}")
          else
            status 400, "Could not find the section"
          end
        end
        
        delete '/records/:id/*' do
          @record = Record.find(params[:id])
          @section = @record.sections.find_by_path(params[:splat].first)
          if @section
            @section.section_documents.each do |document|
              document.destroy
            end
            @section.destroy
            status 204
          else
            status 404
          end
        end
      end
    end
  end
end
