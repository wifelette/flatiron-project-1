require "thor"
require "httparty"
require "pastel"
require "awesome_print"
require "tty-prompt"
require "tty-markdown"
require "progressbar"

module Candidates
  # Pastel is a tool for coloring text inside the terminal
  PASTEL = Pastel.new
  # TTY adds numerous formatting options for data+copy in the terminal
  PROMPT = TTY::Prompt.new
  # This constant is used by the TTY (sub)gem tty-markdown, also for display stuff
  # In this case I used it to overwrite default markdown styling to get some of my longer text blocks to look the way I wanted them to look.
  THEME = {
    em: [:magenta, :bold],
    header: [:cyan, :bold],
    hr: :yellow,
    link: [:yellow, :underline],
    list: :yellow,
    strong: [:yellow, :bold],
    table: :yellow,
    quote: :yellow,
  }
  class Cli < Thor
    def help(*)
      puts
      help_file = File.expand_path('../../markdown/help.md', __dir__)
      parsed = TTY::Markdown.parse_file(help_file, theme: THEME)
      puts parsed
      puts
      super
    end

    desc "user USERNAME", "Gets info about a Github user"
    def user(username)
      candidate = Candidate.new(username)
      puts
      say <<~WRAPPED
        #{PASTEL.on_magenta("Here's everything you need to know about #{username}:")}

        #{PASTEL.magenta.bold('THEIR BASICS:')}
        
        #{PASTEL.magenta.bold('Name:')} #{candidate.real_name}
        #{PASTEL.magenta.bold('Company:')} #{candidate.company}
        #{PASTEL.magenta.bold('Location:')} #{candidate.location}
        #{PASTEL.magenta.bold('Bio:')} #{
          if candidate.bio.nil?
            'No public bio.'
          else
            "#{candidate.bio}"
          end
        }
        #{PASTEL.magenta.bold('Email:')} #{
          if candidate.email.nil?
            "Their email isn't public."
          else
            "#{candidate.email}"
          end
        }
        #{PASTEL.magenta.bold('Hireable:')} #{
          if candidate.hireable == true
            "#{PASTEL.green.bold('Yes')}"
          elsif candidate.hireable == false
            puts "#{PASTEL.red.bold('No')}"
          else
            'No public response.'
          end
        }
        
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
      WRAPPED
    end

    # Proof of concept. I could in theory write one of these for every candidate attribute.
    desc "company USERNAME", "Returns the company the candidate publicly associates with"
    def company(username)
      candidate = Candidate.new(username)
      puts candidate.company
    end

    # This makes it a private method that won't appear in the Thor help command
    no_commands do 
      def orgs(username)
        HTTParty.get("https://api.github.com/users/#{username}/orgs").parsed_response
      end

      def format_username(username)
        "#{PASTEL.magenta.bold("#{username}")}"
      end
      
      def prompts(username)
        pretty_name = format_username(username)
        choices = [
          { value: :userinfo,    name: "Look up #{pretty_name}'s general information" },
          { value: :orgs,      name: "Tell me about the orgs #{pretty_name} belongs to" },
          { value: :newuser, name: "Look up a different candidate" },
          { value: :help,      name: "Remind me what the #{PASTEL.magenta.bold('`candidates`')} gem can do" },
          { value: :exit,      name: "Exit the program" }
        ]
        PROMPT.select("How can I help you learn about #{pretty_name}?", choices)
      end

      def org_detail(candidate)
        pretty_name = format_username(candidate.username)

        puts
        puts "#{pretty_name} is a member of #{PASTEL.magenta.bold("#{candidate.org_count}")} organizations:"
        puts
        orgs_hashes = orgs(candidate.username)
        candidate.org_names(orgs_hashes)
        puts
        org_details = PROMPT.yes?("Do you want a list of all their details? This could take a while.")
        puts
        if org_details == true
          puts "Happy to help. Fetching the data now..."
          puts
          progressbar = ProgressBar.create
          # Right now this is just making a random progressbar that then disappear; gotta revisit later so it's more meaningful
          4.times { progressbar.increment; sleep 1 }
          # Loop in here to return an array of the names of all the user's orgs
          ap orgs_hashes
          puts
          puts "There you go! #{PASTEL.yellow('ProTip')}: Command + click on any of these URLs in most Terminals to go directly to the link."
          puts
        elsif org_details == false
          puts "Wise choice. What's next?"
        end
      end
    end

    desc "wizard", "Interactive Wizard that asks the user for input and helps them with subsequent questions"
    def wizard
      puts
      prompt_file = File.expand_path('../../markdown/prompt.md', __dir__)
      parsed = TTY::Markdown.parse_file(prompt_file, theme: THEME)
      puts parsed
      puts
      username = PROMPT.ask("")
      new_candidate = Candidate.new(username)

      loop do
        puts
        response = prompts(username)

        case response
        when :userinfo
          puts
          user(username)
        when :orgs
          org_detail(new_candidate)
        when :newuser
          username = PROMPT.ask("What's the Github username of this next candidate?")
          new_candidate = Candidate.new(username)
        when :help
          puts
          help
        when :exit
          puts
          puts "#{PASTEL.magenta.bold('Goodbye then!')}"
          puts
          exit
        end
      end
    end
  end
end
