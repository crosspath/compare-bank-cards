module CBC
  class Operation # Операция
    include Helpers::Attrs
    
    PROPERTIES = [
      :sum,    # сумма в единицах счёта (баллы, валюта)
      :mcc,    # код MCC
      :date,   # дата
      :comment # название операции или что-то другое, строка
    ]
    attr_public_reader_protected_writer *PROPERTIES
    
    def initialize(options = {})
      if (%i[sum mcc date] & options.keys).size < 3
        raise ArgumentError, 'Sum, MCC and date should be set'
      end
      
      set_options_and_assert(PROPERTIES, options)
    end
  end
end
