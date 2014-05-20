#!/usr/bin/env ruby
require 'ipaddr'
require 'set'

class GlobetrotterFile
  def initialize(file)
    @set = Set.new
    @file = open(file)
    parse
  end

  attr_accessor :set

  def open(file)
    begin
      file = File.open(file, File::RDONLY|File::CREAT)
    rescue StandardError => e
      abort e.to_s
    end
    file
  end # open

  def parse
    self.open if @file.nil?
    line_number = 0
    # parse line for IP
    @file.each_line do |line|
      line_number += 1
      begin
        ip = IPAddr.new(line.chomp)
        @set.add(ip)
      rescue StandardError => e
        abort "#{e} on line #{line_number}: '#{line}'"
      end
    end
    @file.close unless @file.nil?
    self
  end # parse

  def write
    begin
      File.open(@file, 'w') do |f|
        f.puts(@set.to_a.sort.join("\n"))
      end
    rescue StandardError => e
      abort e.to_s
    end
  end # write

  def to_s
    @file.path
  end

end
