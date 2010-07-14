require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")

class TruckGenerator < Rails::Generator::Base

  def manifest
    record do |m|
      @legacy_models = Dir.glob(RAILS_ROOT + '/app/models/*.rb').collect { |model_path| File.basename(model_path).gsub('.rb', '') }

      m.directory 'app/models/legacy'
      m.file 'legacy_base.rb', 'app/models/legacy/legacy_base.rb'

      @legacy_models.each do |model_name|
        m.template 'legacy_model.erb', "app/models/legacy/#{model_name.downcase}.rb", :assigns => { :model_name => model_name }
      end

      m.directory 'lib/tasks'
      m.template 'legacy_task.erb', 'lib/tasks/legacy.rake', :assigns => { :legacy_models => @legacy_models }
      snippet = <<EOS
legacy:
  adapter: mysql
  database: #{RAILS_ROOT.split('/').last}_legacy
  username:
  password:
EOS

      m.insert_before "config/database.yml", snippet, "production:"
      
    end
  end

end
