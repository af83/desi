# Desi

Desi (Developper ElasticSearch Installer) is very simple tool to quickly set up
an [Elastic Search](http://www.elasticsearch.org/) local install for
development purposes. It will download and install ElasticSearch (the latest
version by default) and let you start/stop/restart it.

## Installation

Add this line to your application's Gemfile:

    gem 'desi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install desi

## Usage

    $ desi list                # List locally installed ElasticSearch versions
    $ desi releases            # List all available Elastic Search versions
    $ desi install [VERSION]   # Install a specific version (latest by default)
    $ desi start               # Start a local 1-node cluster (noop if active)
    $ desi restart             # (Re)start cluster (even if active)
    $ desi stop                # Stop cluster
    $ desi status              # Show running cluster info

## TODO

  * add tests, dammit!

  * `desi upgrade` (Upgrade to latest version and migrate data)
  * `desi switch VERSION` (Switch currently active ES version to VERSION)
  * index management (list, create, delete ES indices)
  * plugin management ? (list, install, remove ES plugins)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
