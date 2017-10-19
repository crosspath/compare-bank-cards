module Magnate
  class Operation # Операция (расход, покупка)
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
  
  # ещё есть операции:
  #   - поступление средств (в т.ч. перечисление зарплаты)
  #   - перевод на другую карту
  #   - перевод на счёт физического или юридического лица
  #   - снятие наличных
  #   - пополнение наличными
  #
  # class PaymentOrder # Платёжное поручение
  #   # - перевод на карту
  #   # - перевод на счёт физического лица
  #   # - перевод на счёт юридического лица
  # end
  #
  # нужно узнать, как оформляют в банковских системах поступление средств
  # на карту или счёт.
  #
  # возможно, снятие наличных проводят как расходный ордер. в отделениях это
  # расходный кассовый ордер.
end
