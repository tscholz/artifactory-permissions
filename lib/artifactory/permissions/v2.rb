require_relative "v2/api_client"
require_relative "v2/commands"
require_relative "v2/permission_items"
require_relative "v2/permission_target"

module Artifactory
  module Permissions
    module V2
      module_function

      def api_client(endpoint:, access_token:)
        ApiClient.new endpoint:     endpoint,
                      access_token: access_token
      end

      def parse_permission_target(payload)
        PermissionTarget.new payload
      end
    end
  end
end
