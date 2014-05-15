$ ->
  new HighSchools
  
class HighSchools
  
  constructor: ->
    @data = window.high_school_data
    @data.sort (a,b) -> b['SAT Subject Scores (Averages) - Math']-a['SAT Subject Scores (Averages) - Math']
    
    @lng_extent = d3.extent @data.map((d) -> d.lng)
    @lat_extent = d3.extent @data.map((d) -> d.lat)
        
    @margin = {top: 20, right: 80, bottom: 20, left: 20}
    @width = 960 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom

   # create the view
    @view = d3.select('#graph_1').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")
    
    # estimate the 12th grade class enrollment and scale it so it represents the radius of the circle
    enrollment_r = (d) ->
      (d['School Enrollment']/(d['Grades Offered'].split(',').length*Math.PI))^(1/2)
    
    r_scale = d3.scale.linear()
      .domain(d3.extent(@data.map enrollment_r))
      .range([5,20])
      
    color_scale = d3.scale.quantize()
      .domain(d3.extent(@data.map (d) -> d['SAT Subject Scores (Averages) - Math']))
      .range(['rgb(215,48,39)','rgb(252,141,89)','rgb(254,224,139)','rgb(217,239,139)','rgb(145,207,96)','rgb(26,152,80)'])
    
    # projection roughly centered on PA
    projection = d3.geo.conicConformal()
      .rotate([77.7, 0])
      .center([0, 41])
      .parallels(@lat_extent)
      .scale(10000)
      .translate([@width/2, @height/2])
      .precision(.1);
    
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

    # add the circles
    @circles = @view
      .selectAll('circle')
      .data(@data)
      .enter()
      .append('circle')
      .attr('class', 'circle')

    @circles
      .attr('cx', (d) => projection([d.lng,d.lat])[0])
      .attr('cy', (d) => projection([d.lng,d.lat])[1])
      .attr('r', (d) -> r_scale(enrollment_r(d)))
      .attr('stroke', (d) => color_scale(d['SAT Subject Scores (Averages) - Math']))
    
    # add the color legend
    colors = color_scale.range()
    legend_data = colors.map (c) -> { color: c, scores: color_scale.invertExtent(c) }
    legend_view = d3.select('#graph_1_legend_1').append('svg')
      .attr('width', 200)
      .attr('height', 250)
      .append('g')
      .attr('transform', "translate(50,20)")
    legend_view.append('text')
      .text('Math SAT')
      .attr('class', 'legend_header')    
    legend = legend_view.selectAll('.legend')
      .data(legend_data.reverse())
      .enter().append('g')
      .attr('transform', (d,i) -> "translate(0,#{i*20+10})")
    legend.append('rect')
      .attr('width', 18)
      .attr('height', 18)
      .style('fill', (d) -> d.color);
    legend.append('text')
      .attr('x', 24)
      .attr('y', 9)
      .attr('dy', '.35em')
      .text((d) -> "#{Math.round(d.scores[0])}-#{Math.round(d.scores[1])}")
    
    # add the size legend
    r_values = [5, 8.75, 12.5, 16.25, 20]
    legend_data = r_values.map (r) -> { r: r, size: Math.PI*(r_scale.invert(r))^2 }
    legend_view_2 = d3.select('#graph_1_legend_2').append('svg')
      .attr('width', 200)
      .attr('height', 250)
      .append('g')
      .attr('transform', "translate(75,20)")
    legend_view_2.append('text')
      .text('Size')
      .attr('class', 'legend_header')    
    legend = legend_view_2.selectAll('.legend')
      .data(legend_data.reverse())
      .enter().append('g')
      .attr('transform', (d,i) -> "translate(0,#{i*20+10})")
    legend.append('circle')
      .attr('class', 'legend-circle')
      .attr('cy', (d,i) -> 20*i+20 )
      .attr('r', (d) -> d.r)
    legend.append('text')
      .attr('x', 24)
      .attr('y', (d,i) -> 20*i+20)
      .attr('dy', '.35em')
      .text((d) -> "#{Math.round(d.size)}")

    # append tooltips to the elements
    # see: http://bl.ocks.org/Caged/6476579
    tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset([-10, 0])
      .html (d) -> 
        "<p>#{d.name}</p>" +
        "<p>Math SAT: #{Math.round(d['SAT Subject Scores (Averages) - Math'])}</p>" +
        "<p>Class size: #{Math.round(d['School Enrollment']/(d['Grades Offered'].split(',').length))}</p>"

    @view.call(tip)

    @circles
      .on('mouseover', tip.show)
      .on('mouseout', tip.hide)

