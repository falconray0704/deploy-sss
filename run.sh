#!/bin/bash

set -o nounset
set -o errexit
# trace each command execute, same as `bash -v myscripts.sh`
#set -o verbose
# trace each command execute with attachment infomations, same as `bash -x myscripts.sh`
#set -o xtrace

#set -o
set -e
#set -x

export LIBSHELL_ROOT_PATH=${PWD}/libShell
. ${LIBSHELL_ROOT_PATH}/echo_color.lib
. ${LIBSHELL_ROOT_PATH}/utils.lib
. ${LIBSHELL_ROOT_PATH}/sysEnv.lib

# Checking environment setup symbolic link and its file exists
if [ -L ".env_setup" ] && [ -f ".env_setup" ]
then
#    echoG "Symbolic .env_setup exists."
    . ./.env_setup
else
    echoR "Setup environment informations by making .env_setup symbolic link to specific .env_setup_xxx file(eg: .env_setup_amd64_ubt_1804) ."
    exit 1
fi

SUPPORTED_CMD="start, stop"
SUPPORTED_TARGETS="sss"

EXEC_CMD=""
EXEC_ITEMS_LIST=""

CONTAINER_NAME_PREFIX="sss_"
SERVER_PORTS="8080 8801 8802 8410 8000 9000 14000 16285 5222 5223 5228 9001"

stop_sss()
{
	set +e
	echoY "Stopping sss on: ${SERVER_PORTS} ..."
	for srv_port in ${SERVER_PORTS}
	do
		local srv_name="${CONTAINER_NAME_PREFIX}${srv_port}"
		docker stop ${srv_name}
		docker rm ${srv_name}
	done
	echoG "Stopping sss on: ${SERVER_PORTS} finish."
	docker ps -a | grep ${CONTAINER_NAME_PREFIX}
	set -e
}

start_sss()
{
	echoY "Starting sss on: ${SERVER_PORTS} ..."
	for srv_port in ${SERVER_PORTS}
	do
		local srv_name="${CONTAINER_NAME_PREFIX}${srv_port}"
		docker run -d --restart unless-stopped -v ${PWD}/config.json:/config.json -p ${srv_port}:${srv_port} -p ${srv_port}:${srv_port}/udp --name ${srv_name} rayruan/ss_x86_64:static ss-server -c /config.json -p ${srv_port}
	done
	echoG "Starting sss on: ${SERVER_PORTS} successfully!!!"
	docker ps -a | grep ${CONTAINER_NAME_PREFIX}
}

usage_func()
{

    echoY "Usage:"
    echoY './run.sh -c <cmd> -l "<item list>"'
    echoY "eg:\n./run.sh -c start -l \"sss\""
    echoY "eg:\n./run.sh -c stop -l \"sss\""

    echoC "Supported cmd:"
    echo "${SUPPORTED_CMD}"
    echoC "Supported items:"
    echo "${SUPPORTED_TARGETS}"
    
}

no_args="true"
while getopts "c:l:" opts
do
    case $opts in
        c)
              # cmd
              EXEC_CMD=$OPTARG
              ;;
        l)
              # items list
              EXEC_ITEMS_LIST=$OPTARG
              ;;
        :)
            echo "The option -$OPTARG requires an argument."
            exit 1
            ;;
        ?)
            echo "Invalid option: -$OPTARG"
            usage_func
            exit 2
            ;;
        *)    #unknown error?
              echoR "unkonw error."
              usage_func
              exit 1
              ;;
    esac
    no_args="false"
done

[[ "$no_args" == "true" ]] && { usage_func; exit 1; }
#[ $# -lt 1 ] && echoR "Invalid args count:$# " && usage_func && exit 1


case ${EXEC_CMD} in
    "start")
        start_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "stop")
        start_items ${EXEC_CMD} ${EXEC_ITEMS_LIST}
        ;;
    "*")
        echoR "Unsupport cmd:${EXEC_CMD}"
        ;;
esac



