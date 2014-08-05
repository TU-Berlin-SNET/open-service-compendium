SimpleCov.start do
  # any custom configs like groups and filters can be here at a central place
  add_group 'Controllers', 'app/controllers'
  add_group 'Helpers', 'app/helpers'
  add_group 'Models', 'app/models'
  add_group 'Views', 'app/views'
  add_group 'Specs', 'spec'

  add_filter 'bin'
  add_filter 'config'
  add_filter 'lib'
  add_filter 'vendor'

  refuse_coverage_drop
end