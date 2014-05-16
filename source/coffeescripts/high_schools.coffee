$ ->
  new HighSchools
  
class HighSchools
  
  constructor: ->
    @data = window.high_school_data
    @data.sort (a,b) -> b['SAT Subject Scores (Averages) - Math']-a['SAT Subject Scores (Averages) - Math']
    @sat_scores = @data.map (d) -> d['SAT Subject Scores (Averages) - Math']
    @sat_extent = d3.extent @sat_scores
                    
    @color_scale = d3.scale.quantile()
      .domain(@sat_scores)
      .range(['rgb(215,48,39)','rgb(252,141,89)','rgb(254,224,139)','rgb(255,255,191)','rgb(217,239,139)','rgb(145,207,96)','rgb(26,152,80)'])

    @create_distribution_graph()
    @append_color_scale_legend 'distribution_graph_legend_1'
        
    @create_ranking_graph()
    @append_color_scale_legend 'ranking_graph_legend_1'

    @create_regional_graph()
    @append_color_scale_legend 'regional_graph_legend_1'

  create_ranking_graph: ->
    margin = {top: 20, right: 0, bottom: 50, left: 80}
    width = 940 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom
    
    view = d3.select('#ranking_graph').append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
      .append('g')
      .attr('transform', "translate(#{margin.left},#{margin.top})")
    
    view.append('text')
      .text('School')
      .attr('x', width/2)
      .attr('y', height+margin.bottom/2)
      
    view.append('text')
      .text('SAT score')
      .attr('y', -45)
      .attr('x', -height/1.5)
      .attr('transform', 'rotate(270)')
      
    x_axis_view = view.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{height})")
    
    y_axis_view = view.append('g')
      .attr('class', 'y axis')
    
    x_scale = d3.scale.linear().domain([0, @data.length]).range([0, width])

    y_scale = d3.scale.linear().domain(@sat_extent).range([height, 0])
    y_axis = d3.svg.axis().scale(y_scale).orient('left').tickFormat(d3.format('.0f'))
    
    bars = view.selectAll(".bar").data(@data.slice().reverse())

    bars.enter().append('rect')
      .attr('class', 'bar')
      .attr('width', 2)
      .attr('fill', (d) => @color_scale(d['SAT Subject Scores (Averages) - Math']))
      .attr('x', (d,i) -> x_scale(i))
      .attr('height', (d) => height - y_scale(d['SAT Subject Scores (Averages) - Math']))
      .attr('y', (d) -> y_scale(d['SAT Subject Scores (Averages) - Math']))

    y_axis_view.call(y_axis)
    
    # tooltips
    tip = @get_tooltip()
    view.call(tip)
    bars
      .on('mouseover', tip.show)
      .on('mouseout', tip.hide)
  
  create_distribution_graph: ->
    margin = {top: 20, right: 0, bottom: 50, left: 80}
    width = 940 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom
    
    view = d3.select('#distribution_graph').append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
      .append('g')
      .attr('transform', "translate(#{margin.left},#{margin.top})")
    
    view.append('text')
      .text('SAT score')
      .attr('x', width/2)
      .attr('y', height+margin.bottom-5)
      
    view.append('text')
      .text('Number of schools')
      .attr('y', -40)
      .attr('x', -height/1.5)
      .attr('transform', 'rotate(270)')
      
    x_axis_view = view.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{height})")
    
    y_axis_view = view.append('g')
      .attr('class', 'y axis')
    
    x_scale = d3.scale.linear().domain(@sat_extent).range([0, width])
    x_axis = d3.svg.axis().scale(x_scale).orient('bottom').ticks(10)

    # Generate a histogram using uniformly-spaced bins
    hist_data = d3.layout.histogram().bins(x_scale.ticks(75))(@sat_scores)

    max_y_value = d3.max(hist_data, (d) -> d.y)
    y_scale = d3.scale.linear().domain([0, max_y_value]).range([height, 0])
    y_axis = d3.svg.axis().scale(y_scale).orient('left').tickFormat(d3.format('.0f'))
    
    bars = view.selectAll(".bar").data(hist_data)

    bars.enter().append('rect')
      .attr('class', 'bar')
      .attr('width', 10)
      .attr('fill', (d) => @color_scale(d.x))
    bars.exit().remove()

    bars
      .attr('x', (d) -> x_scale(d.x))
      .attr('height', (d) => height - y_scale(d.y) )
      .attr('y', (d) -> y_scale(d.y))

    x_axis_view.call(x_axis)
    y_axis_view.call(y_axis)

  create_regional_graph: ->    
    margin = {top: 20, right: 80, bottom: 20, left: 20}
    width = 960 - margin.left - margin.right
    height = 500 - margin.top - margin.bottom
    
    @lng_extent = d3.extent @data.map((d) -> d.lng)
    @lat_extent = d3.extent @data.map((d) -> d.lat)
    
   # create the view
    @regional_graph_view = d3.select('#regional_graph').append('svg')
      .attr('width', width + margin.left + margin.right)
      .attr('height', height + margin.top + margin.bottom)
      .append('g')
      .attr('transform', "translate(#{margin.left},#{margin.top})")
    
    # estimate the 12th grade class enrollment and scale it so it represents the radius of the circle
    enrollment_r = (d) ->
      (d['School Enrollment']/(d['Grades Offered'].split(',').length*Math.PI))^(1/2)
    
    r_scale = d3.scale.linear()
      .domain(d3.extent(@data.map enrollment_r))
      .range([5,20])
        
    # projection roughly centered on PA
    projection = d3.geo.conicConformal()
      .rotate([77.7, 0])
      .center([0, 41])
      .parallels(@lat_extent)
      .scale(10000)
      .translate([width/2, height/2])
      .precision(.1);
    
    # draw the US land boundaries, states, and counties
    # see: http://bl.ocks.org/mbostock/3734308
    path = d3.geo.path().projection(projection)
    d3.json 'vendor/us.json', (error, us) =>
      @regional_graph_view.append("path", ".boundary")
        .datum(topojson.feature(us, us.objects.land))
        .attr("class", "land")
        .attr("d", path)
      @regional_graph_view.append("path", ".boundary")
        .datum(topojson.mesh(us, us.objects.states, (a, b) -> a isnt b))
        .attr("class", "state-boundary")
        .attr("d", path)
      @regional_graph_view.insert("path", ".boundary")
        .datum(topojson.mesh(us, us.objects.counties, (a, b) -> 
          a isnt b and not (a.id / 1000 ^ b.id / 1000) ))
        .attr("class", "county-boundary")
        .attr("d", path)

    # add the circles
    @circles = @regional_graph_view
      .selectAll('circle')
      .data(@data)
      .enter()
      .append('circle')
      .attr('class', 'circle')

    @circles
      .attr('cx', (d) => projection([d.lng,d.lat])[0])
      .attr('cy', (d) => projection([d.lng,d.lat])[1])
      .attr('r', (d) -> r_scale(enrollment_r(d)))
      .attr('stroke', (d) => @color_scale(d['SAT Subject Scores (Averages) - Math']))
    
    # add the size legend
    sizes = [20,  250, 500, 750, 1000]
    legend_data = sizes.map (s) -> { r: Math.sqrt(s/Math.PI), size: s }
    legend_view_2 = d3.select('#regional_graph_legend_2').append('svg')
      .attr('width', 200)
      .attr('height', 250)
      .append('g')
      .attr('transform', "translate(25,20)")
    legend_view_2.append('text')
      .text('Grad. class size')
      .attr('class', 'legend_header')
      .attr('x',-15)
    legend = legend_view_2.selectAll('.legend')
      .data(legend_data.reverse())
      .enter().append('g')
      .attr('transform', (d,i) -> "translate(10,#{(Math.sqrt(i+1))*50-40})")
    legend.append('circle')
      .attr('class', 'legend-circle')
      .attr('cy', (d,i) -> 20*i+20 )
      .attr('r', (d) -> d.r)
    legend.append('text')
      .attr('x', 34)
      .attr('y', (d,i) -> 20*i+20)
      .attr('dy', '.35em')
      .text((d) -> "#{Math.round(d.size)}")
    
    # tooltips
    tip = @get_tooltip()
    @regional_graph_view.call(tip)
    @circles
      .on('mouseover', tip.show)
      .on('mouseout', tip.hide)
  
  get_tooltip: ->
    tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset([-10, 0])
      .html (d) -> 
        "<p>#{d.name}</p>" +
        "<p>#{d['School Address (City)']}</p>" +
        "<p>Math SAT: #{Math.round(d['SAT Subject Scores (Averages) - Math'])}</p>" +
        "<p>Class size: #{Math.round(d['School Enrollment']/(d['Grades Offered'].split(',').length))}</p>"
    
  append_color_scale_legend: (parent_view_id) ->
    colors = @color_scale.range()
    legend_data = colors.map (c) => { color: c, scores: @color_scale.invertExtent(c) }
    legend_view = d3.select("##{parent_view_id}").append('svg')
      .attr('width', 200)
      .attr('height', 250)
      .append('g')
      .attr('transform', "translate(25,20)")
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


