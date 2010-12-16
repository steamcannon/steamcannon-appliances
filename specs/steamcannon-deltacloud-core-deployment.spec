%define jruby_version 1.8
%define deltacloud_version 0.1.1.3
%define gemname steamcannon-deltacloud-core
%define gemdir /opt/jruby/lib/ruby/gems/%{jruby_version}
%define geminstdir %{gemdir}/gems/%{gemname}-%{deltacloud_version}

Summary: Deltacloud REST API
Name: %{gemname}-deployment
Version: %{deltacloud_version}
Release: 1%{?dist}
Group: Development/Languages
License: GPLv2+ or Ruby
URL: http://www.deltacloud.org
BuildRequires: rubygems
BuildArch: noarch
Requires: torquebox-rubygem(%{gemname}) = %{deltacloud_version}
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
install -d -m 755 %{buildroot}/opt/jboss-as/server/all/deploy

# Write deltacloud-rack.yml file 
echo "application:"                         >> %{buildroot}/opt/jboss-as/server/all/deploy/deltacloud-rack.yml
echo "    RACK_ROOT: %{geminstdir}-java"    >> %{buildroot}/opt/jboss-as/server/all/deploy/deltacloud-rack.yml
echo "    RACK_ENV: production"             >> %{buildroot}/opt/jboss-as/server/all/deploy/deltacloud-rack.yml
echo "web:"                                 >> %{buildroot}/opt/jboss-as/server/all/deploy/deltacloud-rack.yml
echo "    context: /deltacloud"             >> %{buildroot}/opt/jboss-as/server/all/deploy/deltacloud-rack.yml
echo "environment:"                         >> %{buildroot}/opt/jboss-as/server/all/deploy/deltacloud-rack.yml
echo "    API_DRIVER: ec2"                  >> %{buildroot}/opt/jboss-as/server/all/deploy/deltacloud-rack.yml

%clean
rm -rf %{buildroot}

%files
%defattr(-, root, root, -)
/opt/jboss-as/server/all/deploy/deltacloud-rack.yml

%changelog
* Thu Dec 16 2010 Ben Browning
- Upgrade steamcannon-deltacloud-core to 0.1.1.3

* Mon Oct 11 2010  <builder@localhost.localdomain> - 0.0.7.1-1
- Initial package
