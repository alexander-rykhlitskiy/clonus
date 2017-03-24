class Ticket
  attr_reader :csm, :hvs

  def initialize(csm, hvs)
    @csm, @hvs = csm.downcase, hvs.downcase
  end

  def to_s
    "#{csm.upcase} - #{hvs.upcase}"
  end
end
