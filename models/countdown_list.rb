require 'protobuf'
require 'google/transit/gtfs-realtime.pb'
require 'net/http'
require 'uri'
require 'ws2801'

require_relative '../env/api_key.rb'

class CountdownList
  attr_accessor :upcoming_departures,
                :feed_list,
                :next_refresh
  def initialize
    # TODO: THIS COULD BE A GOOD EXTERNAL LIBRARY TO USE
    # WS2801.generate                # generate empty strip (Would happen from alone if you just start setting colors)
    #
    # WS2801.length 25               # default
    # WS2801.device "/dev/spidev0.0" # default
    # WS2801.autowrite true
    #
    # WS2801.set :pixel => :all, :r => 255 # set all to red

    # grab our data from gtfs
    data = Net::HTTP
           .get(URI
           .parse("http://datamine.mta.info/mta_esi.php?key=#{ApiKey::KEY}&feed_id=31"))
    # use the gtfs-realtime-bindings gem to decode it to a feed list
    @feed_list = Transit_realtime::FeedMessage.decode(data).entity
    # make a hash with empty arrays to keep track of our departures
    @upcoming_departures = {
      departure_list_north: [],
      departure_list_south: []
    }
    # declare next_refresh to be 60 (which should be the max number
    # of seconds before we call for updated data)
    @next_refresh = 60
    # make it all happen
    self.build_departure_lists
  end

  def build_departure_lists
    @feed_list.each do |entity|
      # only do this for trips with the trip_update field... it's totally
      # optional for gtfs, so we need to make sure it has it
      if entity.field?(:trip_update)
        # get our stop time data
        departures = entity[:trip_update][:stop_time_update]
        .select do |stop|
          # looking just for the GreenPoint Ave (stop_id = G26) stops...
          stop[:stop_id].include? "G26"
        end
        .map do |stop|
          # get the arrival time from the gtfs data
          arrival_time = stop[:arrival][:time]
          # convert current time to POSIX and then subtract it from
          # the arrival time so we know how many seconds until the
          # arrival of the train. Then divide by 60 to get minutes
          countdown_time = (arrival_time - Time.now.to_f) / 60

          # we don't care about times that have passed or
          # times that are more than 20 minutes away
          if(countdown_time > 0 && countdown_time <= 20)
            # insert into sorted array depending on which direction
            # this train is traveling
            if stop[:stop_id].include? 'N'
              @upcoming_departures[:departure_list_north] = insert_at_index(countdown_time, true)
            else
              @upcoming_departures[:departure_list_south] = insert_at_index(countdown_time, false)
            end
            # update the next_refresh property to keep track of when to update
            find_next_refresh(countdown_time)
          end
        end
      end
    end
  end

  def get_seconds_remaining time
    time.modulo(1) * 60
  end

  def insert_at_index countdown_time, is_north_bound
    # get seconds left so we know when to update
    seconds_remaining = get_seconds_remaining(countdown_time)
    # grab which array we need
    countdown_arry = current_departure_list(is_north_bound)
    # find the index of where this time belongs in the array
    insert_index = get_insert_index(countdown_arry, countdown_time);
    # if countdown_time is the largest value for the array...
    if insert_index == nil
      countdown_arry.push(countdown_time)
    else
      # otherwise, insert it at the index we found
      countdown_arry.insert(insert_index, countdown_time)
    end
  end

  def get_insert_index arry, elm
    # find the index where to insert this countdown_time
    insert_index_arry = [*arry.each_with_index].bsearch{|x, _| x > elm}
    # we got an index to insert?
    if(insert_index_arry != nil)
      insert_index = insert_index_arry.last
    end
    # return the index or nil
    insert_index
  end

  def current_departure_list is_north_bound
    if is_north_bound
      @upcoming_departures[:departure_list_north]
    else
      @upcoming_departures[:departure_list_south]
    end
  end

  def find_next_refresh countdown_time
    # seconds left until the next minute
    seconds_left = (countdown_time % 1) * 60
    # gotta know when we should update data based on
    # when the next train gets a minute closer
    if(seconds_left < @next_refresh)
      @next_refresh = seconds_left
    end
  end
end
