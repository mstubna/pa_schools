
class @DistributionGraph
  
  constructor: (args) ->
    {@data, @sat_scores, @sat_extent, @color_scale, @append_color_scale_legend, @get_tooltip} = args
    @margin = {top: 20, right: 0, bottom: 50, left: 80}
    @width = 940 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom

    @create_view()
    @append_color_scale_legend 'distribution_graph_legend_1'

  create_view: ->    
    view = d3.select('#distribution_graph').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")
    
    view.append('text')
      .text('SAT score')
      .attr('x', @width/2)
      .attr('y', @height+@margin.bottom-5)
      .style('text-anchor', 'middle')
      
    view.append('text')
      .text('Number of schools')
      .attr('y', -40)
      .attr('x', -@height/2)
      .attr('transform', 'rotate(270)')
      .style('text-anchor', 'middle')
      
    x_axis_view = view.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@height})")
    
    y_axis_view = view.append('g')
      .attr('class', 'y axis')
    
    x_scale = d3.scale.linear().domain(@sat_extent).range([0, @width])
    x_axis = d3.svg.axis().scale(x_scale).orient('bottom').ticks(10)

    # Generate a histogram using uniformly-spaced bins
    hist_data = d3.layout.histogram().bins(x_scale.ticks(75))(@sat_scores)

    max_y_value = d3.max(hist_data, (d) -> d.y)
    y_scale = d3.scale.linear().domain([0, max_y_value]).range([@height, 0])
    y_axis = d3.svg.axis().scale(y_scale).orient('left').tickFormat(d3.format('.0f'))
    
    bars = view.selectAll(".bar").data(hist_data)

    bars.enter().append('rect')
      .attr('class', 'bar')
      .attr('width', 10)
      .attr('fill', (d) => @color_scale(d.x))
    bars.exit().remove()

    bars
      .attr('x', (d) -> x_scale(d.x))
      .attr('height', (d) => @height - y_scale(d.y) )
      .attr('y', (d) -> y_scale(d.y))

    x_axis_view.call(x_axis)
    y_axis_view.call(y_axis)