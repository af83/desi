Desi
====
[![Build Status](https://secure.travis-ci.org/AF83/desi.png)](http://travis-ci.org/AF83/desi)
[![Gem Version](https://badge.fury.io/rb/desi.png)](http://badge.fury.io/rb/desi)

Desi (Developper Elasticsearch Installer) is very simple tool to quickly set up
an [Elastic Search](http://www.elasticsearch.org/) local install for
development purposes.

It can:

  * download and install Elasticsearch (the latest release by default)
  * start/stop/restart it.
  * do basic indices management (list, delete, empty a given set of indices)

It can be used both as a command-line tool and as a library.


## Usage (command-line)

    $ desi list                  # List locally installed Elasticsearch releases
    $ desi releases              # List all upstream Elastic Search releases (latest 5 by default)
    $ desi install [VERSION]     # Install a specific version (latest by default)
    $ desi start                 # Start a local 1-node cluster (noop if active)
    $ desi restart               # (Re)start cluster (even if active)
    $ desi stop                  # Stop cluster
    $ desi status [--host HOST]  # Show running cluster info
    $ desi tail                  # Show tail output from Elastic Search's log file

    $ desi indices "^foo"          # List all indices whose name match /^foo/
    $ desi indices "^foo" --delete # Delete all matching indices
    $ desi indices "bar$" --empty  # Remove all records from the matching indices

## Examples (command-line and Ruby)

### Installing Elastic Search

 ```bash
 $ # The latest version will be installed by default
 $ desi install
 * No release specified, will fetch latest.
 * fetching release elasticsearch-1.0.1.tar.gz
 […]

 $ # You can also give a specific release name
 $ desi install 0.90.12 # ("v0.90.12" or "elasticsearch-0.90.12" would also work)
 * fetching release elasticsearch-0.90.12.tar.gz
 […]
 ```

### Get the list of locally installed releases

The current version is the one symlinked to `$HOME/elasticsearch/current`, that
will be spun up by (`desi start`)

  * command-line

  ```shell
  $ desi list
  Local ES installs in /home/me/elasticsearch (current one is tagged with '*'):
    * elasticsearch-1.0.1 (/home/me/elasticsearch/elasticsearch-1.0.1)
    - elasticsearch-1.0.0 (/home/me/elasticsearch/elasticsearch-1.0.0)
  ```


  * library

  ```ruby
  Desi::LocalInstall.new.releases.map(&:name) #=> ["elasticsearch-1.0.0", "elasticsearch-1.0.1"]
  Desi::LocalInstall.new.releases.detect(&:current?).version #=> "1.0.1"
  ```

### Start a node instance and get the cluster's status

  * command-line

  ```shell
  $ desi start
   * Elastic Search 1.0.1 started
  $ desi status
  OK. Elastic Search cluster 'elasticsearch' (v1.0.1) is running on 1 node(s) with status yellow

  # Start Elastic Search in the foreground
  $ desi start -f # or --foreground
  ES will be launched in the foreground
  ^C # Manual stop with Control-C
  Elastic Search interrupted!
  ```

  * library

  ```ruby
  Desi::ProcessManager.new.start.status #=> "OK. Elastic Search cluster 'elasticsearch' (v1.0.1) is running on 1 node(s) with status green"
  ```


### List and delete some indices

  * command-line

  ```shell
  $ # List all local indices
  $ desi indices
    Indices from host http://127.0.0.1:9200 matching the pattern /.*/

    foo
    bar
    baz

  $ # List all indices with "foo" in their name on remote cluster 129.168.1.42, port 9800
  $ desi indices --host 129.168.1.42:9800 foo
    Indices from host http://192.168.1.42:9800 matching the pattern /foo/

    remotefoo1
    remotefoo2

  $ # Remove all indices whose name starts with "ba"
  $ desi indices --delete "^ba"
  The following indices from host http://127.0.0.1:9200 are now deleted
   * bar
   * baz
  ```


  * library

  ```ruby
  # All local indices
  Desi::IndexManager.new.list #=> ["foo", "bar", "baz"]

  # All local indices whose name starts with "b"
  Desi::IndexManager.new.list("^b") #=> ["bar", "baz"]

  # All indices from distant cluster
  Desi::IndexManager.new(host: "192.168.1.42:9800").list #=> ["remotefoo1", "remotefoo2"]

  # Delete all local indices whose name starts with "ba"
  Desi::IndexManager.new.delete!("^ba") #=> nil

  # The indices actually disappeared! \o/
  Desi::IndexManager.new.list #=> ["foo"]
  ```


## Change setting(s)

There are two settings at the moment: location of the installation directory
(`directory`, default: `~/elasticsearch`) and ES host address (`server`,
default: `localhost:9200`).

There are two places Desi will be looking for configuration files:

  * a system-wide file: `/etc/desi.yml`
  * a user-specific file, which can be either `$XDG\_HOME\_DIR/desi/config.yml`,
    if [freedesktop](http://www.freedesktop.org/wiki/) environment variable
    [`$XDG\_HOME\_DIR`](http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html)
    is defined, or `~/.desi.yml` (default)

The options found in the former will be overriden by the ones found in the
latter.


  * command-line

    `echo -e "---\n  directory: ~/foobar" > ~/.desi.yml` for instance

  * library

  ```ruby
  Desi.configure do |c|
    c.directory = "~/local/foo"
    c.server = "192.168.1.42:9200"
  end
  ```



## Installation

Add this line to your application's Gemfile:

    gem 'desi'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install desi

## TODO

  * add more tests

  * `desi upgrade` (Upgrade to latest version and migrate data)
  * `desi switch VERSION` (Switch currently active ES version to VERSION)
  * plugin management ? (list, install, remove ES plugins)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
