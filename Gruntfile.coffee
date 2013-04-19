module.exports = (grunt) ->
  appDirs = [
    'bower_components/closure-library'
    'bower_components/este-library'
    'src'
  ]

  appCoffeeFiles = [
    'bower_components/este-library/**/*.coffee'
    '!bower_components/este-library/demos/**/*.coffee'
    '!bower_components/este-library/app/**/*.coffee'
    'src/**/*.coffee'
  ]

  ccJSFiles = [
    'src/inplace/**/*.js',
    'src/api.js'
  ]

  ccCoffeeFiles = [
    'src/**/*.coffee'
  ]

  appCompiledOutputPath =
    'build/cc.js'

  depsPath =
    'src/deps.js'

  # from closure base.js dir to app root dir
  depsPrefix = '../../../../'

  grunt.initConfig

    clean:
      app:
        options:
          force: true
        src: [
          'bower_components/este-library/**/*.js'
          'src/**/*.js'
        ]

  # same params as grunt-contrib-coffee
    esteCoffee:
      options:
        bare: true
      app:
        files: [
          expand: true
          src: appCoffeeFiles
          ext: '.js'
        ]

    esteDeps:
      all:
        options:
          depsWriterPath: 'bower_components/closure-library/closure/bin/build/depswriter.py'
          outputFile: depsPath
          prefix: depsPrefix
          root: appDirs

    esteBuilder:
      options:
        closureBuilderPath: 'bower_components/closure-library/closure/bin/build/closurebuilder.py'
        compilerPath: 'bower_components/closure-compiler/compiler.jar'
      # needs Java 1.7+, see http://goo.gl/iS3o6
        fastCompilation: false
        depsPath: depsPath
        compilerFlags: if grunt.option('stage') == 'debug' then [
          '--output_wrapper="(function(){%output%})();"'
          '--compilation_level="ADVANCED_OPTIMIZATIONS"'
          '--warning_level="VERBOSE"'
          '--define=goog.DEBUG=true'
          '--debug=true'
          '--formatting="PRETTY_PRINT"'
        ]
        else [
            '--output_wrapper="(function(){%output%})();"'
            '--compilation_level="ADVANCED_OPTIMIZATIONS"'
            '--warning_level="VERBOSE"'
            '--define=goog.DEBUG=false'
          ]

      app:
        options:
          namespace: 'cc.api'
          root: appDirs
          outputFilePath: appCompiledOutputPath

    esteUnitTests:
      options:
        basePath: 'bower_components/closure-library/closure/goog/base.js'
      app:
        options:
          depsPath: depsPath
          prefix: depsPrefix
        src: [
          'src/**/*_test.js'
        ]

    esteWatch:
      app:
        js:
          files: ccJSFiles
          tasks: [
            'esteDeps:all'
            'esteUnitTests:app'
            'esteBuilder:app'
          ]

        coffee:
          files: ccCoffeeFiles
          tasks: 'esteCoffee:app'

    coffeelint:
      options:
        no_backticks:
          level: 'ignore'
        max_line_length:
          level: 'ignore'
        line_endings:
          value: 'unix'
          level: 'error'
      all:
        files: [
          expand: true
          src: ccCoffeeFiles
          ext: '.js'
        ]

  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-jshint'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-este'

  grunt.registerTask 'build', 'Build app.', (app) ->
    tasks = [
      "clean:#{app}"
      "coffeelint"
      "esteCoffee:#{app}"
      "esteDeps"
      "esteUnitTests:#{app}"
      "esteBuilder:#{app}"
    ]
    grunt.task.run tasks

  grunt.registerTask 'run', 'Build app and run watchers.', (app) ->
    tasks = [
      "build:#{app}"
      "esteWatch:#{app}"
    ]
    grunt.task.run tasks

  grunt.registerTask 'default', 'run:app'

  grunt.registerTask 'test', 'build:app'
