#!/bin/bash

fail() {
	r=$?
	echo $@
	exit $r
}
uRl=${1:-"https://shuss.freeboxos.fr"}
usEr=${2:-"seb"}
passWd=${3:-"password"}

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
	ssh pi sudo docker stack ps ${Stack} -f name=${Stack}_${Svc}.1 --no-trunc|awk -v N=${Stack}_${Svc}.1 '$2==N{print $1}'
}
sql() {
	ssh pi sudo docker exec -i ${Stack}_${Svc}.1.$Cont su - postgres -c "'psql -U diaspora -d diaspora_production -t'"|sed '/^$/d'
}

echo "Get container ID"
Cont=$(getCont)

echo get Values
People=$(echo "select count(diaspora_handle) from people where id not in (select person_id from contacts);"|sql)
Contact=$(echo "select count(person_id) from contacts;"|sql)
Size=$(echo "SELECT pg_size_pretty( pg_database_size('diaspora_production') );"|sql)
Post=$(echo 'select count(*) from posts;'|sql)

if [ $# -gt 0 ];then
echo Start
Sess=$(newSess)

echo Login
setUrl "$uRl"					|| fail "set url failed"
setElem   $(getElem "user[username]") "$usEr"	|| fail "set username failed"
setElem   $(getElem "user[password]") "$passWd"	|| fail "set password failed"
clickElem $(getElem "commit")			|| fail "Login submit failed"
sleep .2

echo Posting
clickElem $(getElem ".new_status_message .publisher-textarea-wrapper" "css selector")
setElem $(getElem "textarea[id="status_message_text"]" "css selector") "## Diaspora* on raspberry PI test growth report
    Contacts=$Contact
    People  =$People (not yet contacts)
    Size    =$Size
    Posts   =$Post
"
clickElem $(getElem ".btn-group.aspect-dropdown button.dropdown-toggle" "css selector")
clickElem $(getLastElem "li.aspect_selector a" "css selector" -2)
clickElem $(getElem "button[id=submit]" "css selector")

echo Logout
delSess
else
	echo "    Contacts=$Contact
    People  =$People (not yet contacts)
    Size    =$Size
    Posts   =$Post"
fi
