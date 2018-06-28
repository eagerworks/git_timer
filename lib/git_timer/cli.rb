require 'thor'

module GitTimer
  class Timer < Thor
    desc "work ACTION", "This will start or stop your work tracking"
    long_desc <<-WORK

    `work start` will insert 'Work | Start | 2018-01-01 00:00:00 -0300' in the user-log file

    `work stop` will insert 'Work | Stop | 2018-01-01 00:00:00 -0300' in the user-log file

    With the timestamp being the current time with the format %yyyy-MM-dd hh:mm:ss time_zone
    WORK

    def work(action)
      case action
        when 'start', 'START', 'Start'
          GitTimer.register_activity({ ticket_id: 'Work', ticket_state: 'Start' })
        when 'stop', 'STOP', 'Stop'
          GitTimer.register_activity({ ticket_id: 'Work', ticket_state: 'Stop' })
        else
          puts 'Invalid action, please use `git_timer start` or `git_timer stop`. Type `git_timer help` for more information.'
      end
    end
  end
end
