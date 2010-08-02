# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_md2_session',
  :secret      => '10592f376cd3c0334d12c105e7525e312f503dcdc3cfd49596d16de306fe37ff4fd0cff01b7e7129182e10733a5c07748ea0a52d4d25f685b06b21bcaf29e0dd'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
