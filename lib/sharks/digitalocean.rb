require 'http'
require 'json'
require 'terminal-table'

module Sharks
  class DigitalOcean

    droplets = []

    def droplets
      response = HTTP.headers({
        accept: "application/json", 
        authorization: "Bearer 158f23060f07d9880bd8076a2cba88d4b90b51011f60675b15392e3bb473db6f"
      }).get("https://api.digitalocean.com/v2/droplets")

      json = JSON.parse(response.body.to_s)

      rows = []
      json["droplets"].each do |d|
        if d['name'] == 'shark'
          rows << [
            d['id'], 
            d['name'], 
            d['status'], 
            d['networks']['v4'][0]['ip_address'], 
            d['region']['name'], 
            d['size']['price_hourly']
          ]
        end
      end

      Terminal::Table.new :headings => ['ID', 'Name', 'Status', 'IP', 'Region', 'Price Hourly'], :rows => rows
    end

    def create(instances)
      response = HTTP.headers({
        accept: "application/json", 
        authorization: "Bearer 158f23060f07d9880bd8076a2cba88d4b90b51011f60675b15392e3bb473db6f"
      }).get("https://api.digitalocean.com/v2/account/keys")

      ssh_key_id = JSON.parse(response.body.to_s)['ssh_keys'].first['id']

      for i in 1..instances.to_i
        HTTP.headers({
          accept: "application/json", 
          authorization: "Bearer 158f23060f07d9880bd8076a2cba88d4b90b51011f60675b15392e3bb473db6f"
        }).post("https://api.digitalocean.com/v2/droplets", json: { 
          name: "shark",
          region: "nyc3",
          size: "512mb",
          image: "ubuntu-14-04-x64",
          ssh_keys: [ssh_key_id]
        })
      end
    end

    private 

    def create_droplet

    end 

  end
end