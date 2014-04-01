#!/bin/sh
# Takes in from standard in a list of host ip pairs.  The hostname must NOT have spaces.  Neither must the IP.
# Optionally, the script may take one argument, for a script to run on the poller host to create and configure
# the agents
# SSBE_USER, SSBE_PASS, AGENT_PASS, and CLIENT are expected to be set as environment variables, otherwise this probably won't work out for you

if [ -z "${CLIENT}" ]; then CLIENT=omm-location; fi

exec 3>>"${1:-/dev/null}"

echo "tar -xvzf SysShep-s-UBUNTU-5.3.7.tar.gz" >&3
echo >&3

while read line
do
    HOST="$(echo "$line" | awk '{print $1}')"
    IP="$(echo "$line" | awk '{print $2}')"
    # Filter IP to add backslashes for the regex
    FILTEREDIP="$(echo "$IP" | sed 's/\./\\\\./g')"

    # Create the config
    RESPONSE="$(http --ignore-stdin -f -a "${SSBE_USER}:${SSBE_PASS}" POST "http://config.ssbe06.qwest.sysshep.com/configurations" "submit=save" "configuration[public]=false" "configuration[parent_id]=2429" "configuration[notes]=Trap scraper for $HOST" "configuration[name]=${HOST}-trap" "configuration[client_href]=http://core.ssbe06.qwest.sysshep.com/clients/${CLIENT}" </dev/null)"

    # Get the config URL
    CONFIG="$(echo "$RESPONSE" | sed -e 's/^.*="//' -e 's/".*$//')"

    http --ignore-stdin -f -a "${SSBE_USER}:${SSBE_PASS}" PUT "${CONFIG}/registered_templates/1302/update_answers" "submit=save" "answers[log-file-regex]=^.*?(?:${HOST}|${FILTEREDIP}).*$" </dev/null

    cat >&3 <<HERE
# ${HOST}-trap ${CONFIG}
cd /opt/SysShep
tar -xvzf SysShep-s-UBUNTU-5.3.7.tar.gz
cp -rv SysShep-s-UBUNTU-5.3.7 ${HOST}-trap
cd ${HOST}-trap/bin
./configure "${SSBE_USER}" "${SSBE_PASS}"  ssbe06.qwest.sysshep.com ${CLIENT} ${HOST}-trap '${CONFIG}' '${AGENT_PASS}'
HERE

done
