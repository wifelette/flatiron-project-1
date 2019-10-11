require "httparty"
# This next bit is for formatting the Created date to something human-helpful. Date comes with Ruby, and Twitter.cldr uses it.
require "date"

module Candidates
  class Candidate
    attr_accessor :username, :real_name, :location, :email, :company, :bio, :hireable, :created, :repos, :followers

    def initialize(username)
      response = HTTParty.get("https://api.github.com/users/#{username}")

      # This next line helps me figure out when I've been rate limited
      unless response.code == 200
        raise MissingUserError, username
      end

      user_data = response.parsed_response

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

    def orgs
      # `@orgs ||= ` means that the first time I make the HTTP request, I can keep reusing it
      @orgs ||= HTTParty.get("https://api.github.com/users/#{username}/orgs").parsed_response
    end

    def org_names
      orgs.each.with_index do |org_hash, i|
        puts "#{i + 1}. #{org_hash['login']}"
      end
    end
  end
end