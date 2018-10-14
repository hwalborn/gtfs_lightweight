require 'byebug'

require_relative 'models/countdown_list'
require_relative 'models/rpi_service'

loop do
  countdown_list = CountdownList.new()
  rpi_service = RpiService.new(countdown_list)
  sleep(countdown_list.next_refresh)
end
