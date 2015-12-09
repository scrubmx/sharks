require 'sharks/version'
require 'sharks/digitalocean'
require 'formatador'
require 'colorize'
require 'thor'
require 'net/ssh'

module Sharks

  class Console < Thor

    desc "up [NUMBER]", "Start a batch of load testing servers."
    option :number, :default => 2
    # UP: Create new instances (API call to Digital Ocean).
    def up(number=2)
      puts "Starting #{number} load testing servers..."

      digitalocean.create number

      success "Succesfully created #{number} new sharks! Run [sharks report] to see if they are ready to attack."
    end

    desc "down", "Shutdown and deactivate the load testing servers."
    # Terminate instances (API call to Digital Ocean).
    def down
      puts "The instances are now being terminated..."

      digitalocean.destroy_all
    end

    desc "attack", "Begin the attack on a specific url."
    option :url, :required => true
    # Begin the attack on a specific url.
    def attack  
      sharks = digitalocean.droplets.select { |droplet| droplet["name"] == "shark" }

      # TODO: create threads for each ssh connection
      for i in 0..(sharks.length - 1) 
        host = sharks[i]["networks"]["v4"].first["ip_address"]
        ssh = Net::SSH.start(host, 'root')
        ssh.exec!("sudo apt-get install apache2-utils -y > /dev/null")
        puts ssh.exec!("ab -n 1000 -c 100 #{options[:url]}")        
      end
    end

    desc "report", "Report the status of the load testing servers."
    # Display the available droplets and their status
    def report
      puts "Getting status of the load testing servers..."

      sharks = digitalocean.droplets.select { |droplet| droplet["name"] == "shark" }

      return warning "You don't have any sharks yet! Try running [sharks up] first" if sharks.empty?

      Formatador.display_table sharks, ["id", "name", "status", "region.name", "size.price_hourly"]
    end

    desc "token", "Add the API token to the configuration file."
    option :token, :required => true
    # Save the token to storage.
    def token
      puts options[:token]
      puts "Add the API token to the configuration file."
    end

    private 

    def digitalocean
      @digitalocean ||= DigitalOcean.new
    end

    def warning(message)
      puts "\n\r"+message.colorize(:yellow)
    end

    def success(message)
      puts "\n\r"+message.colorize(:green)
    end

  end
end
