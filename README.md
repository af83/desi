# Desi

Desi (Developper ElasticSearch Installer) is very simple tool to quickly set up
an [Elastic Search](http://www.elasticsearch.org/) local install for
development purposes. It will download and install ElasticSearch (the latest
version by default) and let you start/stop/restart it.

It's in very early stages and doesn't do much ATM.

## Installation

Add this line to your application's Gemfile:

    gem 'desi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install desi

## Usage

    $ desi list                      # List locally installed ElasticSearch versions
    $ desi list_all                  # List all available Elastic Search versions
    $ desi install                   # Install latest stable version


## TODO

    $ desi install-latest            # Install latest version
    $ desi install --version VERSION # Install a specific version
    $ desi upgrade                   # Upgrade to latest ElasticSearch version
    $ desi start                     # Start or restart Elastic Search
    $ desi stop                      # Stop Elastic Search
    $ desi switch VERSION            # Switch currently active ES version to VERSION

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
