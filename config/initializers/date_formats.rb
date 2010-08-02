date_time_formats = {
  :date     => "%b %d, %Y",
  :Ymd      => "%Y-%m-%d" 
}

ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(date_time_formats)
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(date_time_formats)
