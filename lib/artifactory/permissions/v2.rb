require_relative "v2/api_client"
require_relative "v2/commands"
require_relative "v2/permission_items"
require_relative "v2/permission_target"

module Artifactory
  module Permissions
    module V2
      module_function

      def api_client(endpoint:, api_key:)
        ApiClient.new endpoint: endpoint,
                      api_key: api_key
      end

      def parse_permission_target(payload)
        PermissionTarget.new payload
      end
    end
  end
end
