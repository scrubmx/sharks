require 'sharks/version'
require 'sharks/digitalocean'
require 'formatador'
require 'colorize'
require 'thor'
require 'net/ssh'

module Sharks

  class Console < Thor
    desc 'up [NUMBER]', 'Start a batch of load testing servers.'
    option :number, default: 2
    # UP: Create new instances (API call to Digital Ocean).
    def up(number = 2)
      puts "Starting #{number} load testing servers..."

      digitalocean.create number

      success "Succesfully created #{number} new sharks!"
    end

    desc 'down', 'Shutdown and deactivate the load testing servers.'
    # Terminate instances (API call to Digital Ocean).
    def down
      puts 'The instances are now being terminated...'

      digitalocean.destroy_all
    end

    desc 'attack', 'Begin the attack on a specific url.'
    option :url, required: true
    def attack
      droplets = digitalocean.droplets
      sharks = droplets.select { |droplet| droplet['name'] == 'shark' }

      # TODO: use threads to load test in parallel
      sharks.each do |shark|
        host = shark['networks']['v4'].first['ip_address']
        load_test host, options[:url]
      end
    end

    desc 'report', 'Report the status of the load testing servers.'
    # Display the available droplets and their status
    def report
      puts 'Getting status of the load testing servers...'

      droplets = digitalocean.droplets
      sharks = droplets.select { |droplet| droplet['name'] == 'shark' }

      if sharks.empty?
        message = "You don't have any sharks yet! Try running [sharks up] first"
        return warning message
      end

      headers = ['id', 'name', 'status', 'region.name', 'size.price_hourly']

      Formatador.display_table sharks, headers
    end

    desc 'token', 'Add the API token to the configuration file.'
    option :token, required: true
    # Save the token to storage.
    def token
      puts options[:token]
      puts 'Add the API token to the configuration file.'
    end

    private

    def digitalocean
      @digitalocean ||= DigitalOcean.new
    end

    def load_test(host, target_url)
      ssh = Net::SSH.start(host, 'root')
      ssh.exec!('sudo apt-get install apache2-utils -y > /dev/null')
      puts ssh.exec!("ab -n 500 -c 100 #{target_url}")
    end

    def warning(message)
      puts "\n\r" + message.colorize(:yellow)
    end

    def success(message)
      puts "\n\r" + message.colorize(:green)
    end
  end

end
