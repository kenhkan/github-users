Browser = require 'zombie'

# Parameters:
#   * language
#   * location
#   * start page index
#   * end page index
[node, path, language, location, start, end, order] = process.argv
order ?= 'asc'

# Weakness of weak typing!
start = parseInt start
end = parseInt end

output = []
pages = [start..end]
pageCount = 0
totalCount = pages.length
url = "https://github.com/search?o=#{order}&q=language%3A#{language}+location%3A#{location}&ref=searchresults&s=joined&type=Users"

# Given a page index, fetch all usernames and email addresses
do fetch = ->
  # We're done once we're at the end
  if pages.length is 0
    console.log JSON.stringify output
    return

  # Pick a random page to avoid detection
  index = Math.round Math.random() * (pages.length - 1)
  # Remove the chosen one from array as an integer
  page = pages.splice(index, 1)[0]
  # Keep a tab of how many pages we've fetched
  pageCount++

  # Print to error to avoid logging to file
  console.error "Processing page #{page} of #{totalCount}. We have processed #{pageCount} pages."

  # Construct URL
  _url = "#{url}&p=#{page}"

  browser = new Browser
  browser.visit(_url)
    .then ->
      document = browser.document
      users = document.querySelectorAll '.user-list-info'

      for user in users
        output.push
          username: user.querySelector('a')?.innerHTML
          email: user.querySelector('.email')?.innerHTML

      # Clean up after yourself!
      browser.close()

      # Do it at some random interval in the future to avoid being detected. At
      # least 1 sec and no more than 4.
      delay = 1000 + parseInt(Math.random() * 2000)
      # Every 20 fetches, wait longer to avoid being shut down
      delay += 15000 if pageCount % 20 is 0
      setTimeout fetch, delay

    .fail (error) ->
      console.error 'error', error
