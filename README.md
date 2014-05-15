# Visualizing PA school performance

[View the interactive demo](http://mountaintrackapps.com/pa_schools/index.html).

## Running and Building

The demo is a static web site comprised of .html, .js, and .css files. The source files are written in coffeescript, sass, and markdown. The project can be built and run using [node.js](http://nodejs.org/) and [Grunt](http://gruntjs.com/).

1. Install `node` and `npm` if you don't already have them installed. See the [official install docs.](http://www.joyent.com/blog/installing-node-and-npm/).

2. Install the Grunt CLI. See the [getting started guide.](http://gruntjs.com/getting-started)

3. After downloading this repository, navigate to your project directory and install the dependencies:

        $ npm install

4. To build the project and automatically rebuild when source files change:

        $ grunt build_and_watch
        
5. To preview the site, start the web server by opening a new terminal window and

        $ grunt preview
        
  then point your browser to <http://localhost:8000/index.html>
  
## Questions?

Contact Mike Stubna `mike@stubna.com`