# Pennsylvania Public High Schools

- Data visualizations demonstrate underlying patterns and relationships between school demographics and performance metrics across the state
- All data shown is from the 2012-2013 school year
- [Source data is from PA dept of education](http://paschoolperformance.org/Downloads)
- [Source code for the visualizations](https://github.com/mstubna/pa_schools)

<p class='graph_header'>School score distribution</p>
<p class='graph_desc'>Each high school's average SAT score is considered one unit in the distribution.</p>

<div id='distribution_graph_container' class='graph_container'>
  <div id='distribution_graph' class='graph'></div>
  <div id='distribution_graph_legend_1' class='legend'></div>
</div>

<p class='graph_header'>Best and worst schools</p>
<p class='graph_desc'>Each high school is represented by a vertical bar. Only the best and worst ranking 1/7th of the schools are shown.</p>

<div id='ranking_graph_container' class='graph_container'>
  <div id='ranking_graph' class='graph'></div>
  <div id='ranking_graph_legend_1' class='legend'></div>
  <div id='ranking_graph_controls'></div>
</div>

<p class='graph_header'>Scores by region</p>
<p class='graph_desc'>Each high school in PA is represented by a circle on the map - the color represents the school average SAT score, and the area of the circle represents the school's estimated graduating class size.</p>

<div id='regional_graph_container' class='graph_container'>
  <div id='regional_graph' class='graph'></div>
  <div id='regional_graph_legend_1' class='legend'></div>
  <div id='regional_graph_legend_2' class='legend'></div>
</div>

<p class='graph_header'>School metrics</p>
<p class='graph_desc'>Scatterplots illustrate potential correlations between two metrics - each circle represents a single school.</p>

<div id='scatterplot_graph_container' class='graph_container'>
  <div id='scatterplot_graph' class='graph'></div>
  <div id='scatterplot_controls'>
    Metrics    
  </div>
</div>
