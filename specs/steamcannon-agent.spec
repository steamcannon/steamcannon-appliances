%define ruby_version 1.8
%define steamcannon_agent_version 7acb3eb

Summary:        SteamCannon Agent
Name:           steamcannon-agent
Version:        0.0.1
Release:        1%{?dist}
License:        LGPL
Group:          Development/Tools

BuildRequires:  ruby-devel gcc-c++ rubygems git sqlite-devel openssl-devel
Source0:        %{name}.init
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)


Requires:       shadow-utils
Requires:       ruby git
Requires:       initscripts
Requires:       rubygems
Requires:       steamcannon-agent-dependencies = %{steamcannon_agent_version}
Requires(post): /sbin/chkconfig


# Ugly hack for thin
Provides:       /usr/local/bin/ruby

%description
SteamCannon Agent

%install
rm -rf $RPM_BUILD_ROOT

install -d -m 755 $RPM_BUILD_ROOT%{_initrddir}
install -m 755 %{SOURCE0} $RPM_BUILD_ROOT%{_initrddir}/%{name}

install -d -m 755 $RPM_BUILD_ROOT/usr/lib/ruby/gems/%{ruby_version}

/usr/bin/git clone git://github.com/steamcannon/steamcannon-agent.git $RPM_BUILD_ROOT/usr/share/%{name}
cd $RPM_BUILD_ROOT/usr/share/%{name}
/usr/bin/git checkout -b %{steamcannon_agent_version} %{steamcannon_agent_version}

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
