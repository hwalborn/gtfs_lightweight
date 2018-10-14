# THIS IS THE FIRST ITERATION OF HOLT'S AWESOME COUNTDOWN CLOCK

# TO RUN THE PROGRAM:
* cd into the directory
* `ruby server_control.rb run`

## ADDING THE API KEY
For security reasons, I have placed my API Key in an environment variable and included it in the git ignore. You'll need to add your own api_key.rb file under the env directory and place the following code into it
```ruby
module ApiKey
  KEY = 'YOUR API KEY'
end
```

## GEMS THIS PROGRAM USES:
* 'gtfs-realtime'
* 'rpi_gpio'
* 'daemons'

## NOTES:
* This program will only run on a Linux machine... the rpi_gpio gem
requires an ubuntu OS
* Light colors mean the following:
  * Blue: the train is between 20 and 30 minutes away
  * Green: the train is between 10 and 20 minutes away
  * Yellow: the train is between 7 and 10 minutes away
  * Red: the train is between 5 and 7 minutes away
