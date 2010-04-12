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