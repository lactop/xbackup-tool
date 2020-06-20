require "date"

module XDayOfWeekFilter

  def is_allowed?(h)
    return super if ! h.has_key?("dayofweek")
    return super if self.force
    
    days = getdays( h["dayofweek"] )

    today=Date.today.cwday
    log "DAYS=#{days}, today=#{today}"
    if days.include?(today) 
      log "day match"
      super
    else
      false
    end
  end

  def getdays(str)
    return [1,2,3,4,5,6,7] if str == "*"
    days=[]
    
    str = str.gsub /(\d)\s*-\s*(\d)/ do |m|
      a1 = $1.to_i
      a2 = $2.to_i
      if a1 <= a2
        for i in a1 .. a2
          days.push(i)
        end
      end
      ""
    end

    str.match( /\d/ ) do |m|
      days.push m[0].to_i
    end
    days.push(7) if days.include?(0) #compat with cron
    days
  end
  
end