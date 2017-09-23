module CBC
  module Helpers
    module Attrs
      def attr_public_reader_protected_writer(*args)
        send(:public, send(:attr_reader, *args))
        send(:protected, send(:attr_writer, *args))
      end
    end
  end
end
