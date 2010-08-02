namespace :enumerations do

  require 'active_record/fixtures'

  ENUM_DIR = File.join RAILS_ROOT, 'db', 'data', 'enumerations'

  desc "Reload enumerations data from #{ENUM_DIR}. Accepts optional MODEL parameter, a comma-separated string of model names, to reload only those models."
  task :reload => :environment do
    models = Dir["#{ENUM_DIR}/*.yml"].map { |m| File.basename(m, '.yml').classify }
    models &= ENV['MODEL'].split(',').map { |m| m.classify } unless ENV['MODEL'].blank?

    models.each do |model_name|
      model = model_name.constantize
      table = model_name.tableize

      ActiveRecord::Base.connection.execute "TRUNCATE #{table}"

      f = Fixtures.new model.connection, table, model, "#{ENUM_DIR}/#{table}"
      f.insert_fixtures
    end
  end


  desc "Prepare the locations data for use by reload"
  task :prepare do
    # NOTE: Records with non-ascii names are dropped for now
    require 'unicode'

    top_countries = %{CA}
    country_ids = []
    csv_reader('countries') do |r|
      code = r[2].to_s.upcase # Use the ISO2
      if top_countries.include?(code)
        id   = r[0].to_i
        country_ids << id
        name = to_ascii_unicode(r[1].to_s)

        data =  {'id' => id, 'name' => name, 'code' => code}
        data.merge!('priority_country' => true)
        {:key => code, :data => data }
      end
    end

    ignore_ids = [2829] # Somehow this managed to get through
    csv_reader('country_subdivisions') do |r|
      code = r[3].to_s.upcase
      id   = r[0].to_i
      name = to_ascii_unicode(r[2].to_s)
      country_id = r[1].to_i

      if country_ids.include?(country_id)
        key = "#{name.gsub(/[ \'-]+/, '_').downcase}_#{id}"
        {:key => key, :data => {'id' => id, 'name' => name, 'code' => code, 
          'country_id' => country_id}} unless ignore_ids.include?(id)
      end
    end

    csv_reader('cities') do |r|
      id = r[0].to_i
      country_id = r[1].to_i
      country_subdivision_id = r[2].to_i
      name = to_ascii_unicode(r[3])

      if country_ids.include?(country_id)
        key = "#{name.gsub(/[ \'-]+/, '_').downcase}_#{id}"
        {:key => key, :data => {'id' => id, 'name' => name, 'country_id' => country_id,
          'country_subdivision_id' => country_subdivision_id}}
      end
    end
  end

  def to_ascii_unicode(s)
    Unicode.normalize_KD(s).unpack('U*').select{ |cp| cp < 127 }.pack('U*')
  end
  
  def csv_reader(entity)
    csv_raw = "#{ENUM_DIR}/#{entity}.csv"
    csv = CSV::parse(File.open(csv_raw, 'r') {|f| f.read })
    fields = csv.shift
    out = {}
    csv.each do |line|
      r = yield(line)
      out[r[:key]] = r[:data] if r
    end
    File.open("#{ENUM_DIR}/#{entity}.yml", "w") do |f|
      f.puts out.to_yaml
    end
  end

end
