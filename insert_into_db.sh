: 'echo "show all tables"
mysql -u root sms<<EOFMYSQL
show tables;
EOFMYSQL
'

####################################################
# This script will iterate over all the states and
# the election results per each state, sending them 
# to the database.
#
####################################################

cd ./results	# Get to the directory where the election results files are stored.
echo ""
echo "Below are the election results files. Data from each file will be collected and sent to the database."
echo ""
ls -lrt			# Display which elections are going to be considered.

var1=""
if [[ "b" == "b" ]]; then
	var1="blah"
fi
echo $var1

exit

for RESULTFILES in $(ls)
	do
	
	# Results variables.
	electionYear=$(echo "$RESULTFILES" | cut -f 1 -d '.')
	stateName=""
	electoralVotes=""
	popVotesC1=""
	popVotesC2=""
	totalVotes=""
	
	
	echo "************************************************************"
	echo "About to insert for the $electionYear election."
	
	while read p; do
		for r in $p 
		do				
			if [[ $stateName == "" ]]; then
				$stateName = $p
			fi
		done	
	done < "$RESULTFILES"
done

: '
mysql -u root sms<<EOFMYSQL
INSERT INTO presidentialElections (electionYear, state, electoralVotes, totalPopVotes) VALUES () * FROM messages WHERE message_text LIKE '%$s%';
EOFMYSQL
'