require "json"

module Artifactory
  module Permissions
    module V2
      module Commands
        class SavePermission
          def self.call(permission_target:, api_client:)
            new(permission_target: permission_target, api_client: api_client).call
          end

          attr_reader :permission_target, :api_client

          def initialize(permission_target:, api_client:)
            @permission_target = permission_target
            @api_client = api_client
          end

          def call
            process
            permission_target
          end

          private

          def process
            status, result = api_client.save_permission_target permission_target

            result.each { |err| add_error err } if status == :error
          end

          def add_error(err)
            errors.add :base, [err["status"], err["message"]].join(" - ")
          end

          def errors
            permission_target.errors
          end
        end
      end
    end
  end
end
