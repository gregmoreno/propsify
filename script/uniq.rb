# Assumes source is sorted by key already

KEY_POS = 0
File.open(ARGV.first) do |f|
  prev_line = f.gets
  prev_key  = prev_line.split(',')[KEY_POS]

  while (line = f.gets)
    values = line.split(',')
    cur_key = values[KEY_POS]
    if prev_key != cur_key
      puts prev_line
      prev_key  = cur_key
      prev_line = line
    end
  end
end
