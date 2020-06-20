module XRsyncBackup

  def process(h)
    if h["bucket"] && h["tgtdir"]
      stage "rsync backup"
      app=File.join(__dir__,"rsync-x-backup.sh" )
      r = run( { "src" => h["bucket"], "tgtdir" => h["tgtdir"], "rsync_options"=>h["rsync_options"] }, app )
      r && super
    else
      log "bucket or tgtdir columns not specified"
      false
    end
  end
  
end