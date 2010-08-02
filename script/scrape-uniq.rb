# Drop duplicates
# Assumes source is sorted by key already
# 1st pass scrape.rb file.csv  4,5  # address
# 2nd pass scrape.rb file.csv  3 # phone

require 'csv'

def uniq_csv(data, keys)
  prev_line = []
  prev_key  = ''

  uniq_data = data.inject([]) do |list, row|
    cur_key = keys.inject('') do |l, i|
      v = row[i.to_i]
      if v 
        l << v
      else
        l << ''
      end
    end

    cur_key.gsub!(/\s*/, '')

    if prev_key != cur_key
      list << prev_line
      prev_key  = cur_key
      prev_line = row
   end

    list
  end

  uniq_data
end


def sort_csv(data, keys)
  data.sort do |x,y|
    (x[keys.first] || '') <=> (y[keys.first] || '')
  end
end


data = CSV.readlines(ARGV.first)
#i=0
#CSV.open(ARGV.first, 'r') do |row|
#  i = i + 1
#  puts i
#end

keys = [4,5]
p1_data = sort_csv(data, keys) 
p1_uniq = uniq_csv(p1_data, keys)

keys = [3]
p2_data = sort_csv(p1_uniq, keys)
p2_uniq = uniq_csv(p2_data, keys)



p2_uniq.each do |row|
  puts CSV.generate_line(row)
end


#def uniq_csv(file, keys)
#  prev_line = ''
#  prev_key  = ''
#
#  CSV.open(file, "r") do |row|
#    cur_key = keys.split(',').inject('') do |l, i|
#      v = row[i.to_i]
#      if v 
#        l << v
#      else
#        l << ''
#      end
#    end
#  
#    cur_key.gsub!(/\s*/, '')
#    #p cur_key
#  
#    if prev_key != cur_key
#      puts prev_line
#      prev_key  = cur_key
#      prev_line = CSV.generate_line(row) 
#    end
#  end
#end
#
#uniq_csv(ARGV[0], ARGV[1])




