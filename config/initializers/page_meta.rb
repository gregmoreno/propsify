module PageMeta
  # TODO: Add more keywords
  KEYWORDS_INFO = [
    { :keywords    => %w(fitness gym trainer exercise sports workout outdoor),
      :description => "Fitness Sports Gym, Club, Centre, Personal Trainer"
    },
    { :keywords    => %w(yoga ashtanga, hatha, pilates, kundalinio, bikram),
      :description => "Yoga Studio, Yoga Exercise, Yoga Classes, Teacher"

    }
  ]

  @@keyword_map = KEYWORDS_INFO.inject({}) do |l, item|
    desc = item[:description]
    item[:keywords].each do |k|
      l[k] = desc
    end
    l
  end
  
  class << self
    def keyword_description(keywords)
      return nil unless keywords
      keywords.each do |keyword|
        if description = @@keyword_map[keyword.downcase]
          return description
        end
      end
      nil
    end
  end

end


