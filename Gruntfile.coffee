module.exports = ->
  @initConfig
    pkg: @file.readJSON 'package.json'

    mochaTest:
      nodejs:
        src: ['spec/*.coffee']
        options:
          reporter: 'spec'
          require: 'coffee-script/register'

  # Grunt plugins used for testing
  @loadNpmTasks 'grunt-mocha-test'

  @registerTask 'test', 'Build and run tests', (target = 'all') =>
    @task.run 'mochaTest'

  @registerTask 'default', ['test']
