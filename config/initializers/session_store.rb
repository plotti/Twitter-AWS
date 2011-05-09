# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_crowd_session',
  :secret      => '5e53d5e6656408d71c4dc0fc61db6efacfe623b23735ff62c64455531476529bba6d2301d875893fcc5d97e440ba0f36362c5ea5beb4f63c9cafee1d948073b2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
