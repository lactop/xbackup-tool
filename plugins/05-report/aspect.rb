module XReport

  attr_accessor :report

  def go
    self.report=[]
    super
    stage "report"
    count=0
    errcount=0
    log "operations performed: #{self.report.length}"
    for k in self.report do
      log "#{k}"
      if k =~ /^ERROR/
        errcount=errcount+1  
      else
        count=count+1
      end
    end
    
    log "success count: #{count}"
    log "error count: #{errcount}"
  end

  def process(h)
    if super
      self.report.push "#{h['bucket']} -> #{h['host']}:#{h['tgtdir']}"
      true
    else
      #log "REPORT: false"
      self.report.push "ERROR #{h['bucket']} -> #{h['host']}:#{h['tgtdir']}"
      false
    end
  end
  
end
