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

      threads = []

      sharks.each do |shark|
        host = shark['networks']['v4'].first['ip_address']
        threads << Thread.new {
          load_test host, options[:url]
        }
      end

      threads.each { |thread| thread.join }
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
      puts "Shark #{host} is joining the swarm..."
      ssh.exec!('sudo apt-get install apache2-utils -y > /dev/null')
      puts "Shark #{host} firing his lazer, pew pew pew!"
      ssh.exec!("ab -n 1000 -c 100 #{target_url}")
      puts "Shark #{host} is out of ammo."
    end

    def warning(message)
      puts "\n\r" + message.colorize(:yellow)
    end

    def success(message)
      puts "\n\r" + message.colorize(:green)
    end
  end

end
