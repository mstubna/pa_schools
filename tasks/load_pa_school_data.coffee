https = require 'https'
querystring = require 'querystring'
async = require 'async'

module.exports = (@grunt) ->

  # Loads the PA Fast Fact raw data file, appends geocode lat-lng data, and outputs a .json file
  @grunt.registerTask 'load_pa_ff_school_data', ->
    done = this.async()
    api_key = get_api_key()    
    console.log api_key
    ff_data = load_ff_data_from_file()
    
    async.eachSeries ff_data
    , (data, cb) ->
      
      if data['School Address (Street)']?
        address = "#{data['School Address (Street)']}, #{data['School Address (City)']}, #{data['School Address (State)']}"
      else if data['District Address (Street)']?
        address = "#{data['District Address (Street)']}, #{data['District Address (City)']}, #{data['District Address (State)']}"
      else
        console.log "No address info found for school #{data['name']}"
        return cb()
      
      get_lat_long_for_address address, api_key, (err, lat_lng) ->
        cb(err) if err?

        if lat_lng?
          console.log "Successfully found geo info for #{data['name']}: #{JSON.stringify(lat_lng)}"
          data.lat = lat_lng[0]
          data.lng = lat_lng[1]
        else
          console.log "Unable to find geo info for #{data['name']}"

        cb()
    , (err) ->
      done(false) if err?
      save_ff_data_json ff_data
      done()
  
  # filters the set of schools to only the high schools
  @grunt.registerTask 'filter_pa_ff_high_school_data', =>
    is_high_school = (school) ->
      school.hasOwnProperty('Grades Offered') and /12/.test(school['Grades Offered']) and
        school.hasOwnProperty('SAT Subject Scores (Averages) - Math') and
        school['SAT Subject Scores (Averages) - Math'] isnt 'Not Applicable' and
        school['SAT Subject Scores (Averages) - Math'] isnt 'Not Available' and
        school['SAT Subject Scores (Averages) - Math'] isnt 'Insufficient Sample' and
        school.lat? and school.lng?
    
    schools = @grunt.file.readJSON('source/data/ff_data.json')
    filt_schools = (s for s in schools when is_high_school(s))    
    @grunt.file.write 'source/data/high_school_ff_data.json', "high_school_data = " + JSON.stringify(filt_schools)
    
  get_api_key = =>
    @grunt.file.readYAML('secrets/geocoding_keys.yaml').bing_key
  
  # Uses the Bing Locations API to geocode the address
  # see: http://msdn.microsoft.com/en-us/library/ff701711.aspx
  get_lat_long_for_address = (address, api_key, callback) =>
    query = 
      query: address
      key: api_key
    
    options = 
      host: 'dev.virtualearth.net'
      port: 443
      path: "/REST/v1/Locations?#{querystring.stringify(query)}"
      method: 'GET'    

    req = https.request options, (res) ->
      result = ''
      res.on 'data', (chunk) =>
        result += chunk
      res.on 'end', =>
        result = JSON.parse result
        callback null, result.resourceSets[0]?.resources[0]?.point?.coordinates
    
    req.end()        
    req.on 'error', (err) -> 
      callback err
  
  load_ff_data_from_file = =>
    ff_file = @grunt.file.read('data/SPP/SPP.FF.2012.2013.txt').split("\r\n")
    ff_data = []
    for ff,i in ff_file when i > 0
      ff_fields = ff.split('|')
      school_name = ff_fields[1]
      if current_school?.name isnt school_name
        ff_data.push(current_school) if current_school?
        current_school = { name: school_name }
      current_school[ff_fields[4]] = ff_fields[5]
    ff_data.push current_school
    ff_data
  
  save_ff_data_json = (ff_data) =>
    @grunt.file.write 'source/data/ff_data.json', JSON.stringify(ff_data)
