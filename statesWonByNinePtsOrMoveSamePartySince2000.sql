/*
Show all states won by Republicans/Democrats by 9 points or more in EVERY election since 2000.
For example: Hawaii voted for the Democratic candidate in 2000, 2004, 2008, 2012, and 2016, and 
in each of these elections the democrat won by 9 percentage points or more. Iowa, on the other hand, has voted 
for Democratic and Republican candidates since the 2000 election. In 2016, it voted for Donald 
Trump by more than 9 points, but since the state voted Rebublican by a smaller amount in 2004, 
and voted Democratic in 2000, 2008, and 2012, that state would not count in this query.
*/

-- Show the percentage win for republicans, 2000-Present
select r1.candidate, r1.state, r1.electionYear, r1.popVotesReceived/t1.totalPopVotesCast
from resultspercandidatebystate r1 join 
(select * from totalvotesbystate where electionYear >= 2000) t1 on t1.electionYear = r1.electionYear and t1.state = r1.state
join (select * from candidates where party = 'Republican') c1 on c1.candidateName = r1.candidate
where r1.electionYear >= 2000 and r1.popVotesReceived/t1.totalPopVotesCast >= .5;
