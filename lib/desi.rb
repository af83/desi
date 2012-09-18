require "desi/version"

module Desi
  autoload :Downloader,       'desi/downloader'
  autoload :HttpClient,       'desi/http_client'
  autoload :LocalInstall,     'desi/local_install'
  autoload :Upstream,         'desi/upstream'
  autoload :Installer,        'desi/installer'
  autoload :ProcessManager,   'desi/process_manager'
  autoload :IndexManager,     'desi/index_manager'
end

