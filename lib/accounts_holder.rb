class AccountsHolder
  attr_reader :accounts
  
  def initialize(options = {})
    @accounts = options.delete(:accounts)
    
    raise ArgumentError, "Unused args: #{options.keys}" unless options.empty?
  end
  
  def next_day!
    @accounts.each(&:next_day!)
  end
  
  def put_log(bars = true)
    table = HashTableOutput.new
    table.set_headers table_headers
    
    units = @accounts.map(&:units).flatten.uniq # => [unit, ...]
    
    @accounts[0].log.keys.each do |date|
      # => {account name => {unit => sum, ...}, ...}
      funds = get_funds(date)
      sum = calc_sum(funds, units)
      table.append({date: date, sum: sum}.merge(funds))
    end
    
    table.output(bars)
  end
  
  private
  
  # => {
  #     date: 'Date',
  #     [account name, unit] => 'account name (unit)', ...,
  #     sum: 'Sum'
  #    }
  def table_headers
    accounts_units = {}
    @accounts.each do |e|
      e.units.each do |u|
        key = [e.name, u]
        accounts_units[key] = "#{e.name} (#{u})"
      end
    end
    {date: 'Date'}.merge(accounts_units.merge({sum: 'Sum'}))
  end
  
  # date: Date | Time
  # => {[account name, unit] => sum, ...}
  def get_funds(date)
    accounts_units = {}
    @accounts.each do |e|
      e.log[date].each do |unit, sum|
        key = [e.name, unit]
        accounts_units[key] = sum
      end
    end
    accounts_units
  end
  
  # funds: {[account name, unit] => sum, ...}
  # units: [unit, ...]
  # => {unit => sum, ...}
  def calc_sum(funds, units)
    units.map do |u|
        sum = funds.reduce(0) { |a, e| a + (e[u] || 0) } # сумма одной валюты
        [u, sum]
      end.to_h # {unit => sum, ...}
  end
end
