
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

for RESULTFILES in $(ls)
	do
	
	# Results variables.
	electionYear=$(echo "$RESULTFILES" | cut -f 1 -d '.')  # Gets the filename without the extension (results for the 2000 presidential election would be stored in a file named "2000.txt")
	stateName=""
	electoralVotes=""
	popVotesC1=""
	popVotesC2=""
	totalVotes=""
	
	
	echo "************************************************************"
	echo "About to insert for the $electionYear election."
	
	
	# Results for every state are stored on one line each.
	while read p; do
		counter=0  		# Keeps track of which field we're looking at.
		
		for r in $p 
		do				 
			# Results are stored in different fields.
			if [[ $counter == 0 ]]; then
				stateName=$r
			elif [[ $counter == 1 ]]; then 
				electoralVotes=$r
			elif [[ $counter == 2 ]]; then
				popVotesC1=$r
			elif [[ $counter == 3 ]]; then
				popVotesC2=$r
			elif [[ $counter == 5 ]]; then  
				totalVotes=$r									
			fi
			counter=$((counter+1))
		done
		
		totalVotes=${totalVotes//,/}  	# Remove all the commas from the total number of votes.
		stateName=${stateName^^}		# Capitalize the name of the state.
		

		echo "INSERT INTO presidentialElections (electionYear, state, electoralVotes, totalPopVotesCast) VALUES ($electionYear, '$stateName', $electoralVotes, $totalVotes);"  # Display what is about to go to the db.
		
		# Login to the database and insert.
		mysql -u root elections <<eof
INSERT INTO presidentialElections (electionYear, state, electoralVotes, totalPopVotesCast) VALUES ($electionYear, '$stateName', $electoralVotes, $totalVotes);
eof


	done < "$RESULTFILES"
done
