class Logger
  def self.log(obj, statement)
    puts "#{obj.class.name}: #{statement}"
  end
end