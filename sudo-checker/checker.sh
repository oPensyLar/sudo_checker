#!/bin/bash


# Globals variables user_found_sudoers()
POINTER_SUDO_GROUPS=
RET_FOUND_SUDOERS_FILE=



# Filter name process account
FILTER_ACCOUNT_NAME=



# Globals variables used by order_procs()
USER=
PROCS=
PIDS=

USER2=
PROCS2=
PIDS2=

LEN_PROCS=



# Global variable used by ......
USER_EXIST=


# CSV Output file
CSV_FILE_OUT="/tmp/chk_sudo_enviroment.csv"



# Globals variables used by chk_sudo_by_home()
SUDO_USERS_FOUND=
QUANTITY_SUDO_USERS=0




# Globals variables used by extract_group_sudoers()
GROUPS_SUDO_FOUND=
QUANTITY_SUDO_GROUPS=0


# Sudoers folders
SUDOERS_FOLDERS[0]="/etc/sudoers.d/"
#SUDOERS_FOLDERS[1]="/etc/group/"


# Globals variables for command line
param_group=0
param_users=0
param_privileges=0
param_help=0
param_output=0


# Next variables
next_user_filter=0
next_filename=0
argc=0





function parse_command_line()
{
		



	total_headers=	


	if [ $param_help -eq 1 -a \( $total_flags = 1 \) ]
	then    	

		print_help
		exit

	fi



	if [ $param_users -eq 1 ]
	then

		total_headers="pid,proc_name,user_priv"
		running_process_by_user $FILTER_ACCOUNT_NAME

	fi




	if [ $param_privileges -eq 1 ]
	then

		
		theaders_size=${#total_headers}

		
		if (( $theaders_size > 0 ))
		then
			total_headers=$total_headers","
		fi


		total_headers=$total_headers"home_sudo_privileges"
		chk_sudo_by_home "/home/"

	fi




	if [ $param_group -eq 1 ]
	then



		theaders_size=${#total_headers}

		
		if (( $theaders_size > 0 )); then
			total_headers=$total_headers","

		fi



		total_headers=$total_headers"group_sudo_privileges"
		chk_sudo_groups

	fi


	build_headers $total_headers

	
	gen_output $CSV_FILE_OUT


}





function print_help()
{

	echo "Check sudo groups, users and process filter by users"
	echo -e "Version 1.0, Jan-2018."
	echo -e "Devel: emelys3 - Emely Solorzano"	
	echo -e "Support: emelys3@protonmail.com"
	echo -e "\r\n"	
	echo -e "  Usage: $0 -g -p -u -o logs.csv\r\n"	
	echo -e "\t -g\t\t Enumerate all groups allow sudo privileges"
	echo -e "\t -u pattern\t Enumerate all processs of a specific user"
	echo -e "\t -p\t\t Check local users sudo privileges"
	echo -e "\t -o file\t Output log file"
	echo -e "\t -h\t\t Print help"
	echo -e "\r\n"

}



function chk_user_exist()
{

	if getent passwd $1 > /dev/null 2>&1; then
	    USER_EXIST=1
	else
	    USER_EXIST=0
	fi


}



function gen_output()
{



	len_users=${#SUDO_USERS_FOUND[@]}
	#echo "[+] Users founds:: " $len_users
	
	len_procs=${#PROCS2[@]}
	#echo "[+] Process founds:: " $len_procs

	len_homes=${#GROUPS_SUDO_FOUND[@]}
	#echo "[+] /home/ founds:: " $len_homes


	max_values=$len_users


	if [ $max_values -lt $len_procs ]; then
		max_values=$len_procs
	fi


	if [ $max_values -lt $len_homes ]; then
		max_values=$len_homes
	fi



	index=0
	let max_values--




	while [ $index -le $max_values ]
	do


		# Procs privileges

		if [ $param_users -eq 1 ]
		then    	
			str_out_csv="${PIDS2[$index]}"
			str_out_csv=$str_out_csv","
			str_out_csv=$str_out_csv"${PROCS2[$index]}"
			str_out_csv=$str_out_csv","
			str_out_csv=$str_out_csv"${USER2[$index]}"		
		fi		




		# Homes users sudo priveleges (by home)

		if [ $param_privileges -eq 1 ]
		then    	



		if [ $param_users -eq 1 ]
		then

			str_out_csv="$str_out_csv,"

		fi





			str_out_csv="$str_out_csv${SUDO_USERS_FOUND[$index]}"


		if [ $param_group -eq 1 ]
		then

			str_out_csv="$str_out_csv,"

		fi

		fi





		# Groups sudo privileges

		if [ $param_group -eq 1 ]
		then

		str_out_csv=$str_out_csv"${GROUPS_SUDO_FOUND[$index]}"		

		fi



		
		echo $str_out_csv >> $1
		str_out_csv=""
		((index++))

	done

}







function extract_group_sudoers()
{



while read -r line; do	


		ret_awk=$(awk '{ 

					match($0, /^%[a-z]*/)
					{
						print substr($0, RSTART+1, RLENGTH-1)
					}

				}'  <<< $line)
		


		size=${#ret_awk}

		if (( $size != 0 )); then
			
	    	GROUPS_SUDO_FOUND[$QUANTITY_SUDO_GROUPS]=$ret_awk
	    	let QUANTITY_SUDO_GROUPS++

		fi


done < "$1"


}




function build_headers()
{	

	if [ $total_flags -eq 1 ]
	then    	
	  	echo -e "\r\n[!] Please specific action\r\n"
		print_help	
		exit -1

	fi		
	


	echo $1 > $CSV_FILE_OUT

}





function parse_process_output()
{
	USER=$1
	PROCS=$2
	PIDS=$3
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




function order_procs()
{

	LEN_PROCS=0


	while IFS= read -r line
	do

	    parse_process_output $line

		PROCS2[LEN_PROCS]=$PROCS
		USER2[LEN_PROCS]=$USER
		PIDS2[LEN_PROCS]=$PIDS

	    let LEN_PROCS++	    	   


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

	process_by_user=`ps -eo uname:50,comm,pid | grep $1`
	POINTER=$process_by_user
	order_procs

}




function user_found_sudoers()
{


	if grep --quiet  "$1 *" $2; then
	  RET_FOUND_SUDOERS_FILE=1

	else
	  RET_FOUND_SUDOERS_FILE=0

	fi

}





function chk_sudo_by_home()
{

	for userlist in `ls -F $1`; do



	    userlist=${userlist::-1}

	    chk_user_exist $userlist




	    if (( $USER_EXIST == 0 )); then
	    	continue
	    fi



		if `sudo -U $userlist -l > /dev/null`; then
			SUDO_USERS_FOUND[$QUANTITY_SUDO_USERS]=$userlist
			let QUANTITY_SUDO_USERS++

		fi		

	done

}






function chk_sudo_groups()
{



	len=${#SUDOERS_FOLDERS[@]}




	for (( i=0; i<$len; i++ )); 
		do			

			for f in `ls -A "${SUDOERS_FOLDERS[$i]}"`; do				

  				extract_group_sudoers "${SUDOERS_FOLDERS[$i]}$f"

			done


		done

}


chk_is_root


argc="$#"


for i in "$@"
do


	if (( $next_user_filter == 1 )); then
		next_user_filter=0
		FILTER_ACCOUNT_NAME=$i
	fi



	if [ $next_filename == 1 ]; then


		next_filename=0

		echo > $i > /dev/null
	    

		if [ ! -e $i ]; then
		    echo "[!] Unable create file log"
		    exit -2

			else
				CSV_FILE_OUT=$i

		fi 		

	fi 	




case $i in


    -g)
    param_group=1
    ;;



    -u)
    param_users=1
    next_user_filter=1
    ;;



    -p)	
    param_privileges=1    
    ;;



    -o)
    param_output=1
    next_filename=1
    ;;


    -h)
    param_help=1
    ;;


esac
done


total_flags=$(( param_help + param_output + param_group + param_users + param_privileges))

parse_command_line 

