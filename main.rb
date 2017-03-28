cashman_directory = ARGV[0]
hov_remote = ARGV[1]
curl_request = ARGV[2..-1]

require_relative 'lib/tickets_loader'
require_relative 'lib/log_entries_fetcher'
require_relative 'lib/color'

tickets = TicketsLoader.new(curl_request).run
log_entries = LogEntriesFetcher.new(cashman_directory, hov_remote, tickets).run

found_tickets = []
log_entries.sort_by(&:time).chunk(&:ticket).each do |ticket, entries_group|
  found_tickets << ticket
  printf("#{Color.green(ticket)}\n")
  entries_group.each do |log_entry|
    updated_gems = nil
    Dir.chdir(cashman_directory) do
      updated_gems = `git show #{log_entry.commit_hash} | grep gem`.split("\n").select { |l| l.start_with?('+') }
    end
    printf("#{Color.red('%10s')} %-12s #{Color.pink('%s')} %s\n %s \n", *log_entry.human_attributes, updated_gems)
  end
end

found_tickets.uniq!
puts "#{found_tickets.length} tickets were found."
not_found_tickets = tickets - found_tickets
puts "#{not_found_tickets.length} tickets were not found: #{not_found_tickets.join(', ')}."
