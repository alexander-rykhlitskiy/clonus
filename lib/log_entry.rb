require 'time'

class LogEntry
  DELIMITER = '|||'.freeze

  attr_reader :commit_hash, :author, :time, :msg, :ticket

  def initialize(log_row, ticket)
    @commit_hash, @author, @time, @msg = log_row.split(DELIMITER)
    @time = Time.parse(@time).utc
    @ticket = ticket
  end

  def human_attributes
    [commit_hash, author_name, time.strftime('%F %H:%M:%S'), msg]
  end

  def author_name
    first, last = author.split
    "#{first} #{last[0].upcase + '.' if last}"
  end
end
