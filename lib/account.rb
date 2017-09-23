module CBC
  class Account
    include Helpers::Attrs
    
    PROPERTIES = [
      :unit,  # единица счёта (баллы, валюта)
      :sum,   # сумма на счету
      :owner, # держатель счёта
      :name   # название
    ]
    attr_public_reader_protected_writer *PROPERTIES
    
    SPECIAL_PROPERTIES = [
      :operations,  # операции по счёту
      :log,         # как история: сумма на счету за каждый просмотренный день
      :current_date # можно устанавливать дату только больше текущей (<Time>)
    ]
    attr_public_reader_protected_writer *SPECIAL_PROPERTIES
    
    ONE_DAY = 1*24*60*60
    
    def initialize(options = {})
      PROPERTIES.each do |prop|
        if options.key?(prop)
          instance_variable_set("@#{prop}", options.delete(prop))
        end
      end
      
      unless options.empty?
        raise ArgumentError, "Unused args: #{options.keys}"
      end
      
      @log = {} # {date => sum, ...}
      @operations = [] # [<Operation>, ...]
    end
    
    def next_day!
      # выполнить расчёты на счету за текущий день
      
      day_operations = @operations.select { |op| op.date == @current_date }
      @sum = calc_sum(day_operations)
      @log[@current_date] = @sum
      
      @current_date += ONE_DAY
    end
    
    def add_operation(sum, mcc, comment = '')
      @operations << Operation.new(
        sum: sum,
        mcc: mcc,
        date: @current_date,
        comment: comment
      )
    end
    
    def calc_sum(day_operations)
      raise 'Not implemented'
    end
  end
end
