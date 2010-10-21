%define jruby_version 1.8
%define steamcannon_version 19253c7
%define jruby_path $RPM_BUILD_ROOT/opt/jruby
%define jruby_gems %{jruby_path}/lib/ruby/gems/%{jruby_version}
%define jruby_cmd /opt/jruby/bin/jruby

# Don't complain about arch-specific packages in noarch build
%global _binaries_in_noarch_packages_terminate_build 0

Summary:        SteamCannon Rails App
Name:           steamcannon
Version:        %{steamcannon_version}
Release:        1%{?dist}
License:        LGPL
Requires:       torquebox-deployers
BuildRequires:       libxml2 libxml2-devel libxslt libxslt-devel torquebox-jruby
BuildArch:      noarch
Group:          Applications/System
Source0:        http://github.com/steamcannon/steamcannon/tarball/%{steamcannon_version}
BuildRoot:      %{_tmppath}/steamcannon-%{version}-%{release}-root-%(%{__id_u} -n)
Requires:       steamcannon-dependencies = %{steamcannon_version}

%description
SteamCannon Rails App for shooting your apps to the clouds

%prep
%setup -T -b 0 -n steamcannon-steamcannon-%{steamcannon_version}

%install
rm -Rf $RPM_BUILD_ROOT

cd %{_topdir}/BUILD
install -d -m 755 $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version}/gems

cp -R steamcannon-steamcannon-%{steamcannon_version} $RPM_BUILD_ROOT/opt/steamcannon
rm $RPM_BUILD_ROOT/opt/steamcannon/Gemfile.lock

rm -Rf $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version}/cache
touch $RPM_BUILD_ROOT/opt/steamcannon/log/production.log

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,jboss-as6,jboss-as6)
/

%changelog
* Thu Oct 07 2010 Lance Ball %{steamcannon_version}
- Initial release


