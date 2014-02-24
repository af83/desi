# encoding: utf-8

desc "Open a Pry console"
task :console do
  require "desi"
  require "pry"
  Pry.start
end
