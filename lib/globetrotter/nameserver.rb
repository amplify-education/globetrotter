require 'wrest'

# Defines a DNS name server returned by http://public-dns.tk/
class Nameserver
  include Wrest::Components::Container

  always_has :id
  typecast ip:               ->(ip)   { IPAddr.new(ip) },
           created_at:       ->(date) { DateTime.iso8601(date) },
           checked_at:       ->(date) { DateTime.iso8601(date) },
           updated_at:       ->(date) { DateTime.iso8601(date) },
           state_changed_at: ->(date) { DateTime.iso8601(date) }

  def ipv4?
    ip.ipv4?
  end

  def ipv6?
    ip.ipv6?
  end

  def valid?
    state == 'valid'
  end

  def invalid?
    state == 'invalid'
  end

  def age_minutes
    t1 = Time.now.to_i
    t2 = checked_at.to_i
    seconds_since_check = t1 - t2
    minutes_since_check = seconds_since_check / 60
    minutes_since_check
  end
end
