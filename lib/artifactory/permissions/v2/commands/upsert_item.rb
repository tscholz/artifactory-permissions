module Artifactory
  module Permissions
    module V2
      module Commands
        class UpsertItem < PermissionItemCommand
          private

          def process
            permission_target
              .public_send("upsert_#{item_type}", scope: scope, name: name, permissions: permissions)
          end

          def validate
            errors.add :name,
                       "Name can not be empty." if name.empty?

            errors.add :permissions,
                       "Permissions can not be empty." if permissions.empty?

            validate_permission_items if permissions.any?
          end

          def validate_permission_items
            (unknown_permissions = permissions - available_permissions).any? or return

            errors.add :permissions,
                       "Permissions contain unknown value(s) #{unknown_permissions.join(", ")}. Valid permissions are #{available_permissions.join(", ")}."
          end

          def available_permissions
            item.class.available_permissions
          end
        end
      end
    end
  end
end
