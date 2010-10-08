%define jruby_version 1.8
%define steamcannon_version be8c0b1
# %define torquebox_version 1.0.0.Beta22

Summary:        SteamCannon Rails App
Name:           steamcannon
Version:        %{steamcannon_version}
Release:        1%{?dist}
License:        LGPL
BuildRequires:       libxml2 libxml2-devel libxslt libxslt-devel
BuildArch:      noarch
Group:          Applications/System
Source0:        http://github.com/%{name}/%{name}/tarball/%{steamcannon_version}
# Source1:        http://repository.torquebox.org/maven2/releases/org/torquebox/torquebox-dist/1.0.0.Beta22/torquebox-dist-%{torquebox_version}-bin.zip
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
SteamCannon Rails App for shooting your apps to the clouds

%prep
%setup -T -b 0 -n %{name}-%{name}-%{steamcannon_version}
# %setup -T -b 1 -n torquebox-%{torquebox_version}

%install
rm -Rf $RPM_BUILD_ROOT

cd %{_topdir}/BUILD
install -d -m 755 $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version}/gems

cp -R %{name}-%{name}-%{steamcannon_version} $RPM_BUILD_ROOT/opt/steamcannon

# install required gems 
gem fetch authlogic -v 2.1.5
gem fetch aws s3 haml compass
gem fetch bbrowning-deltacloud-client -v 0.0.9.7 --source http://rubygems.org
gem fetch paperclip -v 2.3.3
gem fetch simple-navigation -v 2.6.0
gem fetch aasm -v 2.1.5
gem fetch rest-client -v 1.6.0
gem fetch json -v 1.4.6

gem unpack *.gem
rm *.gem
cp -R * $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version}/gems


rm -Rf $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version}/cache

# %clean
# rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
/

%changelog
* Thu Oct 07 2010 Lance Ball %{steamcannon_version}
- Initial release


