require 'scraperwiki'
require 'httparty'
# require 'mechanize'

url = 'http://billit.ciudadanointeligente.org/bills/search.json?page=1&source=Moci%C3%B3n'
page = HTTParty.get(url, :content_type => :json)

page = JSON.parse(page.body)
page = page['bills']

page.each do |proyecto|
  puts proyecto['uid']
end


page.search('.scrollable-table tbody tr').each do |tr|
  next if tr.search('td')[0].text == 'App No.'

  tds = tr.search('td')
  info_url = tds[1].search('a').first['href']

  begin
    info_page = agent.get(info_url)
  rescue Mechanize::ResponseCodeError => e
    puts "Skipping due to error getting info page: #{e}"
    next
  end

  record = {
    'uid'             => record['uid'],
    'creation_date'   => record['creation_date'],
    'authors'         => JSON.dump(record['authors']),
    # 'date_scraped'    => Date.today.to_s
  }

  if (ScraperWiki.select("* from data where `uid`='#{record['uid']}'").empty? rescue true)
    ScraperWiki.save_sqlite(['uid'], record)
  else
     puts "Skipping already saved record " + record['uid']
  end
end