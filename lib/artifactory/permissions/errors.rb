module Artifactory
  module Permissions
    class Errors
      def initialize
        @errors = Hash.new { |h, k| h[k] = [] }
      end

      def add(key, msg)
        @errors[key] << msg
        self
      end

      def empty?
        !any?
      end

      alias_method :none?, :empty?

      def any?
        @errors.values.flatten.any?
      end

      def full_messages
        @errors
          .keys
          .map { |key| [key, full_message(key)].join(": ") }
          .join("; ")
      end

      def full_message(key)
        @errors[key].join(", ")
      end

      def to_h
        @errors.dup
      end
    end
  end
end
