require "httparty"

module Candidates
  class Candidate
    attr_accessor :username, :real_name, :location, :email, :company, :bio, :hireable, :created, :repos, :followers

    def initialize(username)
      response = HTTParty.get("https://api.github.com/users/#{username}")

      raise response.parsed_response.inspect unless response.code == 200

      user_data = response.parsed_response

      @username = user_data["login"]
      @real_name = user_data["name"]
      @location = user_data["location"]
      @email = user_data["email"]
      @company = user_data["company"]
      @bio = user_data["bio"]
      @hireable = user_data["hireable"]
      @created = user_data["created_at"]
      @repos = user_data["public_repos"]
      @followers = user_data["followers"]
    end

    def org_count
      HTTParty.get("https://api.github.com/users/#{username}/orgs").parsed_response.length
    end

    def org_names(array_of_orgs)
      incrementor = 1
      HTTParty.get("https://api.github.com/users/#{username}/orgs").parsed_response.each do |org_hash|
        puts "#{incrementor}. #{org_hash["login"]}"
        incrementor += 1
      end
    end
  end
end