class CountriesController < ApplicationController
  
  ## POST ajax
  def fetch_states
    p params
    country = Country.find(params[:country_id])
    @states = country.states
  end
end