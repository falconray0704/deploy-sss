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

# 钉钉,腾讯企点: 33445
# 文华财经: 8200-8250
# Zoom会议: 8801-8802
# 微信视频聊天: 16285
# 爱奇艺视频: 8410
# 微云网盘: 14000
# 剑侠情缘3 : 3724
# TeamViewer : 5938
# 大智慧App : 12346，6860，12345,22223
# 东方财富通 : 1860-1870
# 迅雷下载 : 6666
# QQ游戏 : 8000
# 新浪UC : 5000
# 联众游戏 : 8012
# 阿里旺旺 : 16000
# 浩方电竞 : 1201
# 腾讯视频 : 8000
# PPTV : 7100, 7101
# 大智慧 : 6188, 5188
# 同花顺 : 7709, 9999, 8601,8001
# 国泰君安交易软件 : 1558
# 通达信行情软件 : 7700-7760,80,21000,443
# 光大证券 : 6677
# 申银万国证券 : 6166,9001
# 中投证券交易软件 : 708,706,709
# 贸易通,淘宝旺旺文件传输 : 18386, 16000
# 飞信文件 : 8009
# 迅雷看看 : 8888
# 人人网 : 25553
# QQ网游加速器 : 9999



SERVER_PORTS="8080 33445 6666 8888 9999 5188 6188 8801 8802 8410 8000 14000 16285 9001"

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



