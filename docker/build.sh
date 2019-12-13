#!/bin/bash

sep() {
	local c=$(( ( 80 - $(echo "%s" "$*"|wc -c) )/2 ));
	local s=$(awk -v m=$c 'BEGIN{for(c=0;c<m;c++) printf "=";}');
	echo "$s $* $s";
}

set -e
useradd -m diaspora
sep Install build dependencies
apt-get update
apt-get install -y git build-essential cmake libssl-dev libcurl4-openssl-dev libxml2-dev libxslt-dev libmagickwand-dev libpq-dev imagemagick ghostscript curl nodejs
sep Cloning diaspora sources
su - diaspora -c "git clone -b v$(sed 's/,.*//' /tmp/.tags) https://github.com/diaspora/diaspora.git"
rm -rf /home/diaspora/diaspora/.git
chown -R diaspora:diaspora /home/diaspora/diaspora /usr/local/lib/ruby/gems /usr/local/bin
echo "tar czf source.tar.gz diaspora"|su - diaspora
cd /home/diaspora/diaspora
mv ../source.tar.gz ./public/
cp config/diaspora.yml.example config/diaspora.yml
cp config/database.yml.example config/database.yml
sep Install ruby bundler
gem install bundler pg
echo "cd ~/diaspora; script/configure_bundler"|su - diaspora
N=0
sep Build and install ruby dependencies
set +e
while [ $N -lt 10 ];do
	RAILS_ENV=production DB=postgres bundle install --without test development --with postgresql && break
	((N++))
done
set -e
sep Prepare /target
mv /home/diaspora/diaspora/public /home/diaspora/diaspora/pub
mkdir -p /target/usr/local/lib/ruby/gems /target/home/diaspora/ /target/usr/local/bin /target/usr/local/bundle /target/bin /target/tmp
cp -Rapf /usr/local/bin/* /target/usr/local/bin
cp -Rapf /usr/local/bundle/* /target/usr/local/bundle
cp -Rapf /home/diaspora/diaspora /target/home/diaspora/
cp -Rapf /usr/local/lib/ruby/gems/* /target/usr/local/lib/ruby/gems
cp -apf  /bin/entrypoint.sh /target/bin
chown -R root:root /target/usr/
chmod 755 /target/bin/entrypoint.sh
sed 's/,.*//' /tmp/.tags >/target/diaspora_version

