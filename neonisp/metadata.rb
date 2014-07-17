name             'neonisp'
maintainer       'Neon'
maintainer_email 'ops@neon-lab.com'
description      'The Neon image serving platform'
license          'Proprietary - All Rights Reserved'
version          '0.9.0'

depends 'apt'
depends 'neon'
depends 'neon_logs'
depends 'nginx', "= 2.6.2"
depends 'python', "= 1.4.6"

supports 'ubuntu'
