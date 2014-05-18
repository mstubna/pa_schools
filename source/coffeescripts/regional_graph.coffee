
class @RegionalGraph
  
  constructor: (args) ->
    {@data, @sat_scores, @sat_extent, @color_scale, @append_color_scale_legend, @get_tooltip} = args
    @margin = {top: 20, right: 80, bottom: 20, left: 20}
    @width = 960 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom

    @create_view()
    @append_color_scale_legend 'regional_graph_legend_1'

  # estimate the 12th grade class enrollment and scale it so it represents the radius of the circle
  enrollment_r: (d) ->
    (d['School Enrollment']/(d['Grades Offered'].split(',').length*Math.PI))^(1/2)
  
  create_view: ->
    @lng_extent = d3.extent @data.map((d) -> d.lng)
    @lat_extent = d3.extent @data.map((d) -> d.lat)

    @r_scale = d3.scale.linear()
      .domain(d3.extent(@data.map @enrollment_r))
      .range([5,20])

    # projection roughly centered on PA
    @projection = d3.geo.conicConformal()
      .rotate([77.7, 0])
      .center([0, 41])
      .parallels(@lat_extent)
      .scale(10000)
      .translate([@width/2, @height/2])
      .precision(.1);
    
    @view = d3.select('#regional_graph').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")
      .call(d3.behavior.zoom().scaleExtent([1, 5]).on("zoom", @zoom))      
      .append('g')
    
    @view.append('rect')
      .attr('class', 'overlay')
      .attr('width', @width)
      .attr('height', @height)

    # draw the US land boundaries, states, and counties
    # see: http://bl.ocks.org/mbostock/3734308
    @boundary_view = @view.append('g')
    path = d3.geo.path().projection(@projection)
    d3.json 'vendor/us.json', (error, us) =>
      @boundary_view.append("path", ".boundary")
        .datum(topojson.feature(us, us.objects.land))
        .attr("class", "land")
        .attr("d", path)
      @boundary_view.append("path", ".boundary")
        .datum(topojson.mesh(us, us.objects.states, (a, b) -> a isnt b))
        .attr("class", "state-boundary")
        .attr("d", path)
      @boundary_view.insert("path", ".boundary")
        .datum(topojson.mesh(us, us.objects.counties, (a, b) -> 
          a isnt b and not (a.id / 1000 ^ b.id / 1000) ))
        .attr("class", "county-boundary")
        .attr("d", path)

    # create the view
    @regional_graph_view = @view.append('g')

    # add the circles
    @circles = @regional_graph_view
      .selectAll('circle')
      .data(@data)
      .enter()
      .append('circle')
      .attr('class', 'circle')

    @circles
      .attr('cx', (d) => @projection([d.lng,d.lat])[0])
      .attr('cy', (d) => @projection([d.lng,d.lat])[1])
      .attr('r', (d) => @r_scale(@enrollment_r(d)))
      .attr('stroke', (d) => @color_scale(d['SAT Subject Scores (Averages) - Math']))
      .attr('fill', 'rgba(0,0,0,0)')

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
    @legend_circles = legend.append('circle')
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
    self = this
    @circles
      .on('mouseover', (d) ->
        tip.show(d)
        d3.select(this)
          .attr('fill', (d) -> self.color_scale(d['SAT Subject Scores (Averages) - Math'])))
      .on('mouseout', (d) -> 
        tip.hide(d)
        d3.select(this)
          .attr('fill', 'rgba(0,0,0,0)'))
    
  zoom: =>
    scale = d3.event.scale
    @view.attr("transform", "translate(" + d3.event.translate + ")scale(" + scale + ")")
    @circles
      .attr('r', (d) => @r_scale(@enrollment_r(d))/Math.pow(scale*scale,2/3))
      .style('stroke-width', 1.5/scale)
    @legend_circles
      .attr('r', (d) -> d.r/Math.pow(scale,2/3))
    
