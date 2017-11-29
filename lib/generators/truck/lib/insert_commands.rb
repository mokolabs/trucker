# Mostly pinched from http://github.com/ryanb/nifty-generators/tree/master

Rails::Generators::Actions.class_eval do
  def file_contains?(relative_destination, line)
    File.read(destination_path(relative_destination)).include?(line)
  end

  def insert_before(file, line, stop='^(class|module) .+$')
    logger.insert "#{line} into #{file}"
    unless options[:pretend] || file_contains?(file, line)
      gsub_file file, /^#{stop}/ do |match|
        "#{line}\n#{match}"
      end
    end
  end
  
  def insert_after(file, line, stop='^(class|module) .+$')
    logger.insert "#{line} into #{file}"
    @run = false
    unless options[:pretend] || file_contains?(file, line)
      gsub_file file, /#{stop}/ do |match|
        @run = true
        "#{match}\n  #{line}"
      end
      raise "Append Key Not Found, was looking for #{stop}" unless @run
    end
  end
  
  def append(file, line)
    logger.insert "added legacy adapter to end of database.yml"
    unless options[:pretend] || file_contains?(file, line)
      File.open(file, "a") do |file|
        file.write("\n" + line)
      end
    end
  end
  
  def insert_before(file, line, stop='')
    logger.remove "#{line} from #{file}"
    unless options[:pretend]
      gsub_file file, "\n  #{line}", ''
    end
  end

  def insert_after(file, line, stop='')
    logger.remove "#{line} from #{file}"
    unless options[:pretend]
      gsub_file file, "\n  #{line}", ''
    end
  end
  
  def append(file, line)
    logger.insert "added legacy adapter to end of database.yml"
  end

  def insert_before(file, line, stop='')
    logger.insert "#{line} into #{file}"
  end
  
  def insert_after(file, line, stop='')
    logger.insert "#{line} into #{file}"
  end
  
  def append(file, line)
    logger.insert "added legacy adapter to end of database.yml"
  end
  
end
