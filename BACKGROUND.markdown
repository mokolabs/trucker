Background
==========

Trucker is based on a migration technique using LegacyModels first pioneered by Dave Thomas.

Sharing External ActiveRecord Connections
http://pragdave.blogs.pragprog.com/pragdave/2006/01/sharing_externa.html

Using this, I've developed a set of helpers for migrating code.

- /app/models/legacy/
- /app/models/legacy/legacy_base.rb
- /app/models/legacy/legacy_model.rb
- /config/database.yml
- /config/environment.rb
- /lib/migration_helper.rb
- /lib/tasks/migrate.rake



/app/models/legacy/
===================

This folder will contain the base Legacy model, and all subclasses.


/app/models/legacy/legacy_base.rb
=================================

This is the base Legacy model which connects to the legacy database and handles the migration.

    class LegacyBase < ActiveRecord::Base
      self.abstract_class = true
      establish_connection "legacy"
  
      def migrate
        new_record = self.class.to_s.gsub(/Legacy/,'::').constantize.new(map)
        new_record[:id] = self.id
        new_record.save
      end

    end


/app/models/legacy/legacy_model.rb
=================================

This is a sample Legacy subclass, which specifies the legacy model name and defines a map of old field names to new field names. All Legacy models are stored in /app/models/legacy to keep your main app model namespace unaffected.

    class LegacyModel < LegacyBase
      set_table_name "model"

      def map
        {
          :make => self.car_company.squish,
          :model => self.car_name.squish
        }
      end

    end



/config/environment.rb
======================

We need to update the app environment so we can load the legacy models correctly.

    Rails::Initializer.run do |config|
      config.load_paths += %W( #{RAILS_ROOT}/app/models/legacy )
    end



/config/database.yml
====================

We need to add a custom database adapter so that we can connect to our legacy database.

By convention, I've used APPNAME_legacy for my legacy databases, but you can easily customize this.

    legacy:
      adapter: mysql
      database: APPNAME_legacy
      username: root
      password:



/app/models/legacy/legacy_base.rb
=================================

This model connects to our legacy database, and provides a migration method.

    class LegacyBase < ActiveRecord::Base
      self.abstract_class = true
      establish_connection "legacy"
  
      def migrate
        new_record = self.class.to_s.gsub(/Legacy/,'::').constantize.new(map)
        new_record[:id] = self.id
        new_record.save
      end

    end



/lib/migration_helper.rb
========================

This helper is used by the rake task to manage the actual migration process.

    def migrate(name, options={})
      # Grab custom entity label if present
      label = options.delete(:label) if options[:label]
  
      unless options[:helper]
    
        # Grab model to migrate
        model = name.to_s.singularize.capitalize
    
        # Wipe out existing records
        model.constantize.delete_all

        # Status message
        status = "Migrating "
        status += "#{number_of_records || "all"} #{label || name}"
        status += " after #{offset_for_records}" if offset_for_records
    
        # Set import counter
        counter = 0
        counter += offset_for_records if offset_for_records
        total_records = "Legacy#{model}".constantize.find(:all).size
    
        # Start import
        "Legacy#{model}".constantize.find(:all, with(options)).each do |record|
          counter += 1
          puts status + " (#{counter}/#{total_records})"
          record.migrate
        end
      else
        eval options[:helper].to_s
      end
    end

    def with(options={})
      {:limit => number_of_records, :offset => offset_for_records}.merge(options)
    end

    def number_of_records
      nil || ENV['limit'].to_i if ENV['limit'].to_i > 0
    end

    def offset_for_records
      nil || ENV['offset'].to_i if ENV['offset'].to_i > 0
    end

  Available options include offset and limit:

    rake db:migrate:architects limit=1000
    rake db:migrate:architects limit=1000 offset=2000
    


  /lib/tasks/migrate.rake
  ========================

  This is the basic rake task for migrating legacy data. With a sample model, just add a new migration task with the pluralized name of your existing model. For more complicated migrations, the migrate method supports a helper method which will override the default migration behavior and allow you to do a highly customized migration.

    require 'migration_helper'

    namespace :db do
      namespace :migrate do
    
        desc 'Migrates architects'
        task :architects => :environment do
          migrate :architects
        end
    
        desc 'Migrates theaters'
        task :architects => :environment do
          migrate :theaters, :helper => :migrate_theaters
        end

      end
    end

    def migrate_theaters

      # Delete all theaters if delete_all=true
      Theater.delete_all if ENV['delete_all']

      # Set default conditions
      conditions = ["status_publish = 'Yes' AND location_address1 != '' AND location_address1 IS NOT NULL"]

      # Set counters to monitor migration
      success, failure, skipped = 0, 0, 0

      # Count number of theaters
      start = Theater.count

      # Migrate theaters
      puts "\nMigrating #{number_of_records || "all"} theaters #{"after #{offset_for_records}\n\n" if offset_for_records}"
      LegacyTheater.find(:all, with(:conditions => conditions)).each_with_index do |record, i|

        # Migrate theater
        new_record = record.migrate
        message = "#{new_record.name} (#{record.id})"

        if Theater.exists?(record.id)
          puts "#{i+1} SKIP #{message}\n\n"
          skipped += 1
        elsif new_record.save
          puts "#{i+1} PASS #{message}\n\n"
          success += 1
        else
          puts "#{i+1} FAIL #{message}\n#{new_record.inspect}\n\n"
          failure += 1
        end
  
        # Archive old theater data
        archive_old_theater_data(record)

      end

      # Count number of theaters
      finish = Theater.count

      # Batch stats
      percentage = (failure.to_f / (skipped + success + failure).to_f).to_f * 100
      puts "BATCH: #{number_of_records || "all"} theaters => #{success} passed, #{failure} failed (#{percentage.truncate}%), #{skipped} skipped (already imported)"

    end


