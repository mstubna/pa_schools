
class @Scatterplot
  
  constructor: (args) ->
    {@data} = args
    @margin = {top: 20, right: 20, bottom: 80, left: 80}
    @width = 500 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom

    @create_view()
    @add_selectors()
    @x_selector.prop 'selectedIndex', @select_options.length-1
    @update_view()

  create_view: ->
    @view = d3.select('#scatterplot_graph').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")
      
    @points = @view
      .selectAll('circle')
      .data(@data)
      .enter()
      .append('circle')
      .attr('class', 'circle')
      .attr('r', 5)

    @x_axis_view = @view.append('g')
      .attr('class', 'axis')
      .attr('transform', "translate(0,#{@height})")

    @y_axis_view = @view.append('g')
      .attr('class', 'axis')
    
    @x_axis_label = @view.append('text')
      .attr('x', @width/2)
      .attr('y', @height+@margin.bottom/2)
      .style('text-anchor', 'middle')

    @y_axis_label = @view.append('text')
      .attr('y', -45)
      .attr('x', -@height/2)
      .attr('transform', 'rotate(270)')
      .style('text-anchor', 'middle')
  
    @tips = d3.tip().attr('class', 'd3-tip').offset([-10, 0])
    @view.call(@tips)
    
    self = this
    @points
      .on('mouseover', (d) -> 
        self.tips.show(d)
        this.parentNode.appendChild(this)
        d3.select(this)
          .attr('r', 7)
          .classed('active',true))
      .on('mouseout', (d) -> 
        self.tips.hide(d)
        d3.select(this)
          .attr('r', 5)
          .classed('active',false))
  
  add_selectors: ->
    @select_options = [
      'SAT Subject Scores (Averages) - Math'
      'SAT Subject Scores (Averages) - Reading'
      'SAT Subject Scores (Averages) - Writing'
      'Black or African American (not Hispanic)'
      'White (not Hispanic)'
      'Hispanic (any race)'
      'Asian (not Hispanic)'
      'American Indian/Alaskan Native (not Hispanic)'
      'Multi-Racial (not Hispanic)'
      'Male'
      'Female'
      'Economically Disadvantaged' 
    ]

    @x_selector = $("<select id='x_selector'></select>")
    @x_selector.append @select_options.map (o) -> "<option>#{o}</option>"
    @x_selector.on 'change', @update_view

    @y_selector = $("<select id='y_selector'></select>")
    @y_selector.append @select_options.map (o) -> "<option>#{o}</option>"
    @y_selector.on 'change', @update_view

    $('#scatterplot_controls').append [@x_selector, @y_selector]

  update_view: =>
    x_metric = @select_options[@x_selector.prop('selectedIndex')]
    y_metric = @select_options[@y_selector.prop('selectedIndex')]
    
    x_domain = d3.extent(@data.map (d) -> parseFloat(d[x_metric]))
    y_domain = d3.extent(@data.map (d) -> parseFloat(d[y_metric]))

    @update_scales x_domain, y_domain
    @update_axes x_metric, y_metric
    
    @points
      .transition()
      .duration(1000)
      .attr('cx', (d) => @x_scale(d[x_metric]))
      .attr('cy', (d) => @y_scale(d[y_metric]))
    
    @tips.html (d) -> 
      "<p>#{d.name}</p>" +
      "<p>#{d['School Address (City)']}</p>" +
      "<p>#{x_metric}: #{d[x_metric]}</p>" +
      "<p>#{y_metric}: #{d[y_metric]}</p>"

  update_scales: (x_domain, y_domain) ->
    @x_scale = d3.scale.linear().domain(x_domain).range([0, @width]).nice()
    @y_scale = d3.scale.linear().domain(y_domain).range([@height, 0]).nice()

  update_axes: (x_label, y_label) ->
    @x_axis_label.text x_label
    @y_axis_label.text y_label 

    @x_axis = d3.svg.axis().orient('bottom').scale(@x_scale)
    @y_axis = d3.svg.axis().orient('left').scale(@y_scale)    

    @x_axis_view.call @x_axis
    @y_axis_view.call @y_axis
