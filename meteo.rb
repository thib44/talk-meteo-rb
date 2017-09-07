require 'rubygems'
require "dht-sensor-ffi"
require 'pi_piper'
require_relative 'lib/temperature_pressure_sensor.rb'
include PiPiper
require 'net/http'
require 'json'


def send_meteo(temperature, pressure, humidity)
  uri = URI('https://finot-meteo.herokuapp.com/meteos')
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  req = Net::HTTP::Post.new(uri.path, 'Content-Type' => 'application/json')
  req.body = { temperature: temperature, pressure: pressure, humidity: humidity }.to_json
  puts req.body
  res = http.request(req)
end


led = PiPiper::Pin.new(pin: 17, direction: :out)

btn_status = 0
led_status = :off

PiPiper.watch pin: 16, direction: :in, pull: :up do
  btn_status.zero? ? btn_status = 1 : btn_status = 0
  if btn_status == 1
   puts "Pin was pressed"
    if led_status == :on
      led_status = :off
      led.send(led_status)
    else
      led_status = :on
      led.send(led_status)
      temperature_humidity = DhtSensor.read(21, 11)
      temperature_pressure = TemperaturePressureSensor.new('/dev/i2c-1')
      temperature_pressure = temperature_pressure.read(3)
      puts "DHT11 : humidite : #{temperature_humidity.humidity}, temperature : #{temperature_humidity.temperature}"
      puts "BMP180 : pression: #{temperature_pressure.pressure}, temperature : #{temperature_pressure.temp}"
      send_meteo(temperature_pressure.temp, temperature_pressure.pressure, temperature_humidity.humidity)
      led_status = :off
      led.send(led_status)
    end
  else
    puts "Button was released"
  end
end

PiPiper.wait
