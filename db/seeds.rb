# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Country.delete_all
usa = Country.create(country: "U.S.A", abbreviation: "USA")
canada = Country.create(country: "Canada", abbreviation: "canada")

State.delete_all
us_states = [["AK", "Alaska"], 
          ["AL", "Alabama"],
          ["AR", "Arkansas"], 
          ["AZ", "Arizona"], 
          ["CA", "California"], 
          ["CO", "Colorado"], 
          ["CT", "Connecticut"], 
          ["DC", "District of Columbia"], 
          ["DE", "Delaware"], 
          ["FL", "Florida"], 
          ["GA", "Georgia"], 
          ["HI", "Hawaii"], 
          ["IA", "Iowa"], 
          ["ID", "Idaho"], 
          ["IL", "Illinois"], 
          ["IN", "Indiana"], 
          ["KS", "Kansas"], 
          ["KY", "Kentucky"], 
          ["LA", "Louisiana"], 
          ["MA", "Massachusetts"], 
          ["MD", "Maryland"], 
          ["ME", "Maine"], 
          ["MI", "Michigan"], 
          ["MN", "Minnesota"], 
          ["MO", "Missouri"], 
          ["MS", "Mississippi"], 
          ["MT", "Montana"], 
          ["NC", "North Carolina"],
          ["ND", "North Dakota"],
          ["NE", "Nebraska"],
          ["NH", "New Hampshire"],
          ["NJ", "New Jersey"],
          ["NM", "New Mexico"],
          ["NV", "Nevada"],
          ["NY", "New York"],
          ["OH", "Ohio"],
          ["OK", "Oklahoma"],
          ["OR", "Oregon"],
          ["PA", "Pennsylvania"], 
          ["RI", "Rhode Island"], 
          ["SC", "South Carolina"], 
          ["SD", "South Dakota"], 
          ["TN", "Tennessee"], 
          ["TX", "Texas"], 
          ["UT", "Utah"], 
          ["VA", "Virginia"], 
          ["VT", "Vermont"], 
          ["WA", "Washington"], 
          ["WI", "Wisconsin"], 
          ["WV", "West Virginia"], 
          ["WY", "Wyoming"], 
          ["AK", "Alaska"], 
          ["AL", "Alabama"], 
          ["AR", "Arkansas"], 
          ["AZ", "Arizona"], 
          ["CA", "California"], 
          ["CO", "Colorado"], 
          ["CT", "Connecticut"],
          ["DC", "District of Columbia"],
          ["DE", "Delaware"],
          ["FL", "Florida"],
          ["GA", "Georgia"],
          ["HI", "Hawaii"],
          ["IA", "Iowa"],
          ["ID", "Idaho"],
          ["IL", "Illinois"],
          ["IN", "Indiana"],
          ["KS", "Kansas"],
          ["KY", "Kentucky"],
          ["LA", "Louisiana"],
          ["MA", "Massachusetts"],
          ["MD", "Maryland"],
          ["ME", "Maine"],
          ["MI", "Michigan"],
          ["MN", "Minnesota"],
          ["MO", "Missouri"],
          ["MS", "Mississippi"],
          ["MT", "Montana"],
          ["NC", "North Carolina"],
          ["ND", "North Dakota"],
          ["NE", "Nebraska"],
          ["NH", "New Hampshire"],
          ["NJ", "New Jersey"],
          ["NM", "New Mexico"],
          ["NV", "Nevada"],
          ["NY", "New York"],
          ["OH", "Ohio"],
          ["OK", "Oklahoma"],
          ["OR", "Oregon"],
          ["PA", "Pennsylvania"],
          ["RI", "Rhode Island"],
          ["SC", "South Carolina"],
          ["SD", "South Dakota"],
          ["TN", "Tennessee"],
          ["TX", "Texas"],
          ["UT", "Utah"],
          ["VA", "Virginia"],
          ["VT", "Vermont"],
          ["WA", "Washington"],
          ["WI", "Wisconsin"],
          ["WV", "West Virginia"],
          ["WY", "Wyoming"]]

us_states.each do |abbr, state|
  State.create(country_id: usa.id, state_province: state, abbreviation: abbr)
end

canada_states = [["AB", "Alberta"], ["BC", "British Columbia"],["MB", "Manitoba"],["NB", "New Brunswick"],["NF", "Newfoundland"],["NS", "Nova Scotia"],["ON", "Ontario"],["PE", "Prince Edward Island"],["QC", "Quebec"],["SK", "Saskatchewan"],["YT", "Yukon"]]


canada_states.each do |abbr, state|
  State.create(country_id: canada.id, state_province: state, abbreviation: abbr)
end

