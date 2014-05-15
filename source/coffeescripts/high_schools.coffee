$ ->
  new HighSchools
  
class HighSchools
  
  constructor: ->
    @data = window.high_school_data
    @data.sort (a,b) -> b['SAT Subject Scores (Averages) - Math']-a['SAT Subject Scores (Averages) - Math']
    
    @lng_extent = d3.extent @data.map((d) -> d.lng)
    @lat_extent = d3.extent @data.map((d) -> d.lat)
        
    @margin = {top: 20, right: 20, bottom: 20, left: 20}
    @width = 960 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom
    
    # projection roughly centered on PA
    projection = d3.geo.conicConformal()
      .rotate([77.7, 0])
      .center([0, 41])
      .parallels(@lat_extent)
      .scale(10000)
      .translate([@width/2, @height/2])
      .precision(.1);

   # create the view
    @view = d3.select('#graph_1').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")

    # add the circles
    @circles = @view
      .selectAll('circle')
      .data(@data)
      .enter()
      .append('circle')
      .attr('class', 'circle')
    
    # estimate the 12th grade class enrollment and scale it so it represents the radius of the circle
    enrollment_r = (d) ->
      ((d['School Enrollment']/(d['Grades Offered'].split(',').length))^(1/2))/Math.PI
    
    r_scale = d3.scale.linear()
      .domain(d3.extent(@data.map enrollment_r))
      .range([5,20])
      
    color_scale = d3.scale.quantize()
      .domain(d3.extent(@data.map (d) -> d['SAT Subject Scores (Averages) - Math']))
      .range(['rgb(215,48,39)','rgb(252,141,89)','rgb(254,224,139)','rgb(217,239,139)','rgb(145,207,96)','rgb(26,152,80)'])
    
    @circles
      .attr('cx', (d) => projection([d.lng,d.lat])[0])
      .attr('cy', (d) => projection([d.lng,d.lat])[1])
      .attr('r', (d) -> r_scale(enrollment_r(d)))
      .attr('stroke', (d) => color_scale(d['SAT Subject Scores (Averages) - Math']))
    
    # draw the US land boundaries, states, and counties
    # see: http://bl.ocks.org/mbostock/3734308
    path = d3.geo.path().projection(projection)
    d3.json 'vendor/us.json', (error, us) =>
      @view.append("path", ".boundary")
        .datum(topojson.feature(us, us.objects.land))
        .attr("class", "land")
        .attr("d", path)
      @view.append("path", ".boundary")
        .datum(topojson.mesh(us, us.objects.states, (a, b) -> a isnt b))
        .attr("class", "state-boundary")
        .attr("d", path)
      @view.insert("path", ".boundary")
        .datum(topojson.mesh(us, us.objects.counties, (a, b) -> 
          a isnt b and not (a.id / 1000 ^ b.id / 1000) ))
        .attr("class", "county-boundary")
        .attr("d", path)

  # # appends tooltips to the bars. Uses d3-tip.js
  # # see http://bl.ocks.org/Caged/6476579
  # add_tooltips: ->
  #   tip = d3.tip()
  #     .attr('class', 'd3-tip')
  #     .offset([-10, 0])
  #     .html((d) -> "<span>#{d.country_name}</span>")
  # 
  #   @view.call(tip)
  # 
  #   @circles
  #     .on('mouseover', tip.show)
  #     .on('mouseout', tip.hide)

