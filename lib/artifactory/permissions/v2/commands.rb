require_relative "commands/permission_item_command"
require_relative "commands/delete_item"
require_relative "commands/save_permission"
require_relative "commands/upsert_item"

module Artifactory
  module Permissions
    module V2
      module Commands
        module_function

        def upsert_item(permission_target:, item:)
          UpsertItem.call permission_target: permission_target,
                          item: item
        end

        def delete_item(permission_target:, item:)
          DeleteItem.call permission_target: permission_target,
                          item: item
        end

        def save_permission_target(permission_target:, api_client:)
          SavePermission.call permission_target: permission_target,
                              api_client: api_client
        end
      end
    end
  end
end
