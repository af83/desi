require "desi/version"

module Desi
  autoload :Downloader,       'desi/downloader'
  autoload :HttpClient,       'desi/http_client'
  autoload :LocalInstall,     'desi/local_install'
  autoload :Registry,         'desi/registry'
  autoload :ReleaseInstaller, 'desi/release_installer'
  autoload :ProcessManager,   'desi/process_manager'
end

