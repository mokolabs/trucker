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
      status += "#{limit || "all"} #{label || name}"
      status += " after #{offset}" if offset
  
      # Set import counter
      counter = 0
      counter += offset.to_i if offset
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

  # FIXME: this looks like a pretty coherent argument for a Model class
  def self.base(model)
    # this might look baffling, so check the specs. String#titlecase is badly named (in
    # my opinion) because in addition to title-casing, it also arrogantly adds a space
    "Legacy#{model.singularize.titlecase.split(" ").join}"
  end

  def self.construct_query(model)
    if ENV['limit'] or ENV['offset'] or ENV['where']
      complete = base(model) + "#{where}#{limit}#{offset}"
    else
      complete = base(model) + ".all"
    end
    complete
  end

  def self.batch(method)
    nil || ".#{method}(#{ENV[method]})" unless ENV[method].blank?
  end

  def self.where
    batch("where")
  end

  def self.limit
    batch("limit")
  end

  def self.offset
    batch("offset")
  end
  
end

