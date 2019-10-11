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
  # This constant is used by the TTY (sub)gem `tty-markdown`, also for display stuff
  # In this case I used it to overwrite default markdown styling to get some of my longer text blocks to look the way I wanted them to look.
  THEME = {
    em: [:magenta, :bold],
    header: [:cyan, :bold],
    hr: :yellow,
    link: [:yellow, :underline],
    list: :yellow,
    strong: [:yellow, :bold],
    table: :yellow,
    quote: :yellow
  }

  class Cli < Thor
    def help(*)
      # help is a built-in method in Thor; this code is how I can insert text into its output, ahead of the built-in content
      puts
      help_file = File.expand_path('../../markdown/help.md', __dir__)
      parsed = TTY::Markdown.parse_file(help_file, theme: THEME)
      puts parsed
      puts
      super
    end

    # This next line is what tells the built-in `help` command what to display when describing the method
    desc "user USERNAME", "Gets info about a Github user"
    def user(username)
      candidate = Candidate.new(username)
      # There are a lot of puts around; it's just the simplest way to add whitespace in the command line, which makes the tool easier to read/use
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
        # TODO: 1. (X years and Y months ago), 2. Format the date pretty
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

    # This makes what comes after it a private method that won't appear in the Thor help command
    no_commands do 
      def orgs(username)
        HTTParty.get("https://api.github.com/users/#{username}/orgs").parsed_response
      end

      def format_username(username)
        # This exists just because PASTEL makes the copy really hard to scan, and we use the colored Username a lot.
        "#{PASTEL.magenta.bold("#{username}")}"
      end
      
      def prompts(username)
        pretty_name = format_username(username)
        choices = [
          { value: :userinfo, name: "Look up #{pretty_name}'s general information" },
          { value: :orgs,     name: "Tell me about the orgs #{pretty_name} belongs to" },
          { value: :newuser,  name: "Look up a different candidate" },
          { value: :help,     name: "Remind me what the #{PASTEL.magenta.bold('`candidates`')} gem can do" },
          { value: :exit,     name: "Exit the program" }
        ]
        # This format spits out the question, followed by (comma) the options the user can choose from
        PROMPT.select("How can I help you learn about #{pretty_name}?", choices)
      end

      def org_detail(candidate)
        pretty_name = format_username(candidate.username)

        puts
        puts "#{pretty_name} is a member of #{PASTEL.magenta.bold("#{candidate.org_count}")} organizations:"
        puts
        # The next two lines display a numbered list of all the orgs the candidate belongs to
        orgs_hashes = orgs(candidate.username)
        candidate.org_names(orgs_hashes)
        puts
        org_details = PROMPT.yes?("Do you want a list of all their details? This could take a while.")
        puts
        if org_details == true
          puts "Happy to help. Fetching the data now..."
          puts
          progressbar = ProgressBar.create
          # TODO: Right now this is just making a random progressbar that then disappear; gotta revisit later so it's more meaningful
          4.times { progressbar.increment; sleep 1 }
          ap orgs_hashes
          # TODO: It would be fun later to make the orgs display in a table rather than a hash. Try `tty-table`
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
      # This is fetching all the pretty text I want to show here from the .md file
      prompt_file = File.expand_path('../../markdown/prompt.md', __dir__)
      puts TTY::Markdown.parse_file(prompt_file, theme: THEME)
      puts
      # The query below is blank because I included the question itself in the previous markdown file. Doing it this way has the added bonus of effectively putsing another blank line I wanted.
      username = PROMPT.ask("")
      new_candidate = Candidate.new(username)

      loop do
        puts
        response = prompts(username)

        case response
        when :userinfo
          # If they choose option 1, call the `user` method to display all the pretty-formatted info for the user
          puts
          user(username)
        when :orgs
          # If they choose option 2, send them into the org line of questioning: how many, details y/n, etc.
          org_detail(new_candidate)
        when :newuser
          # If they choose option 3, get the name of a new candidate from the user and instantiate it
          username = PROMPT.ask("What's the Github username of this next candidate?")
          new_candidate = Candidate.new(username)
        when :help
          # If they choose option 4, call the built-in `help` method to display a list of everything they can do
          puts
          help
        when :exit
          # If they choose option 5, display a parting greeting and exit the program
          puts
          puts "#{PASTEL.magenta.bold('Goodbye then!')}"
          puts
          exit
        end
      end
    end
  end
end
