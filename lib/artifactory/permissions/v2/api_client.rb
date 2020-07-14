require "cgi"
require "httparty"
require "json"

module Artifactory
  module Permissions
    module V2
      class ApiClient
        include HTTParty

        HTTP_ERRORS = [
          EOFError,
          Errno::ECONNRESET,
          Errno::EINVAL,
          Net::HTTPBadResponse,
          Net::HTTPHeaderSyntaxError,
          Net::ProtocolError,
          Timeout::Error,
        ]

        HANDLED_ERRORS = [SocketError] + HTTP_ERRORS

        attr_reader :endpoint, :api_key

        def initialize(endpoint:, api_key:)
          @endpoint = endpoint
          @api_key = api_key
        end

        def list_permissions
          get "/api/v2/security/permissions"
        end

        def find_permission(name:)
          get "/api/v2/security/permissions/#{url_safe name}"
        end

        def save_permission_target(permission_target)
          put "/api/v2/security/permissions/#{url_safe permission_target.name}",
              permission_target.payload
        end

        def get(path)
          response = self.class.get uri_for(path), headers: headers

          handle_response response
        rescue *handled_errors => err
          raise FatalError, err.message
        end

        def put(path, data)
          response = self.class.put uri_for(path),
                                    body: data.to_json,
                                    headers: headers

          handle_response response
        rescue *handled_errors => err
          raise FatalError, err.message
        end

        private

        # Informational responses (100–199),
        # Successful responses (200–299),
        # Redirects (300–399),
        # Client errors (400–499),
        # and Server errors (500–599).
        def handle_response(response)
          response.success? ? [:ok, response.parsed_response] : [:error, handle_none_success!(response)]
        end

        def handle_none_success!(response)
          case response
          when :client_error?.to_proc
            response.parsed_response.fetch "errors"
          when :server_error?
            raise FatalError, response.body
          else
            response.error!
          end
        end

        def uri_for(path)
          File.join endpoint, path
        end

        def headers
          { "Content-Type" => "application/json" }.merge auth_headers
        end

        def auth_headers
          { "X-JFrog-Art-Api" => api_key }
        end

        def url_safe(string)
          CGI.escape string
        end

        def handled_errors
          HANDLED_ERRORS
        end
      end
    end
  end
end
