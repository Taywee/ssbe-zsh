#!/bin/zsh
# Curl webservice setuff.
autoload colors ; colors

if [ -e ./.ssbe ]
then
    source ./.ssbe
fi

function colindex {
  indent_level++
  COLOR=indent_colors[indent_level]
  echo -e "\$fg[$COLOR]]"
}

export ACCEPT_HEADER="Accept: application/vnd.absperf.sskj1+json, application/vnd.absperf.ssaj1+json, application/vnd.absperf.sscj1+json, application/vnd.absperf.ssmj1+json, application/vnd.absperf.sswj1+json, application/vnd.absolute-performance.syshep+json, application/x-sysshep+json, text/plain"
export ACCEPT_XML='Accept: application/vnd.absperf.ssac1+xml'
export ACCEPT_SSJ="Accept: application/x-sysshep+json"
export ACCEPT_WW="Accept: application/vnd.absperf.sswcj1+json"


CONTENT_SSCJ='Content-Type: application/vnd.absperf.sscj1+json'
CONTENT_SSAC='Content-Type: application/vnd.absperf.ssac1+json'
CONTENT_SSJ='Content-Type: application/vnd.absperf.ssj+json'
CONTENT_SSKJ='Content-Type: application/vnd.absperf.sskj1+json'
CONTENT_SSMJ='Content-Type: application/vnd.absperf.ssmj1+json'
CONTENT_SSAJ='Content-Type: application/vnd.absperf.ssaj1+json'
CONTENT_SSWJ='Content-Type: application/vnd.absperf.sswj1+json'

STD_ARG=(-v --anyauth -u $SSBE_USER:$SSBE_PASS)

export STD_ARG
NONVERBOSE_ARG=(--anyauth -u $SSBE_USER:$SSBE_PASS)


TIDYJSON=(ruby -rubygems -e "require 'json';puts JSON.pretty_generate(JSON.parse(STDIN.read),{:space_before => '$fg[magenta] ',:space => '$fg[cyan] ',:indent => '$fg[pr_green]  '}).gsub('\/','/')")
export TIDYJSON
PRISSY="${TIDYJSON}"

TIDYJSONNOCOL=(ruby -rubygems -e "require 'json';puts JSON.pretty_generate(JSON.parse(STDIN.read)).gsub('\/','/')")

function ndcurl {
  http --json --pretty format --auth $SSBE_USER:$SSBE_PASS "$@"
}

function formcurl {
  http --form --pretty format --auth $SSBE_USER:$SSBE_PASS "$@"
}

function devndcurl {
  curl $DEV_ARG -H "$ACCEPT_HEADER" "$@"
}

function dcurl {
  http --verbose --json --pretty all --auth $SSBE_USER:$SSBE_PASS "$@" "$ACCEPT_HEADER"
}
function bwcurl {
  ndcurl "$@"
}
function vcurl {
  # requires netRW to really be useful, http://www.vim.org/scripts/script.php?script_id=1075
  # once that is installed, you can use the gf commend in vim to follow links in json docs.
  bwcurl $@ | vim --cmd 'let no_plugin_maps=1' -c 'set ft=json' -c 'au VimEnter * set nomod' -
}
function mcurl {
  dcurl $CONTENT_SSMJ $@
}

# SSCJ
function getsscj {
  dcurl "$@" "$CONTENT_SSCJ"
}
function putsscj {
  dcurl PUT "$@" "$CONTENT_SSCJ"
}
function postsscj {
  dcurl POST "$@" "$CONTENT_SSCJ"
}
function delsscj {
  dcurl DELETE "$@" "$CONTENT_SSCJ"
}

# SSAC
function getssac {
  dcurl "$@" "$CONTENT_SSAC"
}
function putssac {
  dcurl PUT "$@" "$CONTENT_SSAC"
}
function postssac {
  dcurl POST "$@" "$CONTENT_SSAC"
}
function delssac {
  dcurl DELETE "$@" "$CONTENT_SSAC"
}

# SSJ
function getssj {
  dcurl "$@" "$CONTENT_SSJ"
}
function putssj {
  dcurl PUT "$@" "$CONTENT_SSJ"
}
function postssj {
  dcurl POST "$@" "$CONTENT_SSJ"
}
function delssj {
  dcurl DELETE "$@" "$CONTENT_SSJ"
}

# SSKJ
function getsskj {
  dcurl "$@" "$CONTENT_SSKJ"
}
function putsskj {
  dcurl PUT "$@" "$CONTENT_SSKJ"
}
function postsskj {
  dcurl POST "$@" "$CONTENT_SSKJ"
}
function delsskj {
  dcurl DELETE "$@" "$CONTENT_SSKJ"
}

# SSMJ
function getssmj {
  dcurl "$@" "$CONTENT_SSMJ"
}
function putssmj {
  dcurl PUT "$@" "$CONTENT_SSMJ"
}
function postssmj {
  dcurl POST "$@" "$CONTENT_SSMJ"
}
function delssmj {
  dcurl DELETE "$@" "$CONTENT_SSMJ"
}

# SSAJ
function getssaj {
  dcurl "$@" "$CONTENT_SSAJ"
}
function putssaj {
  dcurl PUT "$@" "$CONTENT_SSAJ"
}
function postssaj {
  dcurl POST "$@" "$CONTENT_SSAJ"
}
function delssaj {
  dcurl DELETE "$@" "$CONTENT_SSAJ"
}

# SSWJ
function getsswj {
  dcurl "$@" "$CONTENT_SSWJ"
}
function putsswj {
  dcurl PUT "$@" "$CONTENT_SSWJ"
}
function postsswj {
  dcurl POST "$@" "$CONTENT_SSWJ"
}
function delsswj {
  dcurl DELETE "$@" "$CONTENT_SSWJ"
}

