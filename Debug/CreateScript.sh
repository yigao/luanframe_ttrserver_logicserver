BASEPATH=$(cd `dirname $0`; pwd)

do_work()
{
	ln -sdf $BASEPATH/NFPluginLoader $BASEPATH/$1$2
	#$cp NFPluginLoader $1 -rf
	#chmod a+x $1
	cp AllServer.sh run$1$2.sh -rf
	chmod a+x run$1$2.sh 
	cp AllServer_log.sh $1$2_log.sh -rf
	chmod a+x $1$2_log.sh
	sed -i "s/servername=NFPluginLoader/servername=$1$2/g" ./run$1$2.sh
	sed -i "s/servertype=AllServer/servertype=$1/g" ./run$1$2.sh
	sed -i "s/serverId=6/serverId=$2/g" ./run$1$2.sh

	sed -i "s/AllServer6/AllServer$2/g" ./$1$2_log.sh
	sed -i "s/AllServer/$1/g" ./$1$2_log.sh

	touch Stop.sh
	chmod a+x Stop.sh
	echo "./run$1$2.sh ss" >> Stop.sh

	touch Start.sh
	chmod a+x Start.sh
	echo "./run$1$2.sh" >> Start.sh

	touch Clear.sh
	chmod a+x Clear.sh
	echo "rm $1$2 -rf" >> Clear.sh
	echo "rm $1$2_log.sh -rf" >> Clear.sh
	echo "rm run$1$2.sh -rf" >> Clear.sh
}

do_work MasterServer 1
do_work WorldServer 2
do_work LoginServer 4
do_work ProxyServer 10
do_work ProxyServer 11
do_work GameServer 20


echo "rm Stop.sh -rf" >> Clear.sh
echo "rm Start.sh -rf" >> Clear.sh
echo "rm Clear.sh -rf" >> Clear.sh
