require 'http'
require 'json'

module Sharks
  class DigitalOcean

    def droplets
      response = HTTP.headers(request_headers).get("https://api.digitalocean.com/v2/droplets")
      json = JSON.parse(response.body)
      json["droplets"]
    end

    def create(instances)
      response = HTTP.headers(request_headers).get("https://api.digitalocean.com/v2/account/keys")
      ssh_key = JSON.parse(response.body)['ssh_keys'].first['id']

      for i in 1..instances.to_i
        HTTP.headers(request_headers).post("https://api.digitalocean.com/v2/droplets", json: { 
          name: "shark",
          region: "nyc3",
          size: "512mb",
          image: "ubuntu-14-04-x64",
          ssh_keys: [ssh_key]
        })
      end
    end

    def destroy_all
      response = HTTP.headers(request_headers).get("https://api.digitalocean.com/v2/droplets")
      json = JSON.parse(response.body)
      sharks = json["droplets"].select { |droplet| droplet["name"] == "shark" }
      sharks.each { |shark| destroy shark['id'] }
    end

    def destroy(id)
      HTTP.headers(request_headers).delete("https://api.digitalocean.com/v2/droplets/#{id}")
    end

    private 

    def request_headers
      {
        accept: "application/json", 
        authorization: "Bearer 158f23060f07d9880bd8076a2cba88d4b90b51011f60675b15392e3bb473db6f"
      }
    end 

  end
end