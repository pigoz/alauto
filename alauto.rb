require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'awesome_print'
end

class App
  KEYCODE_B = '0x0B'
  KEYCODE_C = '0x08'

  def minutes
    4
  end

  def call
    Timer.new(waittime: 60.0 * minutes + rand(0...5), interval: 10).call do
      osascript = OsaScript.new
      # osascript.keypress(keycode: KEYCODE_B)
      osascript.keypress(keycode: KEYCODE_C)
    end
  end
end

class OsaScript
  def keypress(keycode:)
    # keycodes
    # https://gist.github.com/chipjarred/cbb324c797aec865918a8045c4b51d14
    exec <<-JS
ObjC.import('Carbon')
pid = Application("System Events").processes['Azur Lane'].unixId();
kdown = $.CGEventCreateKeyboardEvent($(), #{keycode}, true);
kup = $.CGEventCreateKeyboardEvent($(), #{keycode}, false);
$.CGEventPostToPid(pid, kdown);
delay(0.1);
$.CGEventPostToPid(pid, kup);
pid
    JS
  end

  private

  def exec(js)
    require 'json'
    require 'tempfile'

    file = Tempfile.new('alauto')
    IO.write(file, js)
    JSON.parse(`osascript -s s -l JavaScript #{file.path}`)
  ensure
    file.close
    file.unlink
  end
end

class Timer
  def initialize(waittime:, interval:)
    @waittime = waittime
    @interval = interval
  end

  def call
    loop do
      yield
      iteration
    end
  end

  def iteration
    waitcount = @waittime
    loop do
      puts "waiting: #{waitcount} seconds left"
      sleep(@interval)
      waitcount -= @interval
      break if waitcount.negative?
    end
  end
end

App.new.call
