module Trucker

  def self.migrate(name, options={})
    # Grab custom entity label if present
    label = options.delete(:label) if options[:label]

    unless options[:helper]
  
      # Grab model to migrate
      model = name.to_s.classify
  
      # Wipe out existing records
      model.constantize.delete_all

      # Status message
      status = "Migrating "
      status += "#{number_of_records || "all"} #{label || name}"
      status += " after #{offset_for_records}" if offset_for_records
  
      # Set import counter
      counter = 0
      counter += offset_for_records.to_i if offset_for_records
      total_records = "Legacy#{model}".constantize.count
  
      # Start import
      query(model).each do |record|
        counter += 1
        puts status + " (#{counter}/#{total_records})"
        record.migrate
      end
    else
      eval options[:helper].to_s
    end
  end

  def self.query(model)
    eval construct_query(model)
  end

  def self.construct_query(model)
    base = "Legacy#{model.singularize.titlecase}"
    if ENV['limit'] or ENV['offset'] or ENV['where']
      complete = base + "#{where}#{number_of_records}#{offset_for_records}"
    else
      complete = base + ".all"
    end
    complete
  end

  def self.batch(method)
    nil || ".#{method}(#{ENV[method]})" unless ENV[method].blank?
  end

  def self.where
    batch("where")
  end

  def self.number_of_records
    batch("limit")
  end

  def self.offset_for_records
    batch("offset")
  end
  
end

