require 'pi_piper'
include PiPiper


puts "Press the switch to get started"

led = PiPiper::Pin.new(pin: 17, direction: :out)

btn_status = 0
led_status = :off
PiPiper.watch pin: 16, direction: :in, pull: :up do |pin|
  btn_status.zero? ? btn_status = 1 : btn_status = 0
  if btn_status == 1
    puts "Pin was pressed"
    led_status == :on ? led_status = :off : led_status = :on
    led.send(led_status)
  else
    puts "Button was released"
  end
end

PiPiper.wait
