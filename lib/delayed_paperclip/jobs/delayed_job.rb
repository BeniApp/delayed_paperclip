require 'delayed_job'

module DelayedPaperclip
  module Jobs
    class DelayedJob < Struct.new(:object, :crop_attributes, :attachment_name)

      if Gem.loaded_specs['delayed_job'].version >= Gem::Version.new("2.1.0") # this is available in newer versions of DelayedJob. Using the newee Job api thus.

        def self.enqueue_delayed_paperclip(object, crop_attributes, attachment_name)
          ::Delayed::Job.enqueue(
            :payload_object => new(object, crop_attributes, attachment_name),
            :priority => object.class.name.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            :queue => object.class.name.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      else

        def self.enqueue_delayed_paperclip(object, crop_attributes, attachment_name)
          ::Delayed::Job.enqueue(
            new(object, crop_attributes, attachment_name),
            object.class.name.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            object.class.name.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      end

      def perform
        DelayedPaperclip.process_job(object, crop_attributes, attachment_name)
      end
    end
  end
end