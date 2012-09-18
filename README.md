# Desi

Desi (Developper ElasticSearch Installer) is very simple tool to quickly set up
an [Elastic Search](http://www.elasticsearch.org/) local install for
development purposes.

It can:
  * download and install ElasticSearch (the latest release by default)
  * start/stop/restart it.
  * do basic indices management (list, delete, empty a given set of indices)


## Installation

Add this line to your application's Gemfile:

    gem 'desi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install desi

## Usage

    $ desi list                  # List locally installed ElasticSearch versions
    $ desi releases              # List all upstream Elastic Search releases (latest 5 by default)
    $ desi install [VERSION]     # Install a specific version (latest by default)
    $ desi start                 # Start a local 1-node cluster (noop if active)
    $ desi restart               # (Re)start cluster (even if active)
    $ desi stop                  # Stop cluster
    $ desi status [--host HOST]  # Show running cluster info

    $ desi indices "^foo"          # List all indices whose name match /^foo/
    $ desi indices "^foo" --delete # Delete all matching indices
    $ desi indices "bar$" --empty  # Remove all records from the matching
                                   #  indices

## TODO

  * add tests, dammit!

  * `desi upgrade` (Upgrade to latest version and migrate data)
  * `desi switch VERSION` (Switch currently active ES version to VERSION)
  * plugin management ? (list, install, remove ES plugins)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
