main()
{
	LOG=logs/AllServer6/AllServer.log
		        
	tail --follow=name --retry $LOG --max-unchanged-stats=3 -n 5 -q | awk '/info/ {print "\033[32m" $0 "\033[39m"} /debug/ {print  $0 }  /warning/ {print "\033[33m" $0 "\033[39m"} /    trace/ {print "\033[33m" $0 "\033[39m"} /error/ {print "\033[31m" $0 "\033[39m"}'
}

main

