SELECT
    candidate,
    electionYear,
    FORMAT(SUM(popVotesReceived),
    0)
FROM
    results
WHERE
    LENGTH(state) = 2
GROUP BY
    electionYear,
    candidate