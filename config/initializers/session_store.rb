# Be sure to restart your server when you modify this file.

#Bestnights::Application.config.session_store :cookie_store, key: 'rails_bestnights_session'

Bestnights::Application.config.session_store :active_record_store

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
#Bestnights::Application.config.session_store :active_record_store
#Bestnights::Application.config.session_store :cookie_store, key: 'rails_bestnights_session', :expire_after => 20.minutes
