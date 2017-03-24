require_relative 'log_entry'

class LogEntriesFetcher
  LOG_LINES_NUMBER = 3000

  def initialize(cashman_directory, hov_remote, tickets)
    @cashman_directory, @hov_remote, @tickets = cashman_directory, hov_remote, tickets
  end

  def run
    tickets_regexp = Regexp.new(@tickets.map(&:hvs).join('|'), 'i')
    tickets_log_lines = fetch_log.split("\n").grep(tickets_regexp)
    tickets_log_lines.map do |line|
      ticket = @tickets.find { |t| line.match(Regexp.new(t.hvs, 'i')) }
      LogEntry.new(line, ticket)
    end
  end

  private

  def fetch_log
    Dir.chdir(@cashman_directory) do
      `git fetch #{@hov_remote}`
      `git checkout #{@hov_remote}/master`
      d = LogEntry::DELIMITER
      `git log --pretty=format:"%h#{d}%an#{d}%ci#{d}%s" -#{LOG_LINES_NUMBER}`
    end
  end
end
