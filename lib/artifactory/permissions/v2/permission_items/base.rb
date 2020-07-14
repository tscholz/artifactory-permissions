module Artifactory
  module Permissions
    module V2
      module PermissionItems
        class Base
          def self.available_permissions
            PERMISSIONS
          end

          def self.available_scopes
            SCOPES
          end

          attr_reader :name, :permissions, :scope

          def initialize(name:, permissions:, scope:)
            @name = name.to_s
            @permissions = Array(permissions).map(&:to_s)
            @scope = scope.to_s
          end

          def valid?
            !errors?
          end

          def errors?
            errors.any?
          end

          def errors
            @errors ||= Errors.new
          end
        end
      end
    end
  end
end
