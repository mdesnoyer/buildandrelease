name             'neon'
maintainer       'Neon'
maintainer_email 'ops@neon-lab.com'
description      'Installs neon services'
license          'Proprietary - All Rights Reserved'
version          '0.9.0'

depends 'apt'
depends 'java'
depends 'neon_logs'
depends 'nginx', "= 2.6.2"
depends 'python', "= 1.4.6"

supports 'ubuntu'
