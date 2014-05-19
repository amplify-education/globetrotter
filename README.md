# globetrotter

globetrotter retrieves a list of DNS servers around the world from the [Public DNS Server List](http://public-dns.tk/) and runs your query against them. This is particularly handy for compiling list of SaaS endpoint IPs in cases where the provider doesn't specify them.

## Installation

    $ gem install globetrotter

## Usage
Query 100 DNS servers for googleapis.com, making 10 requests in parallel at a time (defaults):

    $ globetrotter -q googleapis.com -n 100 -p 10

See `globetrotter -h` for all parameters

## TODO
* Improve command line argument parsing
* Handle non-A records

## Contributing

1. [Fork it](https://github.com/amplify-education/globetrotter/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
