require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'json'
end

require 'tempfile'

KEYCODE_B = '0x0B'
KEYCODE_C = '0x08'

class Runloop
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
keycode_c = 0x08;
keycode_b = 0x0B;
enterDown = $.CGEventCreateKeyboardEvent($(), #{keycode}, true);
enterUp = $.CGEventCreateKeyboardEvent($(), #{keycode}, false);
$.CGEventPostToPid(pid, enterDown);
delay(0.1);
$.CGEventPostToPid(pid, enterUp);
pid
    JS
  end


  private

  def exec(js)
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

Runloop.new.call
