module Messaging
  module Message
    class Metadata
      class Error < RuntimeError; end

      include Schema::DataStructure

      attribute :source_event_stream_name
      alias :stream_name :source_event_stream_name
      attribute :source_event_position
      alias :sequence :source_event_position
      alias :position :source_event_position
      alias :position= :source_event_position=

      attribute :causation_event_stream_name
      attribute :causation_event_position

      attribute :correlation_stream_name

      attribute :reply_stream_name

      attribute :global_position
      attribute :time

      attribute :schema_version

      def source_event_identifier
        return nil if source_event_stream_name.nil? || source_event_position.nil?
        "#{source_event_stream_name}/#{source_event_position}"
      end

      def causation_event_identifier
        return nil if causation_event_stream_name.nil? || causation_event_position.nil?
        "#{causation_event_stream_name}/#{causation_event_position}"
      end

      def follow(other_metadata)
        self.causation_event_stream_name = other_metadata.source_event_stream_name
        self.causation_event_position = other_metadata.source_event_position

        unless follows?(other_metadata)
          raise Error, "Metadata doesn't have precedence (Metadata: #{self.inspect}, Other Metadata #{other_metadata.inspect})"
        end
      end

      def follows?(other_metadata)
        causation_event_identifier == other_metadata.source_event_identifier &&

          correlation_stream_name == other_metadata.correlation_stream_name &&
          reply_stream_name == other_metadata.reply_stream_name
      end

      def clear_reply_stream_name
        self.reply_stream_name = nil
      end

      def self.transient_attributes
        [
          :source_event_stream_name,
          :source_event_position,
          :global_position,
          :time
        ]
      end

      def self.remove_transient_attributes(data)
        transient_attributes.each do |not_written_attribute|
          data.delete(not_written_attribute)
        end
      end

      def attributes
        attributes = super
        self.class.remove_transient_attributes(attributes)
        attributes
      end

      def to_h
        attributes
      end

      def self.attribute_names
        attribute_names = super
        remove_transient_attributes(attribute_names)
        attribute_names
      end
    end
  end
end
