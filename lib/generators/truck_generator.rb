require 'rails'

class TruckGenerator < ::Rails::Generators::Base
  # TODO: once you have this thing running, factor it out into hook_for calls to more
  # specific generators. that way you can call a new subset every time you decide to
  # migrate a new model, and you don't necessarily have to give a shit about the other
  # stuff you've already set up.

  # USAGE
  # TODO: find out how Rails pulls these from USAGE files
  usage =<<-USAGE
Description:
    The Trucker gem enables you to migrate legacy data more
    painlessly than ever before.

    This generator:
      1) Adds a legacy adapter to database.yml
      2) Adds a legacy base class
      3) Adds legacy subclasses for all existing models
      4) Adds the app/models/legacy directory to the Rails load path
      5) Generates a sample migration (using pluralized model names)

    For more information:
      https://github.com/mokolabs/trucker
      https://github.com/gilesbowkett/trucker
      [link to my blog post linking up Patrick's presentations]
  USAGE
  desc usage
  source_root File.expand_path('../../../lib/generators/templates', __FILE__)

  # 1) Add legacy adapter to database.yml
  def add_legacy_adapter
    say_status("appending", "legacy adapter", :blue)
  end

  # 2) Add legacy base class
  def add_legacy_base_class
    say_status("adding", "legacy base class", :red)
    # TODO: mkdir, unless exists, app/models/legacy (DRY)
    copy_file "legacy_base.rb", "app/models/legacy/legacy_base.erb"
  end

  # 3) Add legacy subclasses for all existing models
  def add_legacy_subclasses
    say_status("adding", "legacy subclasses", :green)
  end

  # 4) Add app/models/legacy to Rails load path
  def update_load_path
    say_status("updating", "load path", :red)
    # TODO: mkdir, unless exists, app/models/legacy (DRY)
  end

  # 5) Generate sample migration (using pluralized model names)
  def sample_migration
    say_status("adding", "sample migration", :green)
  end
end

