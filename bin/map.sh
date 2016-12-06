#!/bin/bash

# Set the root location of the script so that it can
# be used to place the log and temp file in it's 
# proper location
script_home=`dirname $0`
script_home=`(cd "$script_home/.." && pwd)`

# Set variables for where to store temp and log files 
app_list_file="$script_home/tmp/applist.tmp"
log_file="$script_home/logs/`date +%F_%H:%M:%S`_applist.log"

# Cleanup leftover temp file if previous program exited prematurely
rm $app_list_file 2> /dev/null

# Generate list of apps and put it in a temporary file
cf apps | awk -F / '(NR>4){print $1,$3}' | awk '{print $1,$3}' > $app_list_file

echo
echo "*********************************************" | tee $log_file
echo "*                                           *" | tee -a $log_file
echo "*             Cloud Foundry                 *" | tee -a $log_file
echo "*      Application to Cell Mapping          *" | tee -a $log_file
echo "*                                           *" | tee -a $log_file
echo "* This program identifies the IP addresses  *" | tee -a $log_file
echo "* of all the cells that are running a       *" | tee -a $log_file
echo "* particular application.                   *" | tee -a $log_file
echo "*                                           *" | tee -a $log_file
echo "*********************************************" | tee -a $log_file

# loop through apps and identify the IP of the cell they are running on
# NOTE: IFS needs to be set to newline otherwise the for loop prints 
# each word on a new line
IFS=$'\n'
for line in $(cat $app_list_file)
do
	#Initialize variables 
	my_app=`echo $line | awk '{print $1}'`
	numb_of_inst=`echo $line | awk '{print $2}'`

	# Print formatting information
	echo | tee -a $log_file
	echo $numb_of_inst instances of $my_app are located at: | tee -a $log_file
	echo "---------------------------------------------" | tee -a $log_file

	#Print app instance number with Cell IP 
	for(( instance=0; instance < $numb_of_inst; instance++ ))
	do
		cell_ip=`cf ssh $my_app -i $instance -c 'echo $CF_INSTANCE_IP'`
		echo $instance : $cell_ip | tee -a $log_file
	done
done

#Cleanup temp file
rm $app_list_file 2> /dev/null
