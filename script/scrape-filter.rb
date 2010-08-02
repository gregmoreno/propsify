require 'csv'

data = CSV.readlines(ARGV.first)
data.each do |row|
  
  name = row[0]
  name.strip! if name

  out = false
  out = true if name =~ /\bdr.?\b/i

  ['accounting', 'investor', 'investors', 'lawyer', 'law', 'firm', 'photo',
   'financial', 'financials', 'contracting', 'hospital', 'management',
   'capital', 'counselling', 'goldsmith', 'superstore', 'shampoo', 'utility',
   'pavement', 'planning', 'graphics', 'alarms', 'dog', 'book', 'books', 
   'design', 'storage', 'steel', 'auto', 'car', 'pizza', 'spaghetti', 'food',
   'plumbing', 'hotel', 'public', 'library', 'golf', 'towing',
   'machine', 'society', 'association', 'hotel', 'commerce', 'space', 'spatial',
   'church', 'construction','maintenance'].each do |word|
    if name =~ /\b#{word}\b/i
      out = true
      break
    end
  end

  
  unless out
    ['ltd', 'the', 'inc', 'llc' ,'corp', 'corporation'].each do |word|
      if name =~ /\b#{word}$/i
        name.gsub!(/#{word}$/i, '')
        row[0] = name.strip
        break
      end
    end

    puts CSV.generate_line(row)
  end
end
