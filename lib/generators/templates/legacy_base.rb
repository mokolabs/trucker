class LegacyBase < ActiveRecord::Base
  self.abstract_class = true
  establish_connection "legacy"
  
  def migrate
    @new_record = self.class.to_s.gsub(/Legacy/,'::').constantize.new(map)
    @new_record[:id] = self.id
    begin
      @new_record.save!
    rescue Exception => e
      # this is mostly for ActiveRecord Validation errors - if the validation fails, it
      # typically means you need to adjust the validations or the model you're migrating
      # your legacy data into. this is especially useful information when you're migrating
      # user data established with one auth library to a code base which uses another.
      puts "error saving #{@new_record.class} #{@new_record.id}!"
      puts e.inspect
    end 
  end 

end
