require "thor"
require "httparty"
require "pastel"
require "awesome_print"

module Candidates
  PASTEL = Pastel.new
  class Cli < Thor
    def help(*)
      print_wrapped <<~INTRO
        #{PASTEL.on_magenta('👋 Hello friend')}.

        Are you tired of needing to use your #{PASTEL.blue('eyes')} to evaluate your candidates past 🏃‍♀️ record on Github? Are you tired of needing to, ugh, type URLs into your browser?! Have no fear! The #{PASTEL.black.bold('candidates')} gem is here! 😊

        Use #{PASTEL.black.bold('candidates help')} along the way to remind yourself of all the super cool things you can do.
      INTRO

      puts

      super
    end

    desc "user USERNAME", "Gets info about a Github user"
    def user(username)
      candidate = Candidate.new(username)
      say <<~WRAPPED
        #{PASTEL.on_magenta("Here's everything you need to know about #{username}:")}

        #{PASTEL.magenta.bold('THEIR BASICS:')}
        
        #{PASTEL.magenta.bold('Name:')} #{candidate.pretty_name}
        #{PASTEL.magenta.bold('Company:')} #{candidate.company}
        #{PASTEL.magenta.bold('Location:')} #{candidate.location}
        #{PASTEL.magenta.bold('Bio:')} #{candidate.bio}
        #{PASTEL.magenta.bold('Email:')} #{candidate.email}
        TODO: If not provided, write Not Public
        #{PASTEL.magenta.bold('Hireable:')} #{candidate.hireable}
        TODO: Yes/No (Yes in Green, No in Red)
        
        #{PASTEL.magenta.bold('THEIR ACTIVITY:')}
        
        #{PASTEL.magenta.bold('Joined GitHub:')} #{candidate.created}
        TODO: 1. (X years and Y months ago), 2. Format the date pretty
        #{PASTEL.magenta.bold('Org Membership:')} #{candidate.org_count}
        #{PASTEL.magenta.bold('Public Repos:')} #{candidate.repos}
        #{PASTEL.magenta.bold('Followers:')} #{candidate.followers}
        
        #{PASTEL.magenta.bold('LISTS FOR LATER:')}
        These are bigger bits of info you may want to dig into later, when you're trying to get a better picture of the Candidate's public activity. 
        #{PASTEL.yellow('ProTip')}: Command + click on any of these URLs in most Terminals to go directly to the link.
        
        #{PASTEL.magenta.bold('Public Gists:')} #{PASTEL.underline("https://gist.github.com/search?utf8=%E2%9C%93&q=user%3a#{username}&s=stars")}
        #{PASTEL.magenta.bold('Followers List:')} #{PASTEL.underline("https://github.com/#{username}?tab=followers")}
        #{PASTEL.magenta.bold('Public Repos:')} #{PASTEL.underline("https://github.com/#{username}?tab=repositories")}
        #{PASTEL.magenta.bold('Starred Repos:')} #{PASTEL.underline("https://github.com/#{username}?tab=stars")}
        #{PASTEL.magenta.bold('Who They Follow:')} #{PASTEL.underline("https://github.com/#{username}?tab=following")}
        
        Type #{PASTEL.black.bold('candidates help')} to learn about how else this tool can help.
      WRAPPED
    end

    desc "orgs USERNAME", "Returns all the Orgs this user belongs to"
    def orgs(username)
      org_data = HTTParty.get("https://api.github.com/users/#{username}/orgs").parsed_response
      ap org_data
    end

    desc "company USERNAME", "returns the company the candidate publicly associates with"
    def company(username)
      candidate = Candidate.new(username)
      puts candidate.company
    end
  end
end