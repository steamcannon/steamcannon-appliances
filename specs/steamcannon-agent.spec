%define ruby_version 1.8
%define commit_hash 7526008

Summary:        SteamCannon Agent
Name:           steamcannon-agent
Version:        0.0.1
Release:        1%{?dist}
License:        LGPL
Requires:       shadow-utils
Requires:       ruby git
Requires:       initscripts
Requires:       rubygems
Requires:       rubygem-sinatra rubygem-json rubygem-open4 rubygem-rest-client
BuildRequires:  ruby-devel gcc-c++ rubygems sqlite-devel openssl-devel wget
Requires(post): /sbin/chkconfig
Group:          Development/Tools
Source0:        http://github.com/steamcannon/steamcannon-agent/tarball/%{version}
Source1:        %{name}.init
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

# Ugly hack for thin
Provides:       /usr/local/bin/ruby

%description
SteamCannon Agent

%prep
%setup %{SOURCE0} -n steamcannon-%{name}-%{commit_hash}

%install
rm -rf $RPM_BUILD_ROOT

install -d -m 755 $RPM_BUILD_ROOT%{_initrddir}
install -m 755 %{SOURCE0} $RPM_BUILD_ROOT%{_initrddir}/%{name}

install -d -m 755 $RPM_BUILD_ROOT/usr/lib/ruby/gems/%{ruby_version}

# TODO: once gems are pushed to fedora, add it to require
gem install --install-dir=$RPM_BUILD_ROOT/usr/lib/ruby/gems/%{ruby_version} --force --rdoc rack -v 1.2.0
gem install --install-dir=$RPM_BUILD_ROOT/usr/lib/ruby/gems/%{ruby_version} --force --rdoc gems/thin-1.2.8.gem
gem install --install-dir=$RPM_BUILD_ROOT/usr/lib/ruby/gems/%{ruby_version} --force --rdoc dm-core dm-sqlite-adapter dm-migrations dm-is-tree

install -d -m 755 $RPM_BUILD_ROOT/var/log/%{name}
install -d -m 755 $RPM_BUILD_ROOT/var/lock
touch $RPM_BUILD_ROOT/var/lock/%{name}.pid

%clean
rm -rf $RPM_BUILD_ROOT

%post
/sbin/chkconfig --add %{name}

%files
%defattr(-,root,root)
/

%changelog
* Wed Sep 08 2010 Marek Goldmann 0.0.1-1
- Initial release
