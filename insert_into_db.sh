
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
	popVotesC3=""
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
			elif [[ $counter == 4 ]]; then
				popVotesC3=$r
			elif [[ $counter == 5 ]]; then  
				totalVotes=$r									
			fi
			counter=$((counter+1))
		done
		
		totalVotes=${totalVotes//,/}  	# Remove all the commas from the total number of votes.
		popVotesC1=${popVotesC1//,/} 
		popVotesC2=${popVotesC2//,/} 
		popVotesC3=${popVotesC3//,/} 
		stateName=${stateName^^}		# Capitalize the name of the state.
		
		# Will always send the overall election results to the database, regardless of what election year it is.
		echo "INSERT INTO totalvotesbystate (electionYear, state, electoralVotes, totalPopVotesCast) VALUES ($electionYear, '$stateName', $electoralVotes, $totalVotes);"  # Display what is about to go to the db.
		# Login to the database and insert.
		
		mysql -u root elections <<eof
INSERT INTO totalvotesbystate (electionYear, state, electoralVotes, totalPopVotesCast) VALUES ($electionYear, '$stateName', $electoralVotes, $totalVotes);
eof

		
		# The insert statements will differ based on which election year it is.
		if [[ $electionYear == "1992" ]]; then 
			echo "INSERT INTO resultspercandidatebystatepercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Bill Clinton', $popVotesC2, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystatepercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('George Bush', $popVotesC1, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystatepercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Ross Perot', $popVotesC3, $electionYear, '$stateName');"
			mysql -u root elections <<eof
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Bill Clinton', $popVotesC2, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('George Bush', $popVotesC1, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Ross Perot', $popVotesC3, $electionYear, '$stateName');
eof
		elif [[ $electionYear == "1996" ]]; then
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Bill Clinton', $popVotesC2, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('George Bush', $popVotesC1, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Ross Perot', $popVotesC3, $electionYear, '$stateName');"
			mysql -u root elections <<eof
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Bill Clinton', $popVotesC1, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Bob Dole', $popVotesC2, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Ross Perot', $popVotesC3, $electionYear, '$stateName');
eof
		elif [[ $electionYear == "2000" ]]; then
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Al Gore', $popVotesC2, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('George W. Bush', $popVotesC1, $electionYear, '$stateName');"				
			mysql -u root elections <<eof
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Al Gore', $popVotesC2, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('George W. Bush', $popVotesC1, $electionYear, '$stateName');
eof
		
		elif [[ $electionYear == "2004" ]]; then
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('John Kerry', $popVotesC2, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('George W. Bush', $popVotesC1, $electionYear, '$stateName');"				
			mysql -u root elections <<eof
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('John Kerry', $popVotesC2, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('George W. Bush', $popVotesC1, $electionYear, '$stateName');
eof
		
		elif [[ $electionYear == "2008" ]]; then
			echo "INSERT INTO results (candidate, popVotesReceived, electionYear, state) VALUES ('John McCain', $popVotesC2, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Barack Obama', $popVotesC1, $electionYear, '$stateName');"				
			mysql -u root elections <<eof
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('John McCain', $popVotesC2, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Barack Obama', $popVotesC1, $electionYear, '$stateName');
eof
		elif [[ $electionYear == "2012" ]]; then
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Mitt Romney', $popVotesC2, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Barack Obama', $popVotesC1, $electionYear, '$stateName');"				
			mysql -u root elections <<eof
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Mitt Romney', $popVotesC2, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Barack Obama', $popVotesC1, $electionYear, '$stateName');
eof
		elif [[ $electionYear == "2016" ]]; then
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Hillary Clinton', $popVotesC2, $electionYear, '$stateName');"
			echo "INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Donald Trump', $popVotesC1, $electionYear, '$stateName');"				
			mysql -u root elections <<eof
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Hillary Clinton', $popVotesC2, $electionYear, '$stateName');
INSERT INTO resultspercandidatebystate (candidate, popVotesReceived, electionYear, state) VALUES ('Donald Trump', $popVotesC1, $electionYear, '$stateName');
eof
		fi
				
	done < "$RESULTFILES"
done
