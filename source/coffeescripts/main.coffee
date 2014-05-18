$ ->
  new Main

class Main
  
  constructor: ->
    @data = window.high_school_data    

    @data.sort (a,b) -> 
      b['SAT Subject Scores (Averages) - Math']-a['SAT Subject Scores (Averages) - Math']
      
    @sat_scores = @data.map (d) -> d['SAT Subject Scores (Averages) - Math']
    @sat_extent = d3.extent @sat_scores

    @color_scale = d3.scale.quantile()
      .domain(@sat_scores)
      .range(['rgb(215,48,39)','rgb(252,141,89)','rgb(254,224,139)','rgb(255,255,191)','rgb(217,239,139)','rgb(145,207,96)','rgb(26,152,80)'])
      
    args = { @data, @sat_scores, @sat_extent, @color_scale, @append_color_scale_legend, @get_tooltip }
    new DistributionGraph args
    new RankingGraph args
    new RegionalGraph args
    new Scatterplot args
    
    # activate fastclick
    FastClick.attach document.body

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

  get_tooltip: ->
    tip = d3.tip()
      .attr('class', 'd3-tip')
      .offset([-10, 0])
      .html (d) -> 
        "<p>#{d.name}</p>" +
        "<p>#{d['School Address (City)']}</p>" +
        "<p>Math SAT: #{Math.round(d['SAT Subject Scores (Averages) - Math'])}</p>" +
        "<p>Class size: #{Math.round(d['School Enrollment']/(d['Grades Offered'].split(',').length))}</p>"

