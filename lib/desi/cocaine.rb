# encoding: utf-8

require "cocaine"

# Use Basic BackticksRunner for Cocaine as the PosixRunner triggers
# surprising bugs
# see https://github.com/AF83/desi/issues/5
Cocaine::CommandLine.runner = Cocaine::CommandLine::BackticksRunner.new
