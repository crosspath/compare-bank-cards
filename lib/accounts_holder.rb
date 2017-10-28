class AccountsHolder
  attr_reader :accounts
  
  def initialize(options = {})
    @accounts = options.delete(:accounts)
    
    raise ArgumentError, "Not used args: #{options.keys}" unless options.empty?
  end
  
  def next_day!
    @accounts.each(&:next_day!)
  end
  
  def put_log(bars = true)
    accounts_units = @accounts.map(&:units)
    units = accounts_units.flatten.uniq # => [unit, ...]
    account_names = @accounts.map { |a| a.units.map { |u| [a.name, u] } }
    # TODO: incomplete function
    table = HashTableOutput.new
    table.set_headers ['Date', account_names.values, 'Sum'].flatten
    
    @accounts[0].log.keys.each do |date|
      funds = @accounts.map { |a| a.log[date] } # => [{unit => sum}, ...]
      sums = units.map do |u|
        sum = funds.reduce(0) { |a, e| a + (e[u] || 0) } # сумма одной валюты
        [u, sum]
      end.to_h # {unit => sum, ...}
      table.append [date, funds, sum].flatten
    end
    
    table.output(bars)
  end
end
