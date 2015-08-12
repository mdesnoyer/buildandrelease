#
# Airflow - https://github.com/airbnb/airflow
#
name             'airflow'
maintainer       'Neon'
maintainer_email 'ops@neon-lab.com'
description      'Airflow for Neon Labs'
license          'Proprietary - All Rights Reserved'
version          '0.1.0'

depends 'apt'
depends 'neon'
depends 'neon_logs'
depends 'python', "= 1.4.6"

supports 'ubuntu'
