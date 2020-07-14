module Artifactory
  module Permissions
    module V2
      class PermissionTarget
        attr_reader :payload

        def initialize(payload)
          @payload = Hash payload
        end

        def name
          payload["name"]
        end

        def users(scope: nil)
          find_all :user, scope
        end

        def groups(scope: nil)
          find_all :group, scope
        end

        def upsert_user(scope:, name:, permissions:)
          upsert! scope, "users", name, permissions
        end

        def delete_user(scope:, name:)
          delete! scope, "users", name
        end

        def upsert_group(scope:, name:, permissions:)
          upsert! scope, "groups", name, permissions
        end

        def delete_group(scope:, name:)
          delete! scope, "groups", name
        end

        # def headers
        #   # Does not work.
        #   { "Content-Type" => "application/vnd.org.jfrog.artifactory.security.PermissionTargetV2+json" }
        # end

        def errors?
          errors.any?
        end

        def errors
          @errors ||= Errors.new
        end

        private

        def find_all(type, scope)
          scopes = scope ? Array(scope.to_s) : known_scopes

          scopes.map do |current_scope|
            payload
              .dig(current_scope, "actions", "#{type}s")
              .to_a
              .map { |name, permissions|
              PermissionItems.public_send type, name: name,
                                                permissions: permissions,
                                                scope: current_scope
            }
          end.flatten
        end

        def upsert!(scope, subject, name, permissions)
          Helpers.deep_merge! payload,
                              deep_hash(scope, subject, name, permissions)

          self
        end

        def delete!(scope, subject, name)
          payload
            .dig(scope, "actions", subject)
            &.delete(name)

          self
        end

        def deep_hash(scope, subject, name, permissions)
          Helpers
            .deep_hash
            .tap { |h| h[scope]["actions"][subject][name] = permissions }
        end

        def known_scopes
          Permissions::SCOPES
        end
      end
    end
  end
end
