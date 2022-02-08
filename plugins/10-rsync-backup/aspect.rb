module XRsyncBackup

  def process(h)
    if h["bucket"] && h["tgtdir"]
      stage "rsync backup"
      app=File.join(__dir__,"rsync-x-backup.sh" )
      r = run( { "src" => h["bucket"], "tgtdir" => h["tgtdir"], "rsync_options"=>h["rsync_options"] }, app )
      log "rsync-x-backup.sh returned code #{r}"
      if r
         log "going to next level"
         super
      else
         log "skipping next level"
         r
      end
      #r && super
    else
      log "bucket or tgtdir columns not specified, skipping rsync stage"
      super
    end
  end
  
end