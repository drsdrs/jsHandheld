module.exports = (grunt) ->
  grunt.initConfig

    watch:
      clientCoffee:
        files: "./src/coffee/**/*.coffee"
        tasks: ["coffeelint:client", "coffee:client"]
        options: { livereload: true }
      clientLess:
        files: "./src/less/**/*.less"
        tasks: ["less:client"]
        options: { livereload: true }
      views:
        files: "./views/**/*.ejs"
        options: { livereload: true }
      configFiles:
        files: [ 'gruntfile.coffee'],
        options:
          reload: true

    coffeelint:
      options:
        'max_line_length': {'level': 'ignore'}
      client:
        files:
          src: ['src/coffee/**/*.coffee']
      server:
        files:
          src: ['app.coffee', 'routes/**/*.coffee']        

    coffee:
      client:
        options:
          join: true
          bare: true
          sourceMap: true
        files:
          'public/scripts/main.js': 'src/coffee/main.coffee'
          'public/scripts/terminal.js': 'src/coffee/terminal/**/*.coffee'
          'public/scripts/fst.js': 'src/coffee/fst/**/*.coffee'
          'public/scripts/endymen.js': 'src/coffee/endymen/**/*.coffee'#, 'src/coffee/utils/keyField.coffee'
          'public/scripts/turnbased.js': 'src/coffee/turnbased/**/*.coffee'#, 'src/coffee/utils/keyField.coffee'

    less:
      client:
        files:
          'public/stylesheets/style.css':'src/less/style.less'
          'public/stylesheets/fst.css':'src/less/fst.less'
          'public/stylesheets/endymen.css':'src/less/endymen.less'
          'public/stylesheets/turnbased.css':'src/less/turnbased.less'

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-less"
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  # Default task(s).
  grunt.registerTask "wicked", ["watch"]
  grunt.registerTask "default", ["coffeelint", "coffee","less", "watch"]
