module HStore
  module DAS
    def self.included(mod)
      mod.module_eval do
        post '/records/:id/add_das' do
          @record = Record.find(params[:id])
          das = @record.create_discovery_authorization_service(:das_uri => params[:das_url])
          response = Crack::JSON.parse(HTTParty.get(das.das_uri + "/.well-known/hostmeta"))
          das.host_resource_details_uri = response['link']['http://uma/host/resources'][0]['href']
          das.host_token_validation_url = response['link']['http://kantarainitiative.org/confluence/display/uma/host_token_validation_uri'][0]['href']
          das.host_user_uri = response['link']['http://uma/host/user_uri'][0]['href']
          das.host_token_uri = response['link']['http://uma/requester/token_uri'][0]['href']
          
          oauth_response = Crack::JSON.parse(HTTParty.post(das.host_resource_details_uri,
                                         :body => @record.to_resource_descriptor,
                                         :headers => {'Content-Type' => 'application/json'}))
                                         
          das.client_id = oauth_response['client_id']
          das.save
          state = oauth_response['session_id']
          query = {'type' => 'web_server',
                   'redirect_uri' => "http://localhost:4567/records/#{@record.id}/am_redirect",
                  'state' => state,
                  'client_id' => das.client_id}
          redirect "#{das.host_user_uri}?#{query.to_param}"
        end
        
        get '/records/:id/am_redirect' do
          @record = Record.find(params[:id])
          code = params[:code]
          state = params[:state]
          das = @record.discovery_authorization_service
          
          oauth_response = Crack::JSON.parse(HTTParty.post(das.host_token_uri,
                                          :body => {"client_id"  => das.client_id,
                                                    "code" => code,
                                                    'type' => 'web_server',
                                                    'redirect_uri' => "http://localhost:4567/records/#{@record.id}/am_redirect",
                                                    'format' => 'json'
                                                    }))
          das.access_token = oauth_response['access_token']
          das.save
          redirect "http://localhost:4567/records/#{@record.id}"
        end
        
        before do
          md = request.path_info.match(/\/records\/([\w\d]+)/)
          if md
            @record = Record.find(md[1])
            if @record && @record.discovery_authorization_service.try(:access_token).present?
              if params[:oauth_token]
                validate_request(params[:oauth_token], request.path_info)
              else
                halt 401, {'WWW-Authenticate' => @record.discovery_authorization_service.das_uri}, 'You must be authenticated to access this resource'
              end
            end
          end
        end
        
        def validate_request(oauth_token, uri_to_access)
          oauth_response = HTTParty.post(@record.discovery_authorization_service.host_token_validation_url,
                                         :body => {'access_token' => oauth_token,
                                                   'resource_uri' => uri_to_access
                                                  })
          if oauth_response.code != 200
            halt 403
          end
        end
      end
    end
  end
end
