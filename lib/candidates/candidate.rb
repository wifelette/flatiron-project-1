require "httparty"
# This next bit is for formatting the Created date to something human-helpful. Date comes with Ruby, and Twitter.cldr uses it.
require "date"

module Candidates
  class Candidate
    def self.fetch(username)
      # Everything worked before I added this `fetch` method, but I literally did it to tick off the self + class/instance-method check boxes :p 
      response = HTTParty.get("https://api.github.com/users/#{username}")

      # This next line helps me figure out when I've been rate limited
      unless response.code == 200
        raise MissingUserError, username
      end

      user_data = response.parsed_response

      new(user_data)
    end
    
    attr_accessor :username, :real_name, :location, :email, :company, :bio, :hireable, :created, :repos, :followers

    def initialize(user_data)
      @username = user_data["login"]
      @real_name = user_data["name"]
      @location = user_data["location"]
      @email = user_data["email"]
      @company = user_data["company"]
      @bio = user_data["bio"]
      @hireable = user_data["hireable"]
      @created = DateTime.parse(user_data["created_at"])
      @repos = user_data["public_repos"]
      @followers = user_data["followers"]
    end

    def orgs_call
      # `||= ` means that the first time I make the HTTP request, I can keep reusing it
      @orgs_call ||= HTTParty.get("https://api.github.com/users/#{username}/orgs").parsed_response
    end

    def org_names
      orgs_call.map.with_index do |org_hash, i|
        "#{i + 1}. #{org_hash['login']}"
      end
    end
  end
end