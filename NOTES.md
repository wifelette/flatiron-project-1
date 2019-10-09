## Thor

http://whatisthor.com/

Normally, if your project needed a Gem, you would simply include it in your gemfile, and require it in your application. But in this case we're writing a _gem_, not an application, so instead we need to add the dependency to our gemspec:

`spec.add_runtime_dependency "thor", "~> 0.20.3"`

Thor is a useful base class for our CLI, so we'll start by subclassing from it in our `Cli` class (inside the Candidates Module).

The next step to make Thor work, is that we need to tell our executable file (inside the `exe` directory) to start it:

`Candidates::Cli.start`

Once we've done that, we're able to run `bundle exec candidates` in our terminal while building the gem.

Thor helps create CLI tools. It creates effectively a Table of Contents of all available CLI functionality.

This is a demo of some of what Thor can do:

```ruby
class Cli < Thor
    desc "hello NAME", "prints hello world"
    option :loud, type: :boolean
    def hello(name)
      message = "hello #{name}"

      if options[:loud]
        puts message.upcase
      else
        puts message
      end
    end
  end
```

## HTTParty

https://github.com/jnunemaker/httparty

HTTParty is a gem that will pull in the data from HTTP APIs. You can use it similar to how you'd use Nokogiri for scraping. It just makes the HTTP request for you.

Here's an example of a use:

`HTTParty.get("https://api.github.com/users/wifelette").parsed_response`

If you called it without the `.parsed_response` it would give you a gem-specific version of the content called `HTTParty::Resonse`. That has a bunch of metadata in it as well, versus if you do `.parsed_response` you're just getting the actual primary data in a hash. So there are different use cases for each.

Don't forget to once again add it to your gemspec:

`spec.add_runtime_dependency "httparty", "~> 0.17.1"`

...and to `require` it in your `CLI.rb`.

## Pretty Print

While testing, I added the Pretty Print requirement to my files to help me parse the data visually in temporary testing. After digging around a bit I chose to instead use `Awesome Print` which does the same thing but is more feature rich—specifically, colos!

`require "awesome_print"`

It also needs to go into the Gemspec:

`spec.add_runtime_dependency "awesome_print", "~> 1.8"`

## Pastel

I just added this for fun color in my CLI messages :p It's gratuitous.

`spec.add_runtime_dependency "pastel", "~> 0.7.3"`
`require "pastel"`

To look up the available options: https://github.com/piotrmurach/pastel

## Webmock

Webmock is a gem I'm using to allow me to use stub data in my tests, instead of continuing to hammer the actual API every time. I added this after chatting with a classmate who was getting rate limited by her project website :p

## TTYPrompt

https://rubygems.org/gems/tty-prompt
https://github.com/piotrmurach/tty-prompt

