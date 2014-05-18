# Pennsylvania Public High Schools

- Data visualizations demonstrate underlying patterns and relationships between regional demographics and school performance metrics across the state.
- Data is from [PA dept of education school performance site](http://paschoolperformance.org/Downloads).
- All data is from the 2012-2013 school year.
- [Source code used to generate the visualizations](https://github.com/mstubna/pa_schools)

<p class='graph_header'>School score distribution</p>
<p class='graph_desc'>Each high school's average SAT score is considered one unit in this distribution.</p>

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
<p class='graph_desc'>Each high school in PA is represented by a circle - the color represents the school average SAT Math score from lowest (red) to highest (green). And the area of the circle represents the school's estimated 12th grade class size.</p>

<div id='regional_graph_container' class='graph_container'>
  <div id='regional_graph' class='graph'></div>
  <div id='regional_graph_legend_1' class='legend'></div>
  <div id='regional_graph_legend_2' class='legend'></div>
</div>

<p class='graph_header'>School metric correlations</p>
<p class='graph_desc'>A scatterplot can show underlying correlation between two metrics. Select two metrics - each circle represents a single school.</p>

<div id='scatterplot_graph_container' class='graph_container'>
  <div id='scatterplot_graph' class='graph'></div>
  <div id='scatterplot_controls'>
    Metrics    
  </div>
</div>
