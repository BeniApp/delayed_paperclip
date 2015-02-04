module DelayedPaperclip
  module CropModelExtension

    module ClassMethods

      def keep_crop_attributes(attachment_name)
        [:crop_x, :crop_y, :crop_w, :crop_h].each do |a|
          attr_accessor :"#{attachment_name}_original_#{a}"
        end

        before_update :"save_crop_attributes"
      end

      def attachment_names
        if respond_to? :attachment_definitions
          # for Paperclip <= 3.4 
          attachment_definitions.keys
        else
          # for Paperclip >= 3.5
          # Paperclip::Tasks::Attachments.instance.definitions_for(self).keys
          []
        end
      end
    end

    module InstanceMethods

      # Papercrop resets crop attributes after saving the object.
      # This ensures they are saved as similiar named attributes
      def save_crop_attributes
        self.class.attachment_names.each do |attachment_name|
          if self.cropping?(attachment_name)
            [:crop_x, :crop_y, :crop_w, :crop_h].each do |a|
              value = self.send("#{attachment_name}_#{a}")
              self.send :"#{attachment_name}_original_#{a}=", value
            end
          end
        end
      end

      def retreive_crop_attributes(crop_attrs)
        crop_attrs.each do |attachment_attributes|
          attachment_attributes.each do |attribute|
            self.send("#{attribute.keys.first}=", attribute[attribute.keys.first])
          end
        end

        self.class.attachment_names.each do |attachment_name|
          [:crop_x, :crop_y, :crop_w, :crop_h].each do |a|
            value = self.send("#{attachment_name}_original_#{a}")
            self.send :"#{attachment_name}_#{a}=", value
          end
        end

        self
      end
    end

    def crop_attributes
      debugger
      attrs = []
      self.class.attachment_names.each do |attachment_name|
        attachment_attributes = []
        ["#{attachment_name}_original_w", "#{attachment_name}_original_h", "#{attachment_name}_box_w",
         "#{attachment_name}_original_crop_x", "#{attachment_name}_original_crop_y", "#{attachment_name}_original_crop_w",
         "#{attachment_name}_original_crop_h", "#{attachment_name}_aspect"].each do |attribute_name|
          attachment_attributes << {attribute_name => self.send(attribute_name) }
        end
        attrs << attachment_attributes
      end
      attrs
    end

  end
end

if defined? ActiveRecord::Base
  ActiveRecord::Base.class_eval do
    extend  DelayedPaperclip::CropModelExtension::ClassMethods
    include DelayedPaperclip::CropModelExtension::InstanceMethods
  end
end