%define jruby_version 1.8
%define steamcannon_version 9eca839
%define jruby_path $RPM_BUILD_ROOT/opt/jruby
%define jruby_gems %{jruby_path}/lib/ruby/gems/%{jruby_version}
%define jruby_cmd /opt/jruby/bin/jruby

# Don't complain about arch-specific packages in noarch build
%global _binaries_in_noarch_packages_terminate_build 0

Summary:        SteamCannon Rails App
Name:           steamcannon-ui
Version:        %{steamcannon_version}
Release:        1%{?dist}
License:        LGPL
Requires:       torquebox-deployers
BuildRequires:       libxml2 libxml2-devel libxslt libxslt-devel torquebox-jruby
BuildArch:      noarch
Group:          Applications/System
Source0:        http://github.com/steamcannon/steamcannon/tarball/%{steamcannon_version}
BuildRoot:      %{_tmppath}/steamcannon-%{version}-%{release}-root-%(%{__id_u} -n)

%description
SteamCannon Rails App for shooting your apps to the clouds

%prep
%setup -T -b 0 -n steamcannon-steamcannon-%{steamcannon_version}

%install
rm -Rf $RPM_BUILD_ROOT

cd %{_topdir}/BUILD
install -d -m 755 $RPM_BUILD_ROOT/opt/jruby/lib/ruby/gems/%{jruby_version}/gems

cp -R steamcannon-steamcannon-%{steamcannon_version} $RPM_BUILD_ROOT/opt/steamcannon

# install required gems 
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java authlogic -v 2.1.5
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java aws  -v 2.3.21
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java s3 -v 0.3.4
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java haml -v 3.0.15
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java compass -v 0.10.5
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java compass-960-plugin -v 0.10.0
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java maruku -v 0.6.0
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java steamcannon-deltacloud-client -v 0.0.9.7.2 --source http://rubygems.org
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java paperclip -v 2.3.3
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java simple-navigation -v 2.6.0
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java aasm -v 2.1.5
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java rest-client -v 1.6.1
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java json -v 1.4.6
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java nokogiri -v 1.5.0.beta.2
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java bouncy-castle-java -v 1.5.0145.2
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java jruby-openssl -v 0.7.1
%{jruby_cmd} -S gem install --install-dir=%{jruby_gems} --force --ignore-dependencies --no-ri --no-rdoc --platform java http_connection proxies uuidtools xml-simple


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


