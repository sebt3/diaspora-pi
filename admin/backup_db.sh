#!/bin/bash

hoSt=${1:-"pi"}
isFull=${2:-"no"}

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
stamp() { date '+%Y%m%d_%H%M%S'; }
sql() {
	ssh "$hoSt" sudo docker exec -i ${Stack}_${Svc}.1.$Cont su - postgres -c "'psql -U diaspora -d diaspora_production -t'"|sed '/^$/d'
}

if [ "$isFull" != "no" ];then

	echo "Stop the containers"
	ssh "$hoSt" sudo docker service scale diaspora_postgres=0 diaspora_diaspora=0 diaspora_nginx=0

	echo "Get the postgres volume path"
	voL=$(getVolumePath)

	echo "Backing up the database volume"
	ssh "$hoSt" sudo tar -C "$voL" -cz . >backup_full_$(stamp).tar.gz

	echo "Start the database"
	ssh "$hoSt" sudo docker service scale diaspora_postgres=1
	echo "Start Diaspora*"
	ssh "$hoSt" sudo docker service scale diaspora_diaspora=1 diaspora_nginx=1
else
	echo "Get container ID"
	Cont=$(getCont)

	echo "Backing up the database volume"
	ssh "$hoSt" sudo docker exec -i ${Stack}_${Svc}.1.$Cont su - postgres -c "'pg_dump -U diaspora -d diaspora_production'" >backup_$(stamp).sql
fi
