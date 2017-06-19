require_relative 'log_entry'

class LogEntriesFetcher
  LOG_LINES_NUMBER = 3000
  ENTRIES_DELIMITER = 'entries_delimiter'.freeze

  def initialize(cashman_directory, hov_remote, tickets)
    @cashman_directory, @hov_remote, @tickets = cashman_directory, hov_remote, tickets
  end

  def run
    tickets_regexp = Regexp.new(@tickets.map(&:hvs).join('|'), 'i')
    tickets_log_lines = fetch_log.split("#{ENTRIES_DELIMITER}\n").grep(tickets_regexp)
    tickets_log_lines.map do |line|
      tickets = @tickets.select { |t| line.match(Regexp.new(t.hvs, 'i')) }
      LogEntry.new(line, tickets)
    end
  end

  private

  def fetch_log
    Dir.chdir(@cashman_directory) do
      `git fetch #{@hov_remote}`
      `git checkout #{@hov_remote}/production`
      d = LogEntry::ATTRS_DELIMITER
      # https://git-scm.com/docs/pretty-formats
      `git log --pretty=format:"%h#{d}%an#{d}%ci#{d}%s \n %b %N #{ENTRIES_DELIMITER}" -#{LOG_LINES_NUMBER}`
    end
  end
end
