module HStore
  module Document
    def self.included(mod)
      mod.module_eval do
        get '/records/:id/*/:doc_id' do
          @record = Record.find(params[:id])
          @section = @record.sections.find_by_path(params[:splat].first)
          if @section
            doc = @section.section_documents.find(params[:doc_id])
            doc.grid_document.read
          else
            status 404
          end
        end
        
        put '/records/:id/*/:doc_id' do
          @record = Record.find(params[:id])
          @section = @record.sections.find_by_path(params[:splat].first)
          if @section
            doc.replace_grid_file(params[:content][:tempfile], params[:content][:filename], params[:content][:type])
            doc.save
            status 200
          else
            status 404
          end
        end
        
        post '/records/:id/*/:doc_id' do
          @record = Record.find(params[:id])
          @section = @record.sections.find_by_path(params[:splat].first)
          if @section
            doc = @section.section_documents.find(params[:doc_id])
	    if params[:metadata] && doc
	      metadata = params[:metadata][:tempfile].read
	      doc.create_metadata_from_xml(Nokogiri::XML(metadata).root)
	      doc.store_metadata(metadata)
	      doc.save
	      status 201
	    else
	      status 400
	    end
	  else
            status 404
	  end
	end

        delete '/records/:id/*/:doc_id' do
          @record = Record.find(params[:id])
          @section = @record.sections.find_by_path(params[:splat].first)
          if @section
            doc = @section.section_documents.find(params[:doc_id])
            doc.destroy
            status 204
          else
            status 404
          end
        end
      end
    end
  end
end
