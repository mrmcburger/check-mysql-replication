#!/bin/sh
#############################################
# Migeon Cyril
# 2013/04/11

# Nagios Plugin
# Check if the mysql replication is ok
#############################################

usage()
{
cat << EOF
    usage: $0 options

    This script check if the replication is ok for a database
    The only informations needed are those to connect to the slave server    

    OPTIONS:
        -h Show this message
        -u User     (mandatory)
        -p Password (mandatory)
        -H Host     (mandatory)
        -P Port     (mandatory)
        -m Master   (optional)
        -s Slave    (option)

EOF
}

while getopts "hu:p:H:P:m:s:" opt
do
    case $opt in
        h)
            usage
            exit 1
            ;;
        u)
            MYSQL_USER=$OPTARG
            ;;
        p)
            MYSQL_PWD=$OPTARG
            ;;
        H)
            HOST=$OPTARG
            ;;
        P)
            PORT=$OPTARG
            ;;
        m)
            MASTER=$OPTARG
            ;;
        s)
            SLAVE=$OPTARG
            ;;
        ?)
            usage
            exit
            ;;
    esac
done

if [[ -z "${MYSQL_USER}" ]] || [[ -z "${MYSQL_PWD}" ]] || [[ -z "${HOST}" ]] || [[ -z "${PORT}" ]]
then
    usage
    exit 1
fi

#Get the status of the last synchronization
TEST_VARIABLE=`mysql -h ${HOST} -u ${MYSQL_USER} -p${MYSQL_PWD} -P ${PORT} -e 'show slave status\G' | awk '$1=="Seconds_Behind_Master:" {print $2}'`

if [[ "x$TEST_VARIABLE" != "xNULL" ]]
then
    if [[ -n "${MASTER}" && "${SLAVE}" ]]
    then
        echo "OK - Synchronisation entre ${SLAVE} et ${MASTER}"
        exit 0
    else
        echo "OK - Synchronisation entre l'esclave et son maitre"
        exit 0
    fi
else
    if [[ -n "${MASTER}" && -n "${SLAVE}" ]]
    then
        echo "WARNING - Pas de synchronisation entre ${SLAVE} et ${MASTER}"
	exit 1
    else
        echo "WARNING - Pas de synchronisation entre l'esclave et son maitre"
        exit 1
    fi
fi
