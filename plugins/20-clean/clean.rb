#!/usr/bin/env ruby

# tgtdir=... conf=... [dryrun=1] clean.rb

# where conf="ago1:window1 ago2:window2 ... agoN:windowN"

# Let tgtdir contains items (files or dirs) which names looks like date
# Delete those items who match:
#   itemdate < ago_i
#   && 
#   there exist item during window_i period before that item.

# window valid values: -1..32, where
# -1=delete
# 0=keep all copies
# 1=keep one item during day,
# 7=keep one item during week
# 32=keep one item in a month

# example conf="0:1 30:7 180:30 365:-1"
# which means after 0 days, keep 1 item for each day; after 30 days, keep 1 copy of 7 days, after 180 days, keep 1 copy of 30 days, after 365, delete all"

puts "xclean operation started"

require 'date'

targetdir = ENV["tgtdir"] || raise("tgtdir param not specified")
targetdir = File.expand_path(targetdir)
conf = ENV["conf"] || raise("conf params not specified")

conf_parsed = conf.split(/\s+/).map { |s|
  if ! s =~ /\A\d+:\d+\z/
    raise "conf does not match to our regexp!"
  end
  s.split(":").map(&:to_i)
}

date = Date.today
m = date.month

puts "tgtdir=#{targetdir}"
puts "parsed conf=#{conf_parsed.inspect}"
#puts "current month=#{m}"

hash = {}

dryrun = (!!ENV["dryrun"])
#puts "DRYRUN=#{dryrun}"

if dryrun
  def dodelete(dir)
    raise "very short cmd -- strange!" if dir.length < 10
    cmd = "rm -rf #{dir}"
    puts "#dryrun, cmd=#{cmd}"
    puts
 end
else
  def dodelete(dir)
    raise "very short cmd -- strange!" if dir.length < 10
    cmd = "rm -rf #{dir}"
    puts cmd
    puts
    system cmd
  end
end

Dir[ targetdir + "/*" ].sort.each do |d|
  puts "see file system item #{d}"
    
  dn = File.basename(d)
    
  if d.length < 30
    puts "item length too small -- skipping"
    next
  end
  if dn.length < 15
    puts "basename too small -- skipping"
    next
  end
  begin
    td = Date.parse dn
  rescue
    puts "cannot parse date from #{dn} -- skipping"
    next
  end

  
  diff = (date - td).to_i
  
  conf_parsed.each_with_index do |rec,index|
  
    ago = rec[0]
    window = rec[1]

    if diff < ago
      #puts "less than #{ago} days ago -- skipping"
      next
    end
    
    if window == -1
      puts "window = -1, deleting"
      dodelete(d)
      break
    end
    
    if window == 0
      puts "window = 0, skipping"
      break
    end
    
#  q = ((td.yday-1) / window).to_i
#  key = td.year.to_s + "~" + q.to_s
# в варианте выше мы делим год на window-интервалы в днях
# но непонятно, если там например 30 указать, что будет?
# вероятно, надо отдельно мониторить вещи типа 1m, 3m, 1w и т.п.
  q = ((td.day-1) / window).to_i
  key = td.year.to_s + "-" + td.month.to_s + "/" + q.to_s
  puts "key=#{key}"
  hash[index] ||= {}

  if hash[index][key] # busy => delete
    dodelete( d )
  else
    hash[index][key] = true
    puts "KEEP"
    puts
  end
  
  end  # for conf
  
end # for files

puts "xclean operation finished"