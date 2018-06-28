require 'thor'

module GitTimer
  class Timer < Thor
    desc "work ACTION", "This will start or stop your work tracking"
    long_desc <<-WORK

    `work start` will insert 'Work started | 2018-01-01 00:00:00 -0300' in the git log

    `work stop` will insert 'Work stopped | 2018-01-01 00:00:00 -0300' in the git log

    With the timestamp being the current time with the format %yyyy-MM-dd hh:mm:ss time_zone
    WORK
    option :upcase
    def work(action)
      "#{action}".upcase! if options[:upcase]
      puts action
    end
  end
end
