require File.expand_path(File.dirname(__FILE__) + "/lib/insert_commands.rb")

class TruckGenerator < Rails::Generators::Base
  source_root File.expand_path("../templates", __FILE__)
  def manifest
    @legacy_models = Dir.glob(Rails.root.join('app/models/*.rb')).collect { |model_path| File.basename(model_path).gsub('.rb', '') }
    empty_directory 'app/models/legacy'
    copy_file 'legacy_base.rb', 'app/models/legacy/legacy_base.rb'

    @legacy_models.each do |model_name|
      template 'legacy_model.erb', "app/models/legacy/legacy_#{model_name.downcase}.rb", { :model_name => model_name }
    end

    empty_directory 'lib/tasks'
    template 'legacy_task.erb', 'lib/tasks/legacy.rake', { :legacy_models => @legacy_models }
      
    snippet = <<EOS
legacy:
  adapter: mysql
  database: #{Rails.root.to_s.split('/').last}_legacy
  encoding: utf8
  username:
  password:
EOS

    append_to_file "config/database.yml", snippet
      
  end

end
