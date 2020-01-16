#!/bin/bash


echo "Warning this script is dangerous !!!!"
echo "Remove the next line from it if you knowx what you're doing"
exit 1

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

echo "Stop the containers"
ssh "$hoSt" sudo docker service scale diaspora_postgres=0 diaspora_diaspora=0 diaspora_nginx=0

echo "Get the postgres volume path"
voL=$(getVolumePath)

echo "Running pg_resetwal"
ssh "$hoSt" sudo docker run -it --rm -v "$voL:/var/lib/postgresql/data" postgres:12-alpine su - postgres -c "'pg_resetwal /var/lib/postgresql/data'"

echo "Start the database"
ssh "$hoSt" sudo docker service scale diaspora_postgres=1
echo "Start Diaspora*"
ssh "$hoSt" sudo docker service scale diaspora_diaspora=1 diaspora_nginx=1

