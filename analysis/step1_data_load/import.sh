#!/bin/bash

fail() {
	r=$?
	echo $@
	exit $r
}
uRl=${1:-"https://shuss.freeboxos.fr"}
usEr=${2:-"seb"}
passWd=${3:-"password"}
hoSt=${4:-"pi"}

Base=http://localhost:9515/session
newSess() {
	curl -sLd '{ "desiredCapabilities": { "caps": { "nativeEvents": false, "browserName": "chrome", "version": "", "platform": "ANY" }}}'  $Base|jq --jsonargs '.sessionId'|sed 's/"//g'
}
delSess() {
	return $(curl -sL -X DELETE $Base/$Sess|jq --jsonargs '.status')
}
setUrl() {
	return $(curl -sLd '{"url":"'"$1"'"}' $Base/$Sess/url|jq --jsonargs '.status')
}
getElem() {
	curl -sLd '{"using":"'"${2:-"name"}"'","value":"'"$1"'"}' $Base/$Sess/element|jq --jsonargs '.value.ELEMENT'|sed 's/"//g'
}
getLastElem() {
	curl -sLd '{"using":"'"${2:-"name"}"'","value":"'"$1"'"}' $Base/$Sess/elements|jq --jsonargs '.value['"${3:-"-1"}"'].ELEMENT'|sed 's/"//g';
}
setElem() {
	return $(curl -sLd '{"value":["'"$2"'"]}' $Base/$Sess/element/$1/value|jq --jsonargs '.status')
}
clickElem() {
	return $(curl -sL -XPOST $Base/$Sess/element/$1/click|jq --jsonargs '.status')
}

Stack=diaspora
Svc=postgres
getCont() {
	ssh "$hoSt" sudo docker stack ps ${Stack} -f name=${Stack}_${Svc}.1 --no-trunc|awk -v N=${Stack}_${Svc}.1 '$2==N{print $1}'
}
sql() {
	ssh "$hoSt" sudo docker exec -i ${Stack}_${Svc}.1.$Cont su - postgres -c "'psql -U diaspora -d diaspora_production -t'"|sed '/^$/d'
}

echo Start
Sess=$(newSess)

echo Login
setUrl "$uRl"					|| fail "set url failed"
setElem   $(getElem "user[username]") "$usEr"	|| fail "set username failed"
setElem   $(getElem "user[password]") "$passWd"	|| fail "set password failed"
clickElem $(getElem "commit")			|| fail "Login submit failed"
sleep .2

echo "Get container ID"
Cont=$(getCont)

echo get Values
People=$(echo "select count(diaspora_handle) from people where id not in (select person_id from contacts);"|sql)

#Loop over database

for Did in $(echo 'select diaspora_handle from people where id not in (select person_id from contacts);'|ssh pi sudo docker exec -i ${Stack}_${Svc}.1.$Cont su - postgres -c "'psql -U diaspora -d diaspora_production -t'"|sed '/^$/d');do

#Handle adding one user
	echo "Follow $Did"
	setUrl "$uRl/people?q=$Did"
	clickElem $(getElem ".btn.dropdown-toggle.btn-default" "css selector")
	clickElem $(getLastElem "li.aspect_selector a" "css selector")
	sleep .2
done

echo Logout
delSess

