# Package
version       = "0.1.0"
author        = "Jonathan Van Eenwyk"
description   = "For language learning, shuffle silence-separated audio segments to create more challenging recordings"
license       = "MIT"
binDir        = "bin"
srcDir        = "src"
bin           = @["shuffle_recording"]

# Dependencies
requires "nim >= 0.20.2", "cligen >= 0.9.38", "tempfile >= 0.1.7"

