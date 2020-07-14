require_relative "permissions/errors"
require_relative "permissions/helpers"
require_relative "permissions/v2"
require_relative "permissions/version"

module Artifactory
  module Permissions
    Error = Class.new StandardError
    FatalError = Class.new Error

    PERMISSIONS = %w[read write annotate delete manage managedXrayMeta distribute].freeze
    SCOPES = %w[repo build releaseBundle].freeze

    module_function

    def list(api_client:)
      api_client.list_permissions
    end

    def find(name:, api_client:)
      status, result = api_client.find_permission name: name

      status == :ok ? [:ok, V2.parse_permission_target(result)] : [status, result]
    end

    def get(uri, api_client:)
      status, result = api_client.get uri

      status == :ok ? [:ok, V2.parse_permission_target(result)] : [status, result]
    end

    def user(name:, permissions:, scope:)
      V2::PermissionItems.user name: name,
                               permissions: permissions,
                               scope: scope
    end

    def group(name:, permissions:, scope:)
      V2::PermissionItems.group name: name,
                                permissions: permissions,
                                scope: scope
    end

    def upsert_user(permission_target:, user:)
      V2::Commands.upsert_item permission_target: permission_target,
                               item: user

      [user.errors? ? :error : :ok, permission_target, user.errors]
    end

    def delete_user(permission_target:, user:)
      V2::Commands.delete_item permission_target: permission_target,
                               item: user

      [user.errors? ? :error : :ok, permission_target, user.errors]
    end

    def upsert_group(permission_target:, group:)
      V2::Commands.upsert_item permission_target: permission_target,
                               item: group

      [group.errors? ? :error : :ok, permission_target, group.errors]
    end

    def delete_group(permission_target:, group:)
      V2::Commands.delete_item permission_target: permission_target,
                               item: group

      [group.errors? ? :error : :ok, permission_target, group.errors]
    end

    def save(permission_target:, api_client:)
      V2::Commands.save_permission_target permission_target: permission_target,
                                          api_client: api_client

      [permission_target.errors? ? :error : :ok, permission_target, permission_target.errors]
    end

    def api_client(endpoint:, api_key:)
      V2.api_client endpoint: endpoint,
                    api_key: api_key
    end
  end
end
