%define jruby_version 1.8
%define steamcannon_version 069d642

# Don't complain about arch-specific packages in noarch build
%global _binaries_in_noarch_packages_terminate_build 0

Summary:        SteamCannon Rails App
Name:           steamcannon
Version:        %{steamcannon_version}
Release:        1%{?dist}
License:        LGPL
Requires:       torquebox-cloud-profile-deployers
BuildRequires:       libxml2 libxml2-devel libxslt libxslt-devel
BuildArch:      noarch
Group:          Applications/System
Source0:        http://github.com/%{name}/%{name}/tarball/%{steamcannon_version}
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

%description
SteamCannon Rails App for shooting your apps to the clouds

%prep
%setup -T -b 0 -n %{name}-%{name}-%{steamcannon_version}

%install
rm -Rf $RPM_BUILD_ROOT

cd %{_topdir}/BUILD
install -d -m 755 $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version}/gems

cp -R %{name}-%{name}-%{steamcannon_version} $RPM_BUILD_ROOT/opt/steamcannon

# install required gems 
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java authlogic -v 2.1.5
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java aws s3 haml compass
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java steamcannon-deltacloud-client -v 0.0.9.7.2 --source http://rubygems.org
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java paperclip -v 2.3.3
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java simple-navigation -v 2.6.0
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java aasm -v 2.1.5
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java rest-client -v 1.6.1
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java json -v 1.4.6

# These gems are dependencies of those required above. 
gem install --install-dir=$RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version} --ignore-dependencies --force --no-ri --no-rdoc --platform java http_connection nokogiri proxies uuidtools xml-simple


rm -Rf $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version}/cache

%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root)
/

%changelog
* Thu Oct 07 2010 Lance Ball %{steamcannon_version}
- Initial release


