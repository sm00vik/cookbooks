maintainer       "YOUR_COMPANY_NAME"
maintainer_email "YOUR_EMAIL"
license          "All rights reserved"
description      "CPAN modules provider"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.38"
%w{ ubuntu gentoo }.each do |os|
  supports os
end

