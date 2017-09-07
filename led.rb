require 'pi_piper'


led = PiPiper::Pin.new(pin: 17, direction: :out)
while true do
  led.on
  sleep(1)
  led.off
  sleep(1)
end
