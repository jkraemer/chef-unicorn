maintainer       "Jens Kraemer"
maintainer_email "jk@jkraemer.net"
license          "MIT"
description      "Installs/Configures unicorn"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.1.0"

depends 'nginx'
recipe "unicorn", "Installs and configures unicorn"

%w{ ubuntu debian }.each do |os|
  supports os
end
