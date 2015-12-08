require "sharks/version"
require "sharks/digitalocean"
require "thor"

module Sharks

  class Console < Thor

    desc "up [NUMBER]", "Start a batch of load testing servers."
    option :number, :default => 2
    # UP: Create new instances (API call to Digital Ocean).
    def up(number=2)
      puts "Starting #{number} load testing servers..."
      response = digitalocean.create number
    end

    desc "down", "Shutdown and deactivate the load testing servers."
    # Terminate instances (API call to Digital Ocean).
    def down
      puts "The instances are now being terminated..."
      
    end

    desc "attack", "Begin the attack on a specific url."
    option :url, :required => true
    # Use ssh library to run the apache bench test.
    def attack
      puts options[:url]
      puts "You don't have any droplets yet! Try running sharks up first"
    end

    desc "report", "Report the status of the load testing servers."
    # Display the available droplets and their status
    def report
      puts "Getting status of the load testing servers..."
      puts digitalocean.droplets
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

  end
end
