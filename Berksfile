source "https://api.berkshelf.com"

cookbook "apt", "~> 2.4.0"
cookbook 'build-essential', '>= 1.4.0'
cookbook "cmake", "~> 0.3"
cookbook "gflags", "~> 1.0"
cookbook "git", "~> 4.0.2"
cookbook "hadoop", "~> 1.12.0"
cookbook "java", "~> 1.22"
cookbook "minitest-handler", '~> 1.2.0'
cookbook "python", "~> 1.4.6"
cookbook 'ark', '~> 0.9.0'
cookbook 'maven', '~> 1.2.0'
cookbook 'filesystem', '~> 0.9.0'
cookbook 'hostsfile', '= 2.4.5'
cookbook 'awscli', '~> 1.0.1'

# These opencv depdencies need to be pulled into the repo because there is a 
# bug in chef that creates and notifies don't work well together. 
# See https://tickets.opscode.com/browse/CHEF-3740
cookbook "yasm", path: "yasm"
cookbook "ffmpeg", path: "ffmpeg"
cookbook "x264", path: "x264"
cookbook "libvpx", path: "libvpx"
cookbook "redis", path: "redis"
cookbook "s3cmd", path: "s3cmd"

cookbook "neon", path: "neon"
cookbook "neonisp", path: "neonisp"
cookbook "neon_logs", path: "neon_logs"
cookbook "mastermind", path: "mastermind"
cookbook "stats_manager", path: "stats_manager"
cookbook "trackserver", path: "trackserver"
cookbook "cmsdb", path: "cmsdb"
cookbook "neon-nginx", path: "neon-nginx"
cookbook "neon-opencv", path: "neon-opencv"
