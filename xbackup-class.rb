class XBackup

  attr_accessor :files
  attr_accessor :force

  def initialize(files,options)
    log "new: files=#{files}"
    self.files=files
    self.force = options["force"]
  end
  
  def go
    for f in self.files do
      process_1_csv( f )
    end
  end
  
  def process_1_csv(csv_file_path)
    f=File.readlines( csv_file_path )
          .map{ |line| line.chomp }
          .delete_if{ |line| line =~ /^\s*(\#|$)/ }
          # thus we deleted all #-comment lines and all blank lines
    columns = f.shift.split( /[, ]+/ )
    for line in f do
      data = line.split( /,/ ).map{ |line| line.strip }
      process_operation( columns, data )
    end
  end
  
  def process_operation( columns, data )
      
      h = {}
      columns.each_with_index { |col,index| 
        h[col] = data[index]
      }
      stage "process_operation"
      log "process_operation: h=#{h.inspect}"
      
      if is_allowed?(h)
        log "operation allowed"
        process(h)
      else
        log "operation not allowed"
      end
  end
  
  def is_allowed?(h)
    true
  end
  
  def process( h )
    true
  end
  
  def run(env,cmd)
    system(env,cmd)
  end
  
  def stage(str)
    log "=================== #{str} ===================="
  end
  
  def log( str )
    puts str
  end

end

Dir[ File.join( __dir__, "plugins","*","aspect.rb" ) ].sort.reverse.each do |f|
  require_relative f
  
  File.basename( File.dirname(f) ) =~ /^\d+-(.+)$/
  aspect_name = "X" + $1.split('-').collect(&:capitalize).join
  # log "see aspect #{aspect_name}"
  aspect = Kernel.const_get( aspect_name )
  
  XBackup.prepend aspect
end
