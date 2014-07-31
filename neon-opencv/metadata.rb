name             'neon-opencv'
maintainer       'Neon Labs Inc.'
maintainer_email 'ops@neon-lab.com'
license          'Proprietary - All rights reserved'
description      'Installs/Configures OpenCV'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends 'apt'
depends 'build-essential'
depends 'ffmpeg', "~> 0.3"
depends 'yasm', "~> 1.0"

supports 'ubuntu'
