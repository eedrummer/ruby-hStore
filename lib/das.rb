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
      end
    end
  end
end