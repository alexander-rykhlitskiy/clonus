cashman_directory = ARGV[0]
hov_remote = ARGV[1]
curl_request = ARGV[2..-1]

require_relative 'lib/tickets_loader'
require_relative 'lib/log_entries_fetcher'
require_relative 'lib/color'

tickets = TicketsLoader.new(curl_request).run
log_entries = LogEntriesFetcher.new(cashman_directory, hov_remote, tickets).run

log_entries.sort_by(&:time).chunk(&:ticket).each do |ticket, entries_group|
  printf("#{Color.green(ticket)}\n")
  entries_group.each do |log_entry|
    printf("#{Color.red('%10s')} %-12s #{Color.pink('%s')} %s\n", *log_entry.human_attributes)
  end
end