require 'singleton'

class TableCellConversions
  include Singleton
  
  attr_reader :as_methods # => {'as_NilClass' => 'NilClass', ...}
  AS_METHOD_REGEXP = /as_(.+?)/
  
  def initialize
    mth = self.class.private_methods - Object.private_methods
    @as_methods = mth.map do |m|
      match = AS_METHOD_REGEXP.match(m)
      match[1] ? [m, match[1]] : nil
    end.compact.to_h
  end
  
  def apply_to(value)
    nearest_class = @as_methods.find { |m, klass| value.is_a?(klass) }
    nearest_class ? @as_methods[nearest_class].call(value) : default_conv(value)
  end
  
  private
  
  def as_NilClass(value)
    [:right, 'nil']
  end

  def as_TrueClass(value)
    [:right, 'true']
  end
  
  def as_FalseClass(value)
    [:right, 'false']
  end
  
  if defined?(Number)
    define_method(:as_Number) do |value| [:right, value.to_s] end
  else
    define_method(:as_Fixnum) do |value| [:right, value.to_s] end
    define_method(:as_Float) do |value| [:right, value.to_s] end
  end
  
  def default_conv(value)
    [:left, value.to_s]
  end
end

class TableOutput
  attr_reader :data, :headers, :col_lengths
  attr_accessor :conversions
  
  def initialize(options = {})
    headers = options.delete(:headers)
    @conversions = options.delete(:conversions) || TableCellConversions.instance
    
    raise ArgumentError, "Unused args: #{options.keys}" unless options.empty?
    
    @data = [] # cell: [align, value]
    initialize_with_headers(headers)
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
    row.map { |value| @conversions.apply_to(value) }
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
  
  def initialize_with_headers(headers)
    @col_lengths = []
    if headers
      set_headers(headers)
    else
      @headers = []
    end
  end
end

class HashTableOutput < TableOutput
  private
  
  def initialize_with_headers(headers)
    @col_lengths = {}
    if headers
      set_headers(headers)
    else
      @headers = {}
    end
  end
  
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
    row.map { |value| [key, @conversions.apply_to(value)] }.to_h
  end
  
  def row_to_s(row, bars = true)
    @headers.keys.map { |key| pad_cell(row[key], key) }.join(bars ? ' |' : '')
  end
  
  def horizontal_bar
    @headers.keys.map { |key| '-' * (@col_lengths[key] + 2) }.join('+')
  end
end
