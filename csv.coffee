json2csv = require 'json2csv'
# Assuming there is a file called `aggregate.json` that houses all records
aggregate = require './aggregate'

json2csv
  data: aggregate
  fields: 'username email'.split ' '
, (err, csv) ->
  if err?
    console.error err
    return

  console.log csv
