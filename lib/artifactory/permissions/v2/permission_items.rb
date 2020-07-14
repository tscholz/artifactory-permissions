require_relative "permission_items/base"
require_relative "permission_items/group"
require_relative "permission_items/user"

module Artifactory
  module Permissions
    module V2
      module PermissionItems
        module_function

        def user(name:, permissions:, scope:)
          User.new name: name, permissions: permissions, scope: scope
        end

        def group(name:, permissions:, scope:)
          Group.new name: name, permissions: permissions, scope: scope
        end
      end
    end
  end
end
