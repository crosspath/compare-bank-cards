class TableOutput
  attr_reader :data, :headers, :col_lengths
  
  @@conv = {
    NilClass => ->(value) { [:right, 'nil'] },
    TrueClass => ->(value) { [:right, 'true'] },
    FalseClass => ->(value) { [:right, 'false'] }
  }
  if defined?(Number)
    @@conv[Number] = ->(value) { [:right, value.to_s] }
  else
    @@conv[Fixnum] = ->(value) { [:right, value.to_s] }
    @@conv[Float] = ->(value) { [:right, value.to_s] }
  end
  @@default_conv = ->(value) { [:left, value.to_s] }
  
  def initialize(options = {})
    @data = [] # cell: [align, value]
    @headers = []
    @col_lengths = []
  end
  
  def set_headers(headers)
    @headers = format_row(headers)
    update_col_lengths(@headers)
  end
  
  def append(row)
    data_row = format_row(row)
    data << data_row
    update_col_lengths(data_row)
  end
  
  def output(bars = true)
    @headers ||= set_headers(get_headers_from_data)
    
    entries = []
    entries << row_to_s(@headers, bars)
    entries << horizontal_bar if bars
    entries += @data.map { |row| row_to_s(row, bars) }
    
    entries.join("\n") + "\n#{@data.size} row(s)\n"
  end
  # TODO: CSV
  
  private
  
  def get_headers_from_data
    (1..(@col_lengths.size)).to_a
  end
  
  def update_col_lengths(data_row)
    data_row.each_with_index do |cell, i|
      len = cell[1].size
      @col_lengths[i] = len if !@col_lengths[i] || len > @col_lengths[i]
    end
  end
  
  def format_row(row)
    row.map do |value|
      nearest_class = @@conv.keys.find { |klass| value.is_a?(klass) }
      rule = @@conv[nearest_class] || @@default_conv
      rule.call(value)
    end
  end
  
  def pad_cell(cell, column)
    ' ' + case cell[0]
    when :left
      cell[1].ljust(@col_lengths[column])
    when :right
      cell[1].rjust(@col_lengths[column])
    else
      raise ArgumentError, "#{cell[0].inspect} is not correct align parameter"
    end
  end
  
  def row_to_s(row, bars = true)
    row.map.with_index { |cell, i| pad_cell(cell, i) }.join(bars ? ' |' : '')
  end
  
  def horizontal_bar
    @col_lengths.map { |len| '-' * (len + 2) }.join('+')
  end
end

class HashTableOutput < TableOutput
  def initialize(options = {})
    @data = [] # cell: [align, value]
    @headers = {}
    @col_lengths = {}
  end
  
  private
  
  def get_headers_from_data
    @col_lengths.keys
  end
  
  def update_col_lengths(data_row)
    data_row.each do |i, cell|
      len = cell[1].size
      @col_lengths[i] = len if !@col_lengths[i] || len > @col_lengths[i]
    end
  end
  
  def format_row(row)
    res = {}
    row.each do |key, value|
      nearest_class = @@conv.keys.find { |klass| value.is_a?(klass) }
      rule = @@conv[nearest_class] || @@default_conv
      res[key] = rule.call(value)
    end
    res
  end
  
  def row_to_s(row, bars = true)
    @headers.keys.map { |key| pad_cell(row[key], key) }.join(bars ? ' |' : '')
  end
  
  def horizontal_bar
    @headers.keys.map { |key| '-' * (@col_lengths[key] + 2) }.join('+')
  end
end
