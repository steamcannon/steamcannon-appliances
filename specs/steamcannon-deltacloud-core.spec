%define jruby_version 1.8
%define deltacloud_version 0.0.7.2
%define gemname steamcannon-deltacloud-core
%define gemdir /opt/jruby/lib/ruby/gems/%{jruby_version}
%define geminstdir %{gemdir}/gems/%{gemname}-%{deltacloud_version}
%define gemcommand /opt/jruby/bin/jruby -S gem

Summary: Deltacloud REST API
Name: %{gemname}-deployment
Version: %{deltacloud_version}
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
URL: http://www.deltacloud.org
Source0: http://rubygems.org/gems/%{gemname}-%{deltacloud_version}.gem
BuildRoot: %{_tmppath}/%{name}-%{deltacloud_version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: rubygems
BuildArch: noarch
Provides: rubygem(%{gemname}) = %{deltacloud_version}
Requires: torquebox-deployers

%description
The Deltacloud API is built as a service-based REST API.
You do not directly link a Deltacloud library into your program to use it.
Instead, a client speaks the Deltacloud API over HTTP to a server
which implements the REST interface.


%prep

%build

%install
rm -Rf $RPM_BUILD_ROOT

cd %{_topdir}/BUILD
install -d -m 755 %{buildroot}%{gemdir}/gems
install -d -m 755 %{buildroot}/opt/jboss-as/server/default/deploy

# TODO - Need sinatra dependency

# install required gems 
%{gemcommand} install --install-dir=%{buildroot}%{gemdir} --ignore-dependencies --force --no-ri --no-rdoc %{gemname} -v %{deltacloud_version}
%{gemcommand} install --install-dir=%{buildroot}%{gemdir} --ignore-dependencies --force --no-ri --no-rdoc sinatra -v 1.0
%{gemcommand} install --install-dir=%{buildroot}%{gemdir} --ignore-dependencies --force --no-ri --no-rdoc eventmachine -v 0.12.10
%{gemcommand} install --install-dir=%{buildroot}%{gemdir} --ignore-dependencies --force --no-ri --no-rdoc rack-accept -v 0.4.3
%{gemcommand} install --install-dir=%{buildroot}%{gemdir} --ignore-dependencies --force --no-ri --no-rdoc amazon-ec2 -v 0.9.15

# Write deltacloud-rack.yml file 
printf "application:\n    RACK_ROOT: %{geminstdir}-java\n    RACK_ENV: production\nweb:\\n    context: /deltacloud\nenvironment:\n    API_DRIVER: ec2" > %{buildroot}/opt/jboss-as/server/default/deploy/deltacloud-rack.yml

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
%{gemdir}/bin/deltacloudd
%{gemdir}/gems/%{gemname}-%{deltacloud_version}-java/
%{gemdir}/cache/%{gemname}-%{deltacloud_version}-java.gem
%{gemdir}/specifications/%{gemname}-%{deltacloud_version}-java.gemspec
/opt/jboss-as/server/default/deploy/deltacloud-rack.yml

%{gemdir}/gems/sinatra-1.0/
%{gemdir}/cache/sinatra-1.0.gem
%{gemdir}/specifications/sinatra-1.0.gemspec

%{gemdir}/gems/eventmachine-0.12.10-java/
%{gemdir}/cache/eventmachine-0.12.10-java.gem
%{gemdir}/specifications/eventmachine-0.12.10-java.gemspec

%{gemdir}/gems/amazon-ec2-0.9.15/
%{gemdir}/cache/amazon-ec2-0.9.15.gem
%{gemdir}/specifications/amazon-ec2-0.9.15.gemspec

%{gemdir}/gems/rack-accept-0.4.3/
%{gemdir}/cache/rack-accept-0.4.3.gem
%{gemdir}/specifications/rack-accept-0.4.3.gemspec

%{gemdir}/bin/ec2-gem-example.rb
%{gemdir}/bin/ec2-gem-profile.rb
%{gemdir}/bin/ec2sh
%{gemdir}/bin/setup.rb

%changelog
* Mon Oct 11 2010  <builder@localhost.localdomain> - 0.0.7.1-1
- Initial package
