# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
 # env :PATH, '/usr/lib/lightdm/lightdm:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games'
 # set :environment, :development
 # set :output, "/media/New\ Volume/RailsApp/bestnights/log/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# every 2.minutes do
# 	command "puts 'Hello'"
# 	runner "Hotel.notify"
# end

require 'rufus-scheduler'

s = Rufus::Scheduler.new

# Awesome recurrent task...
#
s.cron '45 2 4 * *' do
  Hotel.notify
end


# Learn more: http://github.com/javan/whenever
