require 'byebug'

require_relative 'models/countdown_list'

loop do
  countdown_list = CountdownList.new()
  puts json: countdown_list.upcoming_departures
  puts countdown_list.next_refresh
  sleep(countdown_list.next_refresh)
end
