require "forwardable"

module Artifactory
  module Permissions
    module V2
      module Commands
        class PermissionItemCommand
          extend Forwardable

          def self.call(permission_target:, item:)
            new(permission_target: permission_target, item: item).call
          end

          attr_reader :permission_target, :item

          def initialize(permission_target:, item:)
            @permission_target = permission_target
            @item = item
          end

          def call
            validate_scope

            validate

            process if valid?

            self
          end

          private

          def validate_scope
            if scope.empty?
              errors.add :scope,
                         "Scope can not be empty."
            else
              errors.add :scope,
                         "Unknown scope '#{scope}'. Must be one of #{available_scopes.join(", ")}." unless available_scopes.include? scope
            end
          end

          def_delegators :item, :name, :permissions, :scope, :errors, :errors?, :valid?

          def validate
            # Subclass validations goes here
          end

          def process
            NotImplementedError
          end

          def item_type
            @item_type ||= item.class.name.split("::").last.downcase.tap do |type|
              raise Error, "Unknown permission item type #{type}" unless %w[group user].include? type
            end
          end

          def available_scopes
            item.class.available_scopes
          end
        end
      end
    end
  end
end
