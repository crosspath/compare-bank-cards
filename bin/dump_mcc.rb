#!/usr/bin/env ruby
require 'open-uri'
require 'json'

# PREFERENCES

source_file = 'https://github.com/clearhaus/mcc-codes/raw/master/mcc_codes.json'
target_file = 'mcc.rb'

# skip all descriptions with upcase letters - MCC for a company
SKIP_UPCASE = true

mcc_rb_template = ->(inner) { "module MCC\n#{inner}end\n" }

descriptions_pref_order = [
  'edited_description',
  'irs_description',
  'combined_description',
  'usda_description'
]
get_description = ->(hash) do
  # return first non-empty string
  descriptions_pref_order.each do |key|
    return hash[key] unless hash[key].empty?
  end
  nil
end
get_words = ->(name) do
  name.gsub!(/[^A-z\s\/\-\d]/, '')
  name.gsub!(/[\s\/\-]+/, ' ') # remove duplications, treat some symbols as spaces
  name.gsub!(/^[^A-z]+/, '')
  words = name.split(' ').map(&:upcase)
  words.reject! { |w| ['AND', 'OR', 'THE'].include?(w) }
  words
end
create_const = ->(hash) do
  label = get_description.call(hash)
  return nil if label.nil? || label.empty?
  return nil if SKIP_UPCASE && label !~ /[a-z]/ # company name is in upcase
  name = get_words.call(label)
  mcc = hash['mcc'].gsub(/^0+/, '') # remove leading zeros (0n means octal number)
  [name, mcc]
end

shortest_name = ->(name, names) do
  names = names - [name]
  name.reduce([]) do |a, e|
    e = a + [e]
    if e.size < 2 || e.last == 'NOT' || e.last.size < 2
      e # to get more meaningful names
    # if any other name starts the same
    elsif names.find { |words| words[0 .. (e.size - 1)] == e }
      e # take one more word from `name`
    elsif e[-1] == e[-2]
      return a
    else
      return e
    end
  end
  name
end

mcc_const_template = ->(const_name, const_value) do
  "  #{const_name} = #{const_value}\n"
end

fixes = {
  ['AEORFLOT'] => ['AEROFLOT'],
  ['MENS', 'BOYS', 'CLOTHING', 'ACCESSORIES', 'STORES'] => ['MENS', 'BOYS', 'CLOTHING'],
  ['MENS', 'WOMENS', 'CHILDRENS', 'UNIFORMS', 'COMMERCIAL', 'CLOTHING'] => ['UNIFORMS', 'COMMERCIAL', 'CLOTHING'],
  ['MOTION', 'PICTURE', 'THEATERS'] => ['CINEMAS'],
  ['MOTION', 'PICTURES', 'VIDEO', 'TAPE', 'PRODUCTION', 'DISTRIBUTION'] => ['VIDEO', 'PRODUCTION', 'DISTRIBUTION'],
  ['NEW', 'YORK', 'NEW', 'YORK', 'HOTEL', 'CASINO'] => ['NEW', 'YORK', 'HOTEL', 'CASINO'],
  ['TIRE', 'RE', 'TREADING', 'REPAIR', 'SHOPS'] => ['TIRE'],
  ['UNION', 'DE', 'TRANSPORTS', 'AERIENS', 'UTA', 'INTERAIR'] => ['UTA', 'INTERAIR'],
  ['WOMENS', 'READY', 'TO', 'WEAR', 'STORES'] => ['WOMENS', 'WEAR']
}

# DOWNLOAD

puts 'Downloading mcc_codes.json...'
content = open(source_file).read

# WRITE

puts "Ok, creating mcc.rb in current path (#{File.join(Dir.pwd, target_file)})..."
File.open(target_file, 'w') do |f|
  json = JSON.parse(content)
  constants = json.reduce({}) do |a, hash|
    key, value = create_const.call(hash)
    a[key] = value if key && !a.key?(key) # do not overwrite values
    a
  end
  fixes.each do |from, to|
    value = constants.delete(from)
    constants[to] = value if value
  end
  # create short names for constants
  keys = constants.keys.sort
  new_constants = keys.map do |k|
    [shortest_name.call(k, keys).join('_'), constants[k]]
  end
  # write data into file
  inner = new_constants.map { |k, v| mcc_const_template.call(k, v) }.join
  f << mcc_rb_template.call(inner)
end

puts 'Done'
