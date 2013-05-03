require 'fileutils'

module Rack::MiniProfilerRails

  # call direct if needed to do a defer init
  def self.initialize!(app)
    c = Rack::MiniProfiler.config

    # By default, only show the MiniProfiler in development mode, in production allow profiling if post_authorize_cb is set
    c.pre_authorize_cb = lambda { |env|
      !Rails.env.test?
    }

    c.skip_paths ||= []

    if Rails.env.development?
      c.skip_paths << "/assets/"
      c.skip_schema_queries = true
    end

    if Rails.env.production?
      c.authorization_mode = :whitelist
    end

    # The file store is just so much less flaky
    tmp = Rails.root.to_s + "/tmp/miniprofiler"
    FileUtils.mkdir_p(tmp) unless File.exists?(tmp)

    c.storage_options = {:path => tmp}
    c.storage = Rack::MiniProfiler::FileStore

    # Quiet the SQL stack traces
    c.backtrace_remove = Rails.root.to_s + "/"
    c.backtrace_includes =  [/^\/?(app|config|lib|test)/]
    c.skip_schema_queries =  Rails.env != 'production'

    # Install the Middleware
    app.middleware.insert(0, Rack::MiniProfiler)
  end

  class Railtie < ::Rails::Railtie

    initializer "rack_mini_profiler.configure_rails_initialization" do |app|
      Rack::MiniProfilerRails.initialize!(app)
    end

    config.after_initialize do
      # Attach to various Rails methods
      ::Rack::MiniProfiler.profile_method(ActionController::Base, :process) {|action| "Controller: #{self.class.name} Action: #{action}"}
      ::Rack::MiniProfiler.profile_method(ActionView::Template, :render) {|x,y| "View: #{@virtual_path}"}

      # preload all model classes
      Dir.glob("#{Rails.root}/app/models/**/*.rb").map{|file| file.match(/([^\/]+).rb/)[1].camelize.constantize}

      ActiveRecord::Base.subclasses.each do |model_class|
        (model_class.instance_methods - ActiveRecord::Base.instance_methods + [:save, :update_attributes, :initialize]).each do |method|
          # ::Rack::MiniProfiler.profile_method(model_class, method){ |*args| "Model: #{self.class.name} Method: #{method}" }
          unless method.to_s =~ /^_.*/
            ::Rack::MiniProfiler.profile_method(model_class, method){ |*args| "Model: #{ self.class.name } Method: #{ method }" }
          end
        end

        ((model_class.public_methods - ActiveRecord::Base.public_methods) + [:find, :where, :order, :all]).each do |method|
          unless method.to_s =~ /^_.*/
            ::Rack::MiniProfiler.profile_method(model_class, method, true){ |*args| "Model: #{ self.name } Method: #{ method }" }
          end
        end
      end
    end


    # TODO: Implement something better here
    # config.after_initialize do
    #
    #   class ::ActionView::Helpers::AssetTagHelper::JavascriptIncludeTag
    #     alias_method :asset_tag_orig, :asset_tag
    #     def asset_tag(source,options)
    #       current = Rack::MiniProfiler.current
    #       return asset_tag_orig(source,options) unless current
    #       wrapped = ""
    #       unless current.mpt_init
    #         current.mpt_init = true
    #         wrapped << Rack::MiniProfiler::ClientTimerStruct.init_instrumentation
    #       end
    #       name = source.split('/')[-1]
    #       wrapped << Rack::MiniProfiler::ClientTimerStruct.instrument(name, asset_tag_orig(source,options)).html_safe
    #       wrapped
    #     end
    #   end

    #   class ::ActionView::Helpers::AssetTagHelper::StylesheetIncludeTag
    #     alias_method :asset_tag_orig, :asset_tag
    #     def asset_tag(source,options)
    #       current = Rack::MiniProfiler.current
    #       return asset_tag_orig(source,options) unless current
    #       wrapped = ""
    #       unless current.mpt_init
    #         current.mpt_init = true
    #         wrapped << Rack::MiniProfiler::ClientTimerStruct.init_instrumentation
    #       end
    #       name = source.split('/')[-1]
    #       wrapped << Rack::MiniProfiler::ClientTimerStruct.instrument(name, asset_tag_orig(source,options)).html_safe
    #       wrapped
    #     end
    #   end

    # end

  end
end
