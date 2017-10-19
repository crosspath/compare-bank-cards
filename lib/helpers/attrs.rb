module Magnate
  module Helpers
    module Attrs
      def attr_public_reader_protected_writer(*args)
        send(:public, send(:attr_reader, *args))
        send(:protected, send(:attr_writer, *args))
      end
      
      alias :iv_get, :instance_variable_get
      alias :iv_set, :instance_variable_set
      
      def set_options_and_assert(allowed_keys, options)
        allowed_keys.each do |prop|
          iv_set("@#{prop}", options.delete(prop).freeze) if options.key?(prop)
        end
        
        raise ArgumentError, "Unused args: #{options.keys}" if options.present?
      end
    end
  end
end
