require_relative './globetrotter/version'
require_relative './globetrotter/nameserver'
require 'dnsruby'
require 'wrest'
require 'time'
require 'date'
require 'set'
require 'ipaddr'
require 'pp'

include Dnsruby

class Globetrotter
  def initialize(options)
    @ns_max_age_minutes = options.ns_max_age_minutes
    @ns_count_to_check = options.ns_count_to_check
    @query = options.domain
    @ns_ips = fetch_ns_ips
    @timeout_seconds = options.timeout_seconds
  end

  def run
    ns_count = @ns_ips.count
    @ns_count_to_check = ns_count if @ns_count_to_check > ns_count
    @ns_ips = @ns_ips.sample(@ns_count_to_check)

    message = "Found #{ns_count} nameserver(s). "\
              "Querying #{@ns_count_to_check} of those for '#{query}' "\
              "with a timeout of #{@timeout_seconds} second(s)."
    $stderr.puts message

    query_queue = Queue.new
    result_ips = Set.new
    ok = 0
    nok = 0
    request = Message.new(@query)
    request.header.rd = false
    request.do_caching = false
    request.do_validation = false

    @ns_ips.each_with_index do |ns_ip, index|
      resolver = Dnsruby::Resolver.new(
        nameserver: ns_ip.to_s,
        do_validation: false,
        ignore_truncation: true,
        query_timeout: @timeout_seconds,
        recurse: false,
        retry_times: 1
      )
      resolver.send_async(request, query_queue, index)
    end

    consumer = Thread.new do
      sleep @timeout_seconds
      @ns_ips.size.times do
        response_id, response, exception = query_queue.pop(non_block: true) rescue nil
        if exception.nil?
          response.each_resource do |rr|
            result_ips.add(rr.address) if rr.instance_of?(Dnsruby::RR::IN::A)
          end
          ok +=1
        else
          nok += 1
          next
        end unless response_id.nil?
      end
    end

    consumer.join

    result_ips.each { |ip| puts ip }
    $stderr.puts "#{ok} succeeded, #{nok} failed (#{ok + nok} total)"
    $stderr.puts "#{result_ips.size} unique result(s) found for '#{query}'"
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

end
