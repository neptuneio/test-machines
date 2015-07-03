#!/usr/bin/env ruby

# get the current list of processes
processes = `ps aux`

# determine if the nagent process is running
running = processes.lines.detect do |process|
  process.include?('nagent.py')
end

# return appropriate check output and exit status code
if running
  puts 'OK - nagent process is running'
  exit 0
else
  puts 'WARNING - nagent process is NOT running'
  exit 1
end
