module XClean

  def process(h)
    log "entering xclean level. h=#{h}"
    if h["clean"] && h["tgtdir"]
      stage "clean"
      app=File.join(__dir__,"clean.rb" )
      r = run( { "conf" => h["clean"], "tgtdir" => h["tgtdir"] }, app )
      r && super
    else
      log "no important keys, skipping and going to next level"
      super
    end
  end
  
end