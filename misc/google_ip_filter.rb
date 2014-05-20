#!/usr/bin/env ruby
require 'ipaddr'
require 'resolv'
require 'set'

def get_google_ranges
  ipv4_cidr = Regexp.new('(\d{1,3}\.){3}\d{1,3}\/[0-9]{2}')
  google_ranges = Set.new
  Resolv::DNS.open(nameserver: ['8.8.8.8', '8.8.4.4']) do |dns|
    dns.each_resource('_netblocks.google.com', Resolv::DNS::Resource::IN::TXT) do |rr|
      rr.data.split(' ').each do |s|
        s.match(ipv4_cidr) do |m|
          begin
            google_ranges.add(IPAddr.new(m.to_s.chomp))
          rescue StandardError => e
            abort e.to_s
          end
        end
      end
    end
  end
  google_ranges
end

abort 'Reads newline-delimited IP addresses from STDIN and outputs only those '\
  'associated with Google.' if STDIN.tty?

google_ranges = get_google_ranges

ARGF.each_line do |line|
  begin
    ip = IPAddr.new(line.chomp)
  rescue StandardError => e
    abort e.to_s
  end
  google_ranges.each do |r|
    if r.include?(ip)
      puts ip
      break
    end
  end
end
