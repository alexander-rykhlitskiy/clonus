require 'open-uri'
require 'json'
require 'nokogiri'
require_relative 'ticket'

class TicketsLoader
  def initialize(release_curl_args)
    @release_url = release_curl_args[1]
    uri = URI(@release_url)
    @jira_base_url = "#{uri.scheme}://#{uri.host}"
    @headers = release_curl_args[2..-1].slice_before(/-H/).each_with_object({}) do |(_h, header), headers|
      name, value = header.split(': ')
      headers[name] = value
    end
  end

  def run
    csm_clones_anchors.map do |anchor|
      csm = anchor.content
      csm_url = URI.join(@jira_base_url, anchor.attribute('href').value).to_s
      hvs = hvs_name(csm_url)
      Ticket.new(csm, hvs)
    end
  end

  private

  def hvs_name(csm_url)
    ticket_html = Nokogiri::HTML(get(csm_url))
    hvs_anchor = ticket_html.css('dl [title="clones"] ~ dd a.issue-link').first
    hvs_anchor.content
  end

  def csm_clones_anchors
    release_html = Nokogiri::HTML(JSON.parse(get(@release_url))['tabContent'])
    ticket_rows = release_html.css('tbody.release-report-issues tr')
    clone_rows = ticket_rows.select { |row| row.css('.summary:contains("CLONE")').any? }
    clone_rows.map { |row| row.css('td.key a').first }
  end

  def get(url)
    puts "Sending get request to #{url}"
    result = open(url, @headers)
    result.respond_to?(:read) ? result.read : result
  end
end
