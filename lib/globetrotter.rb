require_relative './globetrotter/version'
require_relative './globetrotter/nameserver'
require 'wrest'
require 'rubydns'
require 'time'
require 'date'
require 'set'
require 'ipaddr'

class Globetrotter
  def initialize(options)
    @ns_max_age_minutes = options.ns_max_age_minutes
    @ns_count_to_check = options.ns_count_to_check
    @timeout_seconds = options.timeout_seconds
    @query = options.domain
    @concurrency = options.ns_query_concurrency
    @ns_ips = fetch_ns_ips
  end

  def run
    ns_count = @ns_ips.count
    @ns_count_to_check = ns_count if @ns_count_to_check > ns_count
    @ns_ips = @ns_ips.sample(@ns_count_to_check)

    message = "Found #{ns_count} nameserver(s). "\
              "Querying #{@ns_count_to_check} of those "\
              "for #{query}, #{@concurrency} at a time, "\
              "with a timeout of #{@timeout_seconds} second(s)."
    $stderr.puts message

    EM.run do
      result_ips = Set.new
      ok = 0
      nok = 0
      EM::Iterator.new(@ns_ips, @concurrency).each(
        proc do |ns_ip, iter|
          resolver = RubyDNS::Resolver.new(
            [[:udp, ns_ip.to_s, 53]],
            timeout: @timeout_seconds
          )
          resolver.query(query) do |response|
            case response
            when RubyDNS::Message
              response.answer.each do |answer|
                address = answer[2].address.to_s
                result_ips.add(address)
              end
              ok += 1
              iter.next
            when RubyDNS::ResolutionFailure
              nok += 1
              iter.next
            end
          end
        end,
        proc do
          EM.stop
          result_ips.each { |ip| puts ip }
          $stderr.puts "#{ok} succeeded, #{nok} failed (#{ok + nok} total)"
        end
      )
    end
  end

  def self.run(options)
    new(options).run
  end

  private

  attr_reader :ns_max_age_minutes, :ns_count_to_check, :ns_ips, :query

  def fetch_ns_ips
    Wrest.logger = Logger.new(STDERR)
    uri = "http://public-dns.tk/nameservers.json".to_uri
    nameservers = uri.get.deserialise.map { |data| Nameserver.new(data) }
    nameservers.select do |ns|
      ns.valid? && ns.ipv4? && (ns.age_minutes <= @ns_max_age_minutes)
    end.map(&:ip)
  end

  def resolve_with_nameserver(query, nameserver)
    resolver = RubyDNS::Resolver.new([[:udp, nameserver, 53]])
    resolver.query(query)
  end
end
