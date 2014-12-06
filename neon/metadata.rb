name             'neon'
maintainer       'Neon'
maintainer_email 'ops@neon-lab.com'
description      'Installs neon services'
license          'Proprietary - All Rights Reserved'
version          '0.9.0'

depends 'apt'
depends 'gflags', '~> 1.0'
depends 'git'
depends 'java'
depends 'neon_logs'
depends 'neon-opencv'
depends 'python', "= 1.4.6"
depends 'filesystem'

supports 'ubuntu'
