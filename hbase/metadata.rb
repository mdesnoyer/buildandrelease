name             'hbase'
maintainer       'Neon Labs'
maintainer_email 'ops@neon-lab.com'
description      'Installs Hbase server'
license          'Proprietary - All Rights Reserved'
version          '0.9.0'

depends 'apt'
depends 'hadoop', "= 1.12.0"
depends 'java'
depends 'hostsfile'
depends 'python', "= 1.4.6"

supports 'ubuntu'