# Other
function getxml {
  curl $STD_ARG -H $ACCEPT_XML $@
}
function postform {
  curl -d $@
}

function getww {
  curl $STD_ARG -H $ACCEPT_WW $@
}

function ecurl {
  dcurl $@ 2>/tmp/.ssws.err | grep -vP '("href"|ed_at"|"id")' > /tmp/.ssws.out || exit -1
  cp -a /tmp/.ssws.out /tmp/.ssws.out.ref
  vim --cmd 'let no_plugin_maps=1' -c 'set ft=json' -c 'au VimEnter * set nomod' /tmp/.ssws.out
  CONTENT_TYPE=`cut -f2- -d' ' /tmp/.ssws.err | grep Content-Type | tail -1`
  if [ `find /tmp/.ssws.out -newer /tmp/.ssws.out.ref | wc -l` -gt 0 ]; then
    dcurl -X PUT -d@/tmp/.ssws.out -H $CONTENT_TYPE $@
    if [ $? -ne 0 ]; then
      mv /tmp/.ssws.out /tmp/ssws.out
      rm -f /tmp/.ssws.out.ref /tmp/.ssws.out
      echo "ERROR! Check /tmp/ssws.out"
    fi
  else
    echo "No changes"
  fi

rm -f /tmp/.ssws.err /tmp/.ssws.out /tmp/.ssws.out.ref
}


function li_report_color {
# fuck yes check this shit out
 curl $NONVERBOSE_ARG -s -H "$ACCEPT_HEADER" "$@" | ruby -rubygems -e "require 'json';require 'time';JSON.parse(STDIN.read)['items'].sort {|a,b| a['clientname'] <=> b['clientname']}.each {|i| printf(\"%18.18s %-38.38s %s%5i %s\n\", \"$fg[green]#{i['clientname']}\",\"$fg[white]#{i['hostname']}\",\"$fg[red]\",(Time.now-Time.parse(i['last_message'])).to_i/60,\" minutes ago$fg[white]\")}"
}

function li_report {
# fuck yes check this shit out
 curl $NONVERBOSE_ARG -s -H "$ACCEPT_HEADER" "$@" | ruby -rubygems -e "require 'json';require 'time';JSON.parse(STDIN.read)['items'].sort {|a,b| a['clientname'] <=> b['clientname']}.each {|i| printf(\"%18.18s %-38.38s %s%5i %s\n\", \"#{i['clientname']}\",\"#{i['hostname']}\",\"\",(Time.now-Time.parse(i['last_message'])).to_i/60,\" minutes ago\")}"
}

function addhost {
    postsskj http://core.$2/clients/$3/hosts "_type=Host" "name=$1" 'tags:=["Added via postsskj - please edit tag"]' "active?:=true"
}

# addagent {User account ID number} {backend fqdn} {client name} {host id number} {configuration id number}
function addagent {
     postssmj http://core.$2/agents "_type=Agent" "account_href=http://core.$2/accounts/$1" "client_href=http://core.$2/clients/$3" "host_href=http://core.$2/hosts/$4" "configuration_href=http://config.$2/configurations/$5" "notes:=null"
}

function jpath {
    SELECTOR="$1"
    shift
    if [ "$#" -eq 1 ]
    then
        JSON="$1"
        shift
    else
        JSON="$(cat)"
    fi
    SELECTOR="$(echo "${SELECTOR}" | sed 's/\/\([0-9]\+\)/[\1]/g')"
    SELECTOR="$(echo "${SELECTOR}" | sed 's/\/\([^\/\[]\+\)/["\1"]/g')"
    #echo ${SELECTOR}
    node -e "var struct = ${JSON}; process.stdout.write(struct${SELECTOR} + \"\\n\");"
}

# changeagentconfig BACKEND AGENTID NEWCONFIGPARENTID
# For changing the parent id of an agent with the wrong parent in its config
function changeagentconfig {
    BACKEND="$1"
    shift
    AGENTID="$1"
    shift
    NEWCONFIGPARENTID="$1"
    shift
    OLDAGENTPAGE="$(ndcurl "https://core.${BACKEND}/agents/${AGENTID}.json")"
    echo "Old Agent Page:\n${OLDAGENTPAGE}"
    OLDCONFIGHREF="$(jpath "/configuration_href" "${OLDAGENTPAGE}")"
    echo "Old Config Href:\n${OLDCONFIGHREF}"
    CLIENTHREF="$(jpath "/client_href" "${OLDAGENTPAGE}" | sed 's/https/http/')"
    echo "Client Href:\n${CLIENTHREF}"
    HOSTHREF="$(jpath "/host_href" "${OLDAGENTPAGE}")"
    echo "Host Href:\n${HOSTHREF}"
    HOSTNAME="$(ndcurl "${HOSTHREF}.json" | jpath "/name")"
    echo "Hostname:\n${HOSTNAME}"
    NEWCONFIGJSON="$(formcurl POST "http://config.${BACKEND}/configurations.json" 'submit=save' 'configuration[public]=false' 'configuration[notes]=NONOTES' "configuration[name]=${HOSTNAME}" "configuration[parent_id]=${NEWCONFIGPARENTID}" "configuration[client_href]=${CLIENTHREF}")"
    echo "New Config JSON:\n${NEWCONFIGJSON}"
    NEWCONFIGHREF="$(jpath "/href" "${NEWCONFIGJSON}")"
    echo "New Config HREF:\n${NEWCONFIGHREF}"
    formcurl PUT "https://core.${BACKEND}/agents/${AGENTID}.json" 'utf8=✓'  'commit=save' "agent[configuration_href]=${NEWCONFIGHREF}"
}
