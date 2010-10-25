%define jruby_version 1.8
%define steamcannon_version 4f46541
%define deltacloud_version 0.0.8.1

# Don't complain about arch-specific packages in noarch build
%global _binaries_in_noarch_packages_terminate_build 0

Summary:        SteamCannon Rails App
Name:           steamcannon
Version:        %{steamcannon_version}
Release:        1%{?dist}
License:        LGPL

BuildArch:      noarch
Group:          Applications/System
BuildRequires:  libxml2 libxml2-devel libxslt libxslt-devel 
BuildRoot:      %{_tmppath}/steamcannon-%{version}-%{release}-root-%(%{__id_u} -n)
Source0:        http://github.com/steamcannon/steamcannon/tarball/%{steamcannon_version}


Requires:       torquebox-deployers
Requires:       steamcannon-dependencies = %{steamcannon_version}
Requires:       steamcannon-deltacloud-core-deployment = %{deltacloud_version}

%description
SteamCannon Rails App for shooting your apps to the clouds

%prep
%setup -T -b 0 -n steamcannon-steamcannon-%{steamcannon_version}

%install
rm -Rf $RPM_BUILD_ROOT

cd %{_topdir}/BUILD

install -d -m 755 $RPM_BUILD_ROOT/opt
cp -R steamcannon-steamcannon-%{steamcannon_version} $RPM_BUILD_ROOT/opt/steamcannon

mkdir $RPM_BUILD_ROOT/opt/steamcannon/log
touch $RPM_BUILD_ROOT/opt/steamcannon/log/production.log

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,jboss-as6,jboss-as6)
/

%changelog
* Thu Oct 07 2010 Lance Ball %{steamcannon_version}
- Initial release


