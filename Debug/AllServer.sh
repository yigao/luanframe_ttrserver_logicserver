servername=NFPluginLoader
servertype=AllServer
serverId=6

dowork()
{
	startpt
	startss
}

startss()
{
	echo "starting $servername"
	$PWD/$servername  -d --Server=$servertype --ID=$serverId --Path=../Config --LuaScript=../ScriptModule
	sleep 1
	ps x|grep "$servername"|sed -e '/grep/d'
}

check_stop_over()
{
	while [ 1 ]
	do
		sleep 1
		pid=`ps x |grep $PWD/$servername | sed -e '/grep/d' | gawk '{print $1}'`
		if [ -z "$pid" ]
		then
			echo "$PWD/$servername Stop Over"
			break
		else
			echo "$PWD/$servername Still Runing, Please Wait..."
		fi
	done
}

stopss()
{
	pid=`ps x |grep $PWD/$servername | sed -e '/grep/d' | gawk '{print $1}'`
	if [ -z "$pid" ]
	then
		return
	fi
	echo "$PWD/$servername Exist.........Stop .............."
	#ps x |grep $PWD/$servername | sed -e '/grep/d' | gawk '{print "panic."$1}' | xargs rm -rf
	ps x |grep $PWD/$servername | sed -e '/grep/d' | gawk '{print $1}' | xargs kill -10
	check_stop_over
	echo "stop $servername"
}

	echo "--------------------------------------------------"
	echo "--------------------START-------------------------"
	echo "--------------------------------------------------"
case $1 in
	exit)
	stopss
	;;
	ss)
	stopss
	;;
	s)
	stopss
	;;
	stop)
	stopss
	;;

	run)
	startss
	;;

	*)
	stopss
	sleep 1
	startss
	;;
esac
echo "--------------------------------------------------"
echo "----------------------DONE------------------------"
echo "--------------------------------------------------"

