#!/usr/bin/env ruby

cashman_directory = ARGV[0]
curl_request = ARGV[1..-1]

require_relative 'lib/tickets_loader'
require_relative 'lib/log_entries_fetcher'
require_relative 'lib/color'

release_tickets = TicketsLoader.new(curl_request).run
log_entries = LogEntriesFetcher.new(cashman_directory, release_tickets).run

found_tickets = []
log_entries.sort_by(&:time).chunk(&:tickets).each do |tickets, entries_group|
  found_tickets.concat(tickets)
  printf("#{Color.green(tickets.join(', '))}\n")
  entries_group.each do |log_entry|
    printf("#{Color.red('%10s')} %-12s #{Color.pink('%s')} %s\n", *log_entry.human_attributes)
  end
end

found_tickets.uniq!
puts "#{found_tickets.length} tickets were found."
not_found_tickets = release_tickets - found_tickets
puts "#{not_found_tickets.length} tickets were not found: #{not_found_tickets.join(', ')}"
