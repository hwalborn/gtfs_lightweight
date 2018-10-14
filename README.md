# THIS IS THE FIRST ITERATION OF THE COUNTDOWN CLOCK
# USING RUBY FOR HOLT'S AWESOME COUNTDOWN CLOCK

# TO RUN THE PROGRAM:
* cd into the directory
* `ruby server_control.rb run`

## GEMS THIS PROGRAM USES:
* 'gtfs-realtime'
* 'rpi_gpio'
* 'concurrent'
* 'daemons'

## NOTES:
* This program will only run on a Linux machine... the rpi_gpio gem
requires an ubuntu OS
* Light colors mean the following:
  * Blue: the train is between 20 and 30 minutes away
  * Green: the train is between 10 and 20 minutes away
  * Yellow: the train is between 7 and 10 minutes away
  * Red: the train is between 5 and 7 minutes away
