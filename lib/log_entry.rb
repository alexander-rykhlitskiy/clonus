require 'time'

class LogEntry
  ATTRS_DELIMITER = 'attrs_delimiter'.freeze

  attr_reader :commit_hash, :author, :time, :msg, :tickets

  def initialize(log_row, tickets)
    @commit_hash, @author, @time, @msg = log_row.split(ATTRS_DELIMITER)
    @time = Time.parse(@time).utc
    @msg = @msg.split("\n").reject { |l| l.strip.empty? }.join("\n")
    @tickets = tickets
  end

  def human_attributes
    [commit_hash, author_name, time.strftime('%F %H:%M:%S'), msg]
  end

  def author_name
    first, last = author.split
    "#{first} #{last[0].upcase + '.' if last}"
  end
end
