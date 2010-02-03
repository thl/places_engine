class FeaturePidGenerator
  # The plan is to get from the database the most recently created
  #  feature and pull in its pid.
  # The pid is comprised of two pars: '<char><digits>' The char part
  #  is always 'f'.  However the digits part is going to be a
  #  sequential number, starting at 1 and incrementing by 1.
  @@next_pid = 0
  
  def self.configure
    @@next_pid = Feature.maximum(:fid)
    puts "** FeaturePidGenerator, Current PID = #{@@next_pid}"
    current
  end
  
  def self.current
    @@next_pid
  end
  
  def self.current=(pid)
    @@next_pid = pid
  end
  
  def self.next
    self.configure if @@next_pid==0
    @@next_pid += 1
  end  
end
