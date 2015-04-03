module.exports = (grunt) ->

  grunt.initConfig

    pkg: grunt.file.readJSON 'package.json'

    coffee:
      compile:
        expand: true
        flatten: true
        cwd: '../app/assets/javascripts/src'
        src: ['*.coffee']
        dest: '../app/assets/javascripts/dist'
        ext: '.js'


    compass:
      compile:
        options:
          sassDir: '../app/assets/stylesheets/src'
          cssDir: '../app/assets/stylesheets/dist'
          outputStyle: 'compressed'

    # express:
    #   server:
    #     options:
    #       bases: ['../app']
    #       server: 'server.coffee'
    #       port: 8000
    #       open: true

    watch:
      scripts:
        files: ['../app/assets/javascripts/src/*.coffee']
        tasks: ['coffee:compile']
      styles:
        files: ['../app/assets/stylesheets/src/*.sass']
        tasks: ['compass:compile']
      reload:
        files: ['../app/assets/stylesheets/dist/*.css', '../app/assets/javascripts/dist/*.js', '../app/*.html']
        options:
          livereload: true

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-compass'
  # grunt.loadNpmTasks 'grunt-express'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['watch', 'coffee', 'compass']
