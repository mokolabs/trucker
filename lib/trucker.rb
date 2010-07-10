module Trucker

  def self.migrate(name, options={})
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

  protected

    def self.with(options={})
      {:limit => number_of_records, :offset => offset_for_records}.merge(options)
    end

    def self.number_of_records
      nil || ENV['limit'].to_i if ENV['limit'].to_i > 0
    end

    def self.offset_for_records
      nil || ENV['offset'].to_i if ENV['offset'].to_i > 0
    end
  
end