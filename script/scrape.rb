# Scraping tool for directory sites


require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'uri'
require 'csv'

agent = 'Mozilla/5.0 (Windows; U; Windows NT 6.0; fr; rv:1.9b5) Gecko/2008032620 Firefox/3.0b5'


class String
  def sanitize
    self.gsub(/\A[\s\"]*/, '').gsub(/[\"\s]*\Z+/, '').gsub(/\n+/, ' ').gsub(/\s+/, ' ')
  end

  def quotify
    "\"#{self}\""
  end
end

def extract(item, criteria)
  s = item.search(criteria).first.content
rescue
  s = ''
ensure
  return s.sanitize.quotify
end

def scrape_yp(stream)
  doc = Nokogiri::HTML(stream)

  listing = doc.search('.listing');
  entries = listing.inject([]) do |l, item|
    title = extract(item, '.listingTitleLine a span')
    phone = extract(item, '.phoneNumber')
    addr  = extract(item, '.address')
    
    website = email = ''
    item.search('.listingLink').each do |link|
      uri = link.content.sanitize
      unless uri.empty?
        # TODO: I know this are not 100% perfect but it works in
        # this context
        website = uri.quotify if uri.match(/\Awww\..+/)
        email   = uri.quotify if uri.match(/@/)
      end
    end

    values = addr.sanitize.split(',')
    if values.size >= 3
      address = values[0].strip.sanitize.quotify
      city = values[1].strip.sanitize
      prov = values[2].strip.sanitize[0..2]
      zip  = values[2].strip.sanitize[-7..-1]
    else
      address = city = prov = zip = ''
    end

    l << [title, website, email, phone, address, city, prov, zip] 
  end
end

def scrape_email(stream)
  emails = [] 
  email_re = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i

  doc = Nokogiri::HTML(stream)
  emails << doc.to_s.scan(email_re)
  
  doc.search('a').each do |link|
    url = link['href']
    if url =~ /^http:/i
      page = Nokogiri::HTML(open(url))
      emails << page.to_s.scan(email_re)
    end
  end

  emails.flatten.uniq
end


provs = ['on']
keywords = ['fitness']
start = 1
pages =  92

# si-bn => matches business name
# si-alph => matches desc
provs.each do |p|
  keywords.each do |k|
    start.upto(start + pages - 1) do |i|
      url = "http://www.yellowpages.ca/search/si-alph/#{i}/#{k}/#{p}" 
      entries = scrape_yp(open(url, 'User-Agent' => agent))

      f = File.open("#{i}-#{p}-#{k}.csv", "w")
      entries.each do |e|
        e << k
        f.puts e.join(',')
      end
      f.close
    end
  end
end


# given a website, look for email

#File.open(ARGV.first) do |f|
#  while line = f.gets
#    values = line.split(',')
#    url  = values[1]
#    cur_email = values[2]
#    path = (url =~ /^www/ ? "http://#{url}" : url)
#
#    begin
#      emails = scrape_email(open(path, 'User-Agent' => agent))
#      unless emails.empty?
#        unless cur_email.empty? or emails.include?(cur_email)
#          puts line
#        end
#        emails.each do |email|
#          values[2] = email
#          puts values.join(',')
#        end
#      else
#        puts line
#      end
#    rescue Timeout::Error
#      puts line
#    rescue
#      puts line
#    end
#  end
#end


# Split the address into street, city, province, zip
# Yeah, my mistake :)

#
#CSV.open(ARGV.first, "r") do |row|
#  values = row[4].sanitize.split(',')
#  address = values[0].strip.sanitize.quotify
#  city = values[1].strip.sanitize
#  prov = values[2].strip.sanitize[0..2]
#  zip  = values[2].strip.sanitize[-7..-1]
#
#  puts (row[0..3] + [address, city, prov, zip]).join(',')
#
#end


