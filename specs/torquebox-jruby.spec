%define torquebox_build_number 795
%define torquebox_version 1.0.0.Beta23-SNAPSHOT
%define torquebox_rpm_version 1.0.0.Beta23.SNAPSHOT

%global _binaries_in_noarch_packages_terminate_build 0

Summary:        TorqueBox JRuby
Name:           torquebox-jruby
Version:        %{torquebox_rpm_version}
Release:        1
License:        LGPL
BuildArch:      noarch
Group:          Applications/System
#Source0:        http://repository.torquebox.org/maven2/releases/org/torquebox/torquebox-dist/1.0.0.Beta22/torquebox-dist-%{torquebox_version}-bin.zip
Source:         http://ci.stormgrind.org/repository/download/bt7/%{torquebox_build_number}:id/torquebox-dist-bin.zip?guest=1
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
The TorqueBox JRuby Distribution

%define __jar_repack %{nil}

%prep
%setup -T -b 0 -n torquebox-%{torquebox_version}

%install
rm -Rf $RPM_BUILD_ROOT

cd %{_topdir}/BUILD

install -d -m 755 $RPM_BUILD_ROOT/opt/

# copy jruby
cp -R torquebox-%{torquebox_version}/jruby $RPM_BUILD_ROOT/opt/
rm -Rf $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/1.8/cache

%clean
rm -Rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
/

%changelog
* Mon Oct 04 2010 Bob McWhirter 
- Initial release
