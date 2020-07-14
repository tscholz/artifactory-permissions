module Artifactory
  module Permissions
    module Helpers
      module_function

      def deep_merge!(hash, other)
        hash.merge!(other) do |key, val, other_val|
          if val.is_a?(Hash) && other_val.is_a?(Hash)
            deep_merge!(val, other_val)
          else
            other_val
          end
        end
      end

      def deep_hash
        Hash.new { |h, k| h[k] = Hash.new &h.default_proc }
      end
    end
  end
end
