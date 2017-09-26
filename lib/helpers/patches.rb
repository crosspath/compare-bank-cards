unless {}.respond_to?(:present?)

  class Hash
    def present?
      !empty?
    end
  end

end

unless [].respond_to?(:present?)

  class Array
    def present?
      !empty?
    end
  end

end
