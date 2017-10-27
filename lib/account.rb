module Magnate
  class Account # Счёт
    include Helpers::Attrs
    
    PROPERTIES = [
      :unit, # единица счёта (баллы, валюта)
      :sum   # сумма на счету
    ]
    attr_public_reader_protected_writer *PROPERTIES
    
    def initialize(options = {})
      set_options_and_assert(PROPERTIES, options)
    end
  end # class Account
  
  class AccountsWrapper
    include Helpers::Attrs
    
    PROPERTIES = [
      :name,        # название
      :current_date # можно устанавливать дату только больше текущей (<Time>)
    ]
    attr_public_reader_protected_writer *PROPERTIES
    
    SPECIAL_PROPERTIES = [
      :current_account, # текущий счёт
      :loan_account,    # ссудный счёт
      :operations,      # операции по счёту
      :log              # сумма на счету за каждый просмотренный день
    ]
    attr_public_reader_protected_writer *SPECIAL_PROPERTIES
    
    ONE_DAY = 1*24*60*60
    
    def initialize(options = {})
      unit = options.delete(:unit)
      sum = options.delete(:sum)
      
      set_options_and_assert(PROPERTIES, options)
      
      @current_account = Account.new(unit: unit, sum: sum > 0 ? sum : 0)
      @loan_account = Account.new(unit: unit, sum: sum < 0 ? -sum : 0)
    end
    
    def all_dates
      @operations.keys
    end
    
    def next_day!
      # посчитать бонусные баллы, cash-back, процент на остаток,
      # процент по задолженности и прочее за день
      
      @log[@current_date] = {
        current: @current_account.sum,
        loan: @loan_account.sum
      }
      @current_date += ONE_DAY
    end
    
    # add operations:
    
    def cash_replenishment(amount, comment = '') # пополнение наличными
      receive_money(amount)
      add_operation(sum: amount, type: __method__, comment: comment)
    end
    
    def cash_withdrawal(amount, comment = '') # снятие наличных
      spend_money(amount)
      add_operation(sum: amount, type: __method__, comment: comment)
    end
    
    def receive_transfer_from_person(amount, comment = '')
      receive_money(amount)
      add_operation(sum: amount, type: __method__, comment: comment)
    end
    
    def receive_transfer_from_org(amount, comment = '')
      receive_money(amount)
      add_operation(sum: amount, type: __method__, comment: comment)
    end
    
    def send_transfer_to_person(amount, comment = '')
      spend_money(amount)
      add_operation(sum: amount, type: __method__, comment: comment)
    end
    
    def send_transfer_to_org(amount, comment = '')
      spend_money(amount)
      add_operation(sum: amount, type: __method__, comment: comment)
    end
    
    private
    
    def receive_money(amount)
      loan_sum = @loan_account.sum
      if loan_sum > 0 # has loan
        if amount >= loan_sum
          amount -= loan_sum
          @loan_account.sum = 0
          @current_account.sum = amount
        else
          @loan_account.sum -= amount
        end
      else # no loan
        @current_account.sum += amount
      end
    end
    
    def spend_money(amount)
      cur_sum = @current_account.sum
      if cur_sum > 0
        if cur_sum >= amount
          @current_account.sum -= amount
        else
          amount -= cur_sum
          @current_account.sum = 0
          @loan_account.sum = amount
        end
      else
        @loan_account.sum += amount
      end
    end
    
    def add_operation(hash = {})
      @operations[@current_date] ||= []
      @operations[@current_date] << hash.merge(date: @current_date)
    end
  end
  
  class CardAccount < AccountsWrapper # Карточный счёт
    # bonus_account есть только у некоторых тарифов карточных счетов, поэтому
    # нужно инициализировать бонусный счёт только у определённых карт.
    attr_public_reader_protected_writer :bonus_account
    
    # cash back бывает двух видов:
    #   1. в валюте счёта, обычно начисляется раз в месяц в определённый день.
    #   2. в виде баллов, тогда обычно есть два бонусных счёта:
    #      i) отложенные баллы (баллы начисляются сразу после подтверждения
    #         операции, становятся доступны спустя несколько дней)
    #     ii) доступные баллы (баллы, которые можно тратить; в некоторых тарифах
    #         баллы сгорают спустя несколько месяцев, если не были использованы)
    
    # нет необходимости знать, сколько реально баллов на бонусном счёте.
    # имеет значение сумма бонусов, выраженная в валюте карточного счёта.
    #
    # т.е. пользователь указывает сумму в валюте, которую хочет списать
    # с бонусного счёта, на бонусном счёте она переводится в бонусы. если бонусов
    # недостаточно для совершения операции, то остальная сумма списывается
    # с карточного счёта, связанного с этим бонусным счётом.
    #
    # значит, после расчёта операций по бонусному счёту необходимо пересчитать
    # операции по карточному счёту. чтобы не возникло коллизий, имеет смысл
    # всегда сначала считать операции с бонусами, затем по карточному счёту,
    # а все действия с бонусным счётом запускать только через карточный счёт.
    # например, Карта.bonus_account.add_operation(...)
    
    def calc_sum(day_operations)
      # возможные случаи изменения карточного счёта:
      #   - оплата картой -> уменьшение суммы на счету
      #   - снятие наличных -> уменьшение суммы на счету,
      #     может быть комиссия
      #   - перевод с карточного счёта физлицу -> уменьшение суммы на счету,
      #     может быть комиссия
      #   - перевод с карточного счёта юрлицу -> уменьшение суммы на счету,
      #     может быть комиссия
      #   - перевод на карточный счёт от физлица -> увеличение суммы на счету
      #   - перевод на карточный счёт от юрлица -> увеличение суммы на счету
      #
      # уменьшение суммы на счету: если средств недостаточно, то могут быть
      # два варианта поведения:
      #   1. заход в овердрафт
      #   2. отмена расходной операции (с состоянием ошибки)
      #
      # увеличение суммы на счету: некоторые тарифы карточных счетов ограничивают
      # максимальную сумму денег, которые можно на них хранить.
      # в этом случае должна быть отмена приходной операции (с состоянием ошибки).
    end
    
    def purchase(amount, mcc, comment = '') # покупка
      # MCC важен для расчёта cash-back. На некоторых кредитных картах некоторые
      # MCC трактуются как операции снятия наличных, за них берут комиссию.
      spend_money(amount)
      add_operation(sum: amount, type: __method__, mcc: mcc, comment: comment)
    end
    
    def cancel_purchase(amount, comment = '') # возврат средств отменённой покупки
      receive_money(amount)
      add_operation(sum: amount, type: __method__, comment: comment)
    end
  end
  
  class BonusAccount < AccountsWrapper # Бонусный счёт
  end
  
  class CheckingAccount < AccountsWrapper # Расчётный счёт
  end
  
  class MilesAccount < AccountsWrapper # Мильный счёт
    # Для программ лояльности транспортных компаний
    # (железные дороги и авиакомпании)
  end
  
  class CashAccount < AccountsWrapper # Наличные
  end
  
  class DepositAccount < AccountsWrapper # Вклад
  end
  
  class CreditAccount < AccountsWrapper # Кредит (но не кредитная карта)
  end
end
