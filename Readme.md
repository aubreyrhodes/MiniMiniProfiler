MiniMini Profiler is a fork of Mini Profiler that is aimed a beginning rails programmers.

To install add the following to your gemfile and then run the `bundle` command:

```
gem 'mini-mini-profiler', :require => 'rack-mini-profiler' 
```

And add the following to `ApplicationController` in `app/controllers/application_controller.rb`

```ruby
before_filter :setup_profiler                                                                                                                                                                                                                                                      

def setup_profiler
  Rack::MiniProfiler.authorize_request
end
```
