ActionMailer::Base.smtp_settings = {
  :address        => "mail.pandayan.com",
  :port           => 2525,
  :domain         => "pandayan.com",
  :user_name      => "notify+pandayan.com",
  :password       => "papacologne",
  :authentication => :login
}

