$ ->
  new Main

class Main
  
  constructor: ->
    @data = window.high_school_data    
    @data.sort (a,b) -> 
      b['SAT Subject Scores (Averages) - Math']-a['SAT Subject Scores (Averages) - Math']
    
    new Graphs { @data }
    new Scatterplot { @data }
    
    FastClick.attach document.body