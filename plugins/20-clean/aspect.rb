module XClean

  def process(h)
    if h["clean"] && h["dir"]
      stage "clean"
      app=File.join(__dir__,"clean.rb" )
      r = run( { "conf" => h["clean"], "tgtdir" => h["dir"] }, app )
      r && super
    else
      super
    end
  end
  
end