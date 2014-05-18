
class @RankingGraph
  
  constructor: (args) ->
    {@data, @sat_extent, @color_scale, @append_color_scale_legend, @get_tooltip} = args
    @margin = {top: 20, right: 0, bottom: 50, left: 80}
    @width = 940 - @margin.left - @margin.right
    @height = 500 - @margin.top - @margin.bottom

    @create_view()
    @append_color_scale_legend 'ranking_graph_legend_1'
    @add_controls()
    @update_view()

  create_view: ->
    @view = d3.select('#ranking_graph').append('svg')
      .attr('width', @width + @margin.left + @margin.right)
      .attr('height', @height + @margin.top + @margin.bottom)
      .append('g')
      .attr('transform', "translate(#{@margin.left},#{@margin.top})")

    @view.append('text')
      .text('Worst schools')
      .attr('x', @width/4)
      .attr('y', @height+@margin.bottom/2)
      .style('text-anchor', 'middle')

    @view.append('text')
      .text('Best schools')
      .attr('x', 3*@width/4)
      .attr('y', @height+@margin.bottom/2)
      .style('text-anchor', 'middle')

    @view.append('text')
      .text('SAT score')
      .attr('y', -45)
      .attr('x', -@height/2)
      .attr('transform', 'rotate(270)')
      .style('text-anchor', 'middle')

    x_axis_view = @view.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0,#{@height})")

    y_axis_view = @view.append('g')
      .attr('class', 'y axis')

    x_scale = d3.scale.linear().domain([0, 2*@data.length/7]).range([0, @width])

    y_scale = d3.scale.linear().domain(@sat_extent).range([@height, 0])
    y_axis = d3.svg.axis().scale(y_scale).orient('left').tickFormat(d3.format('.0f'))

    # only show the first and last 1/7 of the data
    data = (d for d,i in @data.slice().reverse() when i < @data.length/7 or i > 6*@data.length/7)
    @bars = @view.selectAll(".bar").data(data)

    @bars.enter().append('rect')
      .attr('class', 'bar')
      .attr('width', 4)
      .attr('fill', (d) => @color_scale(d['SAT Subject Scores (Averages) - Math']))
      .attr('x', (d,i) -> x_scale(i))
      .attr('height', (d) => @height - y_scale(d['SAT Subject Scores (Averages) - Math']))
      .attr('y', (d) -> y_scale(d['SAT Subject Scores (Averages) - Math']))

    y_axis_view.call(y_axis)

    # tooltips
    tip = @get_tooltip()
    @view.call(tip)
    self = this
    @bars
      .on('mouseover', (d) -> 
        tip.show(d)
        d3.select(this)
          .attr('fill', 'rgb(50,50,50)'))
      .on('mouseout', (d) ->
        tip.hide(d)
        d3.select(this)
          .attr('fill', (d) -> self.color_scale(d['SAT Subject Scores (Averages) - Math'])))

  add_controls: ->
    @checkbox = $("<input type='checkbox' name='ranking_checkbox' id='ranking_checkbox'>")
    @checkbox.on 'change', =>
      @update_view()
      return false

    label = $("<label for='ranking_checkbox'>Highlight Philadelphia schools</label>")
    $('#ranking_graph_controls').append @checkbox, label

  update_view: =>
    should_highlight_philly = @checkbox.prop('checked')
    @bars
      .attr('opacity', (d) ->
        if not should_highlight_philly
          1
        else 
          if d['School Address (City)'] is 'Philadelphia' then 1 else 0.3)

