module XPostcmd

  def process(h)
    if h["postcmd"]
      stage "postcmd"
      app = h["postcmd"]
      r = run( h, app )
      # { "bucket" => h["bucket"], "tgtdir" => h["tgtdir"] }
      r && super
    else
      super
    end
  end
  
end