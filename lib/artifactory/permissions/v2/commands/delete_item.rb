module Artifactory
  module Permissions
    module V2
      module Commands
        class DeleteItem < PermissionItemCommand
          private

          def process
            permission_target
              .public_send("delete_#{item_type}", scope: scope, name: name)
          end

          def validate
            errors.add :name,
                       "Name can not be empty." if name.empty?
          end
        end
      end
    end
  end
end
