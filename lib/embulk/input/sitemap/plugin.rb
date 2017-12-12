module Embulk
  module Input
    module Sitemap
      class Plugin < InputPlugin
        Embulk::Plugin.register_input("sitemap", self)

        def self.transaction(config, &control)
          # configuration code:
          task = {
            "url" => config.param("url", :string),
            "params" => config.param("params", :array, default: []),
          }

          columns = [
            Column.new(0, "loc", :string),
            Column.new(1, "lastmod", :string),
            Column.new(2, "priority", :double),
            Column.new(3, "changefreq", :string),
          ]

          resume(task, columns, 1, &control)
        end

        def self.resume(task, columns, count, &control)
          task_reports = yield(task, columns, count)

          next_config_diff = {}
          return next_config_diff
        end

        def init
        end

        def run
          client = Embulk::Input::Sitemap::Client.new(task["url"], task["params"])
          client.invoke.each do |item|
            page_builder.add([
              item.loc,
              item.lastmod,
              item.priority,
              item.changefreq,
            ])
          end
          page_builder.finish

          task_report = {}
          return task_report
        end
      end
    end
  end
end
