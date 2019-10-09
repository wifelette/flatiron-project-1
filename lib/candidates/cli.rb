require "thor"
require "httparty"
require "pastel"
require "awesome_print"
require "tty-prompt"
require "progressbar"

module Candidates
  PASTEL = Pastel.new
  class Cli < Thor
    def help(*)
      puts ""
      print_wrapped <<~INTRO
        #{PASTEL.magenta.bold('Are you tired of needing to use your 👀 to evaluate your candidates past 🏃‍♀️ record on Github? Are you tired of needing to, ugh, type URLs into your browser?! Have no fear! The `candidates` gem is here! 😊.')}

        #{PASTEL.magenta.bold('Use `candidates help` along the way to remind yourself of all the super cool things you can do..')} 
      INTRO

      puts

      super
    end

    desc "user USERNAME", "Gets info about a Github user"
    def user(username)
      candidate = Candidate.new(username)
      puts ""
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

    desc "company USERNAME", "Returns the company the candidate publicly associates with"
    def company(username)
      candidate = Candidate.new(username)
      puts candidate.company
    end

    no_commands do 
      def prompts(username)
        prompt = TTY::Prompt.new
        choices = [
          "Look up #{username}'s general information", 
          "Tell me about the orgs #{username} belongs to", 
          "Look up a different candidate",
          "Remind me what the #{PASTEL.magenta.bold("`candidates`")} gem can do", 
          "Exit the program"
        ]
        prompt.select("How can I help you learn about #{PASTEL.magenta.bold("#{username}")}?", choices)
      end
    end

    desc "wizard", "Asks the user for input and helps them with subsequent questions"
    def wizard
      prompt = TTY::Prompt.new

      puts ""
      say <<~WRAPPED
        #{PASTEL.magenta.bold("Hello friend! This tool is designed to help you look up information about the developer candidate you've been tasked with assessing. So first thing's first: what's the Github username of the candidate?")}
      WRAPPED
      puts ""
      username = prompt.ask("")
      new_candidate = Candidate.new(username)

      loop do
        puts ""
        response = prompts(username)
        
        if response == "Look up #{username}'s general information"
          puts ""
          user(username)
        elsif response == "Tell me about the orgs #{username} belongs to"
          puts ""
          puts "#{username} is a member of #{new_candidate.org_count} organizations."
          puts ""
          org_details = prompt.yes?("Do you want a list of all their details? This could take a while.")
          puts ""
          if org_details == true
            puts "Happy to help. Fetching the data now..."
            puts ""
            progressbar = ProgressBar.create
            # Right now this is just making a random progressbar that then disappear; gotta revisit later
            4.times { progressbar.increment; sleep 1 }
            # Loop in here to return an array of the names of all the user's orgs
            orgs(username)
            # Restart the loop again with the choices
          else
            puts "Wise choice. What's next?"
            puts ""
          end
        elsif response == "Look up a different candidate"
          username = prompt.ask("What's the Github username of this next candidate?")
          new_candidate = Candidate.new(username)
          choices
          # need a way to restart the loop here. Probably need to extract some bit of this to another function so I can call it again. 
          # Choices could perhaps be a method too, that's passed the new username for string interpolation
        elsif response == "Remind me what the #{PASTEL.magenta.bold("`candidates`")} gem can do"
          puts ""
          help
        elsif response == "Exit the program"
          puts ""
          puts "#{PASTEL.magenta.bold('Goodbye then!')}"
          exit
        end
      end
    end
  end
end
