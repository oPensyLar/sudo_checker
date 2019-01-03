#!/bin/bash


POINTER=
RET_FOUND_SUDOERS_FILE=
FILTER_ACCOUNT_NAME="roo*"
USER=
PROCS=
PID=


function parse_process_output()
{
	USER=$1
	PROCS=$2
	PID=$3
}



function chk_is_root()
{


	if (( $EUID != 0 )); then
	    echo "[!] Please run as root"
	    exit
	fi

}



function gen_csv_sudoers_groups()
{


	echo "$1" > $3


	INC=0


	for i in $(echo $POINTER | tr " " "\n")

	do
	  

			if (( $INC == 0 )); then
			  POINTER=$i

			fi		

	let INC++

	done



	
	POINTER=${POINTER:1}
	echo $POINTER >> $3
}




function gen_csv_sudoers_by_home()
{


	echo "$1" > $3



	len=${#POINTER[@]}
 

	for (( i=1; i<$len; i++ )); 
		do


			user_found_sudoers "${POINTER[$i]}" $2			


			if (( $RET_FOUND_SUDOERS_FILE == 1 )); then
			  echo "${POINTER[$i]}" >> $3

			fi



		done
	

}


function gen_csv_procs()
{

	echo "$1,$2,$3" > $5


	while IFS= read -r line
	do

	    parse_process_output $line
	    echo "$PID,$PROCS,$USER" >> $5


	done <<< "$POINTER"


}


function parser_process()
{


	for i in $(echo $POINTER | tr ";" "\n")

	do
	  echo $i
	done

}




function running_process_by_user()
{

	process_by_user=`ps -eo user,comm,pid | grep $1`
	POINTER=$process_by_user

}




function user_found_sudoers()
{


	if grep --quiet  "$1 *" $2; then
	  RET_FOUND_SUDOERS_FILE=1

	else
	  RET_FOUND_SUDOERS_FILE=0

	fi

}





function chk_admin_access()
{

	INC=0

	for entry in $1*
	do

		let INC++
		
		POINTER[$INC]=$(awk '{
		  		n = split($0, t, "/")

		  		for (i = 0; ++i <= n;)

					if (i==3)		  			
		    			print t[i]

		  }'  <<< $entry)

		 		

	done	
}






function chk_sudo_groups()
{


	POINTER=$(awk '{ 

			if (index($0,"%")==1)
			{ 
				print $0
			} 

		 }' $1)



}




running_process_by_user $FILTER_ACCOUNT_NAME
gen_csv_procs "pid" "proc_name" "account_name" $FILTER_ACCOUNT_NAME "/tmp/sudoers_svc.csv"



chk_is_root



chk_sudo_groups "/etc/sudoers"
gen_csv_sudoers_groups "groups_name" "/etc/sudoers" "/tmp/sudoers_groups.csv"




chk_admin_access "/home/"
gen_csv_sudoers_by_home "account_name" "/etc/sudoers" "/tmp/sudoers_home.csv"



running_process_by_user $FILTER_ACCOUNT_NAME
gen_csv_procs "pid" "proc_name" "account_name" $FILTER_ACCOUNT_NAME "/tmp/sudoers_svc.csv"