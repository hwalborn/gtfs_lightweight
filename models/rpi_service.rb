require 'rpi_gpio'

require_relative '../env/color_times.rb'

class RpiService
  attr_accessor :countdown_list_model,
                :light_pins,
                :pin_colors
  def initialize(countdown_list_model)
    @countdown_list_model = countdown_list_model
    # need a list of all pins so that we can easily clear all
    @light_pins = {
      north_blue: 23,
      north_green: 12,
      north_yellow: 16,
      north_red: 20,
      south_blue: 22,
      south_green: 6,
      south_yellow: 13,
      south_red: 26,
    }
    # these are the pins for north and south, the first
    # element in the array is for north, the second is south
    @pin_colors = {
      red: [@light_pins[:north_red], @light_pins[:south_red]],
      yellow: [@light_pins[:north_yellow], @light_pins[:south_yellow]],
      green: [@light_pins[:north_green], @light_pins[:south_green]],
      blue: [@light_pins[:north_blue], @light_pins[:south_blue]]
    }
    # these are rpi_gpio settings that need to be set
    RPi::GPIO.set_numbering :bcm
    RPi::GPIO.set_warnings(false)
    # set the pins as output
    set_output_pins
    # do logic to light all the necessary pins
    light_all_active_pins
  end

  def light_all_active_pins
    # first we have to clear the board of any lit pins
    clear_all_pins
    # do logic to find and light north_bound pins
    find_and_light_pin(@countdown_list_model.upcoming_departures[:departure_list_north], true)
    # do logic to find and light south_bound pins
    find_and_light_pin(@countdown_list_model.upcoming_departures[:departure_list_south], false)
  end

  def find_and_light_pin departure_list, is_north_bound
    # any time that is between 20 and 30 minutes away gets a blue color
    if(departure_list.any? { |dept|  dept <= ColorTimes::BLUEMAX &&
                                     dept > ColorTimes::BLUEMIN })
      light_pin(@pin_colors[:blue], is_north_bound)
    end
    # any time that is between 10 and 20 minutes away gets a green color
    if(departure_list.any? { |dept|  dept <= ColorTimes::BLUEMIN &&
                                     dept > ColorTimes::GREENMIN })
      light_pin(@pin_colors[:green], is_north_bound)
    end
    # any time that is between 7 and 10 minutes away gets a yellow color
    if(departure_list.any? { |dept|  dept <= ColorTimes::GREENMIN &&
                                     dept > ColorTimes::YELLOWMIN })
      light_pin(@pin_colors[:yellow], is_north_bound)
    end
    # any time that is between 5 and 7 minutes away will get a red color
    if(departure_list.any? { |dept|  dept <= ColorTimes::YELLOWMIN &&
                                     dept >= ColorTimes::REDMIN })
      light_pin(@pin_colors[:red], is_north_bound)
    end
  end

  def light_pin pin_colors, is_north_bound
    if is_north_bound
      RPi::GPIO.set_low pin_colors[0]
    else
      RPi::GPIO.set_low pin_colors[1]
    end
  end

  def set_output_pins
    # iterate over pins and set them as outputs
    @light_pins.each do |pin, value|
      RPi::GPIO.setup value, :as => :output
    end
  end

  def clear_all_pins
    # TURN OFF ALL THE LIGHTS!!!
    @light_pins.each do |pin, value|
      RPi::GPIO.set_high value
    end
  end
end
