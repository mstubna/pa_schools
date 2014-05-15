
module.exports = ->
  
  # display exception stack trace
  @option 'stack', true
  
  # grunt configuration
  @initConfig
    pkg: @file.readJSON 'package.json'
    
    exec:
      preview:
        command: 'node app'
    
    # watch for changes in the soure files and 
    # perform the appropriate tasks
    watch:
      coffeescripts:
        files: ['source/coffeescripts/*']
        tasks: 'coffee'
      stylesheets:
        files: ['source/stylesheets/*']
        tasks: 'sass'
      markdown:
        files: ['source/content/*', 'source/templates/*']
        tasks: 'markdown'

    # convert coffeescript -> js
    coffee:
      options:
        join: true
      project: 
        files: [{
          expand: true
          cwd: 'source/coffeescripts'
          src: ['**/*.coffee']
          dest: 'build/javascripts'
          ext: '.js'
        }]

    # convert scss -> css
    sass: 
      project:
        options:
          noCache: true
        files: [
          expand: true
          cwd: 'source/stylesheets'
          src: ['*.scss']
          dest: 'build/stylesheets'
          ext: '.css'
        ]

    # convert markdown files -> html
    markdown:
      index:
        options:
          template: 'source/templates/index_template.ejs'
        files: 'build/index.html' : 'source/content/index.md'

    # copy all the other assets to the build folder
    copy:
      static_assets:
        files: [
          { expand: true, cwd: 'source/images/', src: ['**'], dest: 'build/images/' }
          { expand: true, cwd: 'source/vendor/', src: ['**'], dest: 'build/vendor/' }
          { expand: true, cwd: 'source/fonts/', src: ['**'], dest: 'build/fonts/' }
          { expand: true, cwd: 'source/data/', src: ['**'], dest: 'build/data/' }
        ]

  # load npm tasks
  @loadNpmTasks 'grunt-exec'
  @loadNpmTasks 'grunt-contrib-coffee'
  @loadNpmTasks 'grunt-contrib-sass'
  @loadNpmTasks 'grunt-markdown'
  @loadNpmTasks 'grunt-contrib-copy'
  @loadNpmTasks 'grunt-contrib-watch'
  
  # load tasks in other files in the 'tasks' directory
  @loadTasks 'tasks'
  
  # creates a clean build
  @task.registerTask 'build', =>
    @file.delete 'build'
    @file.mkdir 'build'
    @task.run ['coffee', 'sass', 'markdown', 'copy']
  
  # creates a clean build and watch for changes, updating the build as necessary
  @task.registerTask 'build_and_watch', =>
    @task.run ['build', 'watch']

  # start the web server for previewing the site
  @task.registerTask 'preview', =>
    @task.run 'exec:preview'

