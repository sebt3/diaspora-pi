#!/bin/bash

hoSt=${1:-"pi"}

fail() {
	r=$?
	echo $@
	exit $r
}

Stack=diaspora
Svc=postgres
getCont() {
	ssh "$hoSt" sudo docker stack ps ${Stack} -f name=${Stack}_${Svc}.1 --no-trunc|awk -v N=${Stack}_${Svc}.1 '$2==N{print $1}'
}
getVolumePath() {
	ssh "$hoSt" sudo docker volume inspect diaspora_database --format '{{.Mountpoint}}'
}
sql() {
	ssh "$hoSt" sudo docker exec -i ${Stack}_${Svc}.1.$Cont su - postgres -c "'psql -U diaspora -d diaspora_production -t'"|sed '/^$/d'
}

echo "Get container ID"
Cont=$(getCont)

echo "Remove the extention from the database"
echo "DROP EXTENSION pg_stat_statements"|sql

echo "Get postgres volume path"
voL=$(getVolumePath)

echo "Disable pg_stat_statements in postgresql.conf"
ssh "$hoSt" sudo sed -i '/pg_stat_statements/d' "$voL/postgresql.conf"

echo "Restarting postgres container"
ssh "$hoSt" sudo docker restart ${Stack}_${Svc}.1.$Cont

