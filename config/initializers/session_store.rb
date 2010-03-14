# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_crawwwl2.0_session',
  :secret      => 'a426afd6a6cc9ee5a116bcbdf2632f5ffd723f0ef2bab6d39b4dfad6488232649163239ef284db71ac973f692f543f97fb2cc70c687f7e54b1053f956903d29b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
