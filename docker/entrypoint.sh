#!/bin/bash

DB_HOST=${DB_HOST:-"postgres"}
DB_USERNAME=${DB_USERNAME:-"diaspora"}
DB_PASSWORD=${DB_PASSWORD:-"$DB_USERNAME"}
DB_PORT=${DB_PORT:-"5432"}
ENVIRONMENT_CERTIFICATE_AUTHORITIES='/etc/ssl/certs/ca-certificates.crt'
#ENVIRONMENT_URL="http://diaspora.example.com"
ENVIRONMENT_REDIS=${ENVIRONMENT_REDIS:-"redis://redis"}
PORT=${SERVER_PORT:-3000}
SERVER_LISTEN=${SERVER_LISTEN:-"0.0.0.0:$PORT"}


DHOME=/home/diaspora/diaspora

conf_db() {
#TODO add support for mysql
cat >$DHOME/config/database.yml <<ENDYAML
postgresql: &postgresql
  adapter: postgresql
  host: "$DB_HOST"
  port: $DB_PORT
  username: "$DB_USERNAME"
  password: "$DB_PASSWORD"
  encoding: unicode

mysql: &mysql
  adapter: mysql2
  host: "$DB_HOST"
  port: $DB_PORT
  username: "$DB_USERNAME"
  password: "$DB_PASSWORD"
  encoding: utf8mb4
  collation: utf8mb4_bin


# Comment the postgresql line and uncomment the mysql line
# if you want to use mysql
common: &common
  # Choose one of the following
  <<: *postgresql
  #<<: *mysql

  # Should match environment.sidekiq.concurrency
  #pool: 25

combined: &combined
  <<: *common
development:
  <<: *combined
  database: diaspora_development
production:
  <<: *combined
  database: diaspora_production
test:
  <<: *combined
  database: diaspora_test
integration1:
  <<: *combined
  database: diaspora_integration1
integration2:
  <<: *combined
  database: diaspora_integration2
ENDYAML
}

cd $DHOME
if [ $# -eq 0 ];then
	conf_db
	export RAILS_ENV=production
	x=$(set|egrep '^ENVIRONMENT|^SERVER|^CHAT|^MAP|^PRIVACY|^SETTINGS|^SERVICES|^MAIL|^ADMINS|^RELAY')
	y=$(echo $x)
	mkdir -p $DHOME/public
	chown diaspora:diaspora $DHOME/public
	cp -Rapf $DHOME/pub/* $DHOME/public
	echo "======================== Database update..."
	echo "cd ~/diaspora;$y bundle exec rake db:create db:migrate"|su diaspora
	if ! [ -f $DHOME/public/diaspora_version ] || ! cmp /diaspora_version $DHOME/public/diaspora_version >/dev/null;then
		echo "======================== Precompile assets..."
		echo "cd ~/diaspora;$y bin/rake assets:precompile;cat /diaspora_version>$DHOME/public/diaspora_version"|su diaspora
	fi
	echo "======================== Start Diaspora*..."
	echo "### $y ###"
	echo "cd ~/diaspora;$y ./script/server -p $PORT"|su diaspora
else
	exec "$@"
fi
