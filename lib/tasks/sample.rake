namespace :sample do
  desc 'Load sample data'
  task :load => [
    'cleanup',
    'workspaces',
    'workspaces:comments',
    'workspaces:votes',
    'users:password'
  ] 


  desc 'Cleanup the db'
  task :cleanup => [:environment, 'votes:purge', 'comments:purge', 'workspaces:purge', 'users:purge']
  
  namespace :users do
    desc 'Set user password to "password" (sans quote)'
    task :password => :environment do
      User.transaction do
        User.all.each do |u|
          u.password = 'password'
          u.save
        end
      end
    end

    task :purge => :environment do
      User.transaction do
        User.delete_all
      end
    end
  end

  desc 'Populate workspaces'
  task :workspaces => :environment do
    require 'csv'
   
    ThinkingSphinx.updates_enabled = false

    path = File.join(RAILS_ROOT, 'spec', 'fixtures', 'workspaces.csv')

    Country.current = Country.find_by_name('Canada')

    User.transaction do
      CSV.open(path, 'r') do |row|
        $stdout << "Adding #{row[0]} ..."
       
        Authorization.current_user = if row[2].nil?
          random_user
        else
          User.find_by_email_or_create(:email => row[2].strip.downcase, :name => random_name)
        end

        if row[6]
          subdivision = Country.current.subdivisions.find_by_code(row[6].strip.upcase)
        else
          subdivision = nil
        end

        city = subdivision.nil? ? nil : subdivision.cities.find_by_name(row[5].strip)
        
        if Authorization.current_user.nil? or city.nil?
          puts " ERROR"
        else
          w = Authorization.current_user.workspaces.new(
            :name => row[0], 
            :contact_numbers => row[3],
            :tag_list => random_tags.join(' '),
            :location_attributes => {
              :country_id => Country.current.id,
              :country_subdivision_id => subdivision.id,
              :city_id => city.id,
              :postal_code => row[7],
              :street_address => row[4]
            })
          begin
            w.save!
            puts " done"
          rescue
            puts " failed"
          end
        end
      end
    end
  end

  namespace :workspaces do
    desc 'Purge workspaces'
    task :purge => [:environment, 'votes:purge', 'comments:purge'] do
      ThinkingSphinx.updates_enabled = false

      Workspace.transaction do
        Workspace.destroy_all
      end
    end

    desc 'Add workspace comments'
    task :comments => :environment do
      texts = load_comment_samples
      upper = texts.size

      Workspace.transaction do
        Workspace.all.each do |w|
          n_comments = rand(upper) + 1
          $stdout << "Adding #{n_comments} comments to #{w.name} ..."
          1.upto(n_comments) do |i|
            user = random_user 
            # TODO: no comment duplicate
            c = w.comments.new(:text => texts[rand(upper)], :user => user, :created_at => random_date)
            c.save!
          end
          puts " done"
        end
      end
    end

    desc "Add workspace votes"
    task :votes => :environment do 
      texts = load_comment_samples
      upper = texts.size

      ThinkingSphinx.updates_enabled = false

      Workspace.find(:all, :conditions => "votes_up < 1").each do |w|
        votes = rand(20) + 1 
        $stdout << "Adding #{votes} votes to #{w.name} ..."
        1.upto(votes) do 
          Authorization.current_user = random_user
          happy = (rand(4) > 0) ? true : false
          v = w.votes.new(:vote => happy, :voter => Authorization.current_user, :created_at => random_date)
          v.save

          # Randomly add a comment to a vote
          if rand(2) == 1
            c = w.comments.new :text => texts[rand(upper)], :user => Authorization.current_user, :vote => v,
              :created_at => v.created_at 
            c.save
          end
        end
        puts " done"
      end
    end

  end  # Workspace

  namespace :votes do 
    task :purge => :environment do 
      Vote.transaction do 
        Vote.delete_all
        Workspace.update_all("votes_up=0, votes_down=0, votes_rating=0")
      end
    end
  end


  namespace :comments do 
    task :purge => :environment do 
      Comment.transaction do 
        Comment.delete_all
      end
    end
  end

  def random_user(id_limit=20)
    user_id = rand(id_limit)
    User.find_by_email_or_create(:email => "#{random_name.downcase}#{user_id}@propsify.com", 
                                 :name  => random_name) 
  end

  def load_comment_samples
    path = File.join(RAILS_ROOT, 'spec', 'fixtures', 'comments.csv')
    texts = []
    File.open(path) do |f|
      texts = f.readlines
    end
    texts.each do |t|
      t.strip!
      t.gsub!(/\\n/, "\n")
    end
  end

  def random_name
    names = ['Greg', 'Donna', 'Gabo', 'Dax', 'Ding', 'Grace', 'Budz', 'Enso', 'Vivian', 'Gerald', 'Greggie',
      'Chard', 'Michelle', 'Migz', 'Ancie', 'Jade', 'Shiela', 'Basti', 'Vener', 'Jeng', 'Jun', 'Bessy',
      'Boyd', 'Mau', 'Vania', 'KC', 'Charm', 'Rema', 'Jermain', 'Gabby']
    names[rand(names.size)]
  end

  def random_date
    rand(100).days.ago
  end

  def random_tags
    tags = %w(dentist gym spa skin chiropractor orthodontist eye)
    list = []
    limit = tags.size
    0.upto(rand(limit)) do
      tag = tags[rand(limit)]
      list << tag unless list.include?(tag)
    end
    list
  end

end
