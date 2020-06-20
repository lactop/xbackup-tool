module XHostFilter

  attr_accessor :current_host

  def is_allowed?(h)
    return super if ! h.has_key?("host") 
    
    self.current_host ||= begin
      require 'socket'
      s=Socket.gethostname
      log "this computer hostname=#{s}"
      # `hostname -s`.strip
      s
    end

    if h["host"] == self.current_host
      log "host match"
      super
    else
      log "host do not match"
      false
    end
  end
  
end