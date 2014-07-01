<nav><a href='/'><div id='logo'></div></a></nav>

# Pennsylvania Public High Schools

May 2014

## Intro

The Pennsylvania Dept of Education provides [in-depth metrics](http://paschoolperformance.org/) about each public school in the state. While this data is detailed, by itself it doesn't provide any visibility into overall performance trends across the state. The goal of this project is to augment the data set with visualizations that provide insight into trends and patterns in the data.

Notes:
- All data shown is from the 2012-2013 school year
- [Source data and code](#sources)

## Data Visualizations

<p class='graph_header'>School score distribution</p>
<p class='graph_desc'>Each high school's average SAT score is considered one unit in the distribution. Although the familiar 'bell-curve' is apparent, there are quite a few schools on the left side of the performance spectrum with substantially worse performance than the median.</p>

<div id='distribution_graph_container' class='graph_container'>
  <div id='distribution_graph' class='graph'></div>
  <div id='distribution_graph_legend_1' class='legend'></div>
</div>

<p class='graph_header'>Best and worst schools</p>
<p class='graph_desc'>Each high school is represented by a vertical bar. Only the best and worst ranking 1/7th of the schools are shown. Of note is the city of Philadelphia, which has two of the top schools and many of the lowest performing schools.</p>

<div id='ranking_graph_container' class='graph_container'>
  <div id='ranking_graph' class='graph'></div>
  <div id='ranking_graph_legend_1' class='legend'></div>
  <div id='ranking_graph_controls'></div>
</div>

<p class='graph_header'>Scores by region</p>
<p class='graph_desc'>Each high school in PA is represented by a circle on the map - the color represents the school average SAT score, and the area of the circle represents the school's estimated graduating class size. City schools tend to perform much worse than the rings of suburban schools surrounding them.</p>

<div id='regional_graph_container' class='graph_container'>
  <div id='regional_graph' class='graph'></div>
  <div id='regional_graph_legend_1' class='legend'></div>
  <div id='regional_graph_legend_2' class='legend'></div>
</div>

<p class='graph_header'>School metrics</p>
<p class='graph_desc'>Scatterplots illustrate potential correlations between two metrics - each circle represents a single school. Note the strong correlation between SAT scores and the percentage of 'Economically Disadvantaged' students.</p>

<div id='scatterplot_graph_container' class='graph_container'>
  <div id='scatterplot_graph' class='graph'></div>
  <div id='scatterplot_controls'>
    Metrics    
  </div>
</div>

## <a name="sources">Source Data and Code</a>
- [Source data is from PA dept of education](http://paschoolperformance.org/Downloads)
- [Source code for the visualizations](https://github.com/mstubna/pa_schools)
