package com.company;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.LinkedList;
import java.util.Scanner;

public class Main {

    /*
    Display states won by either candidate by nine percentage points or more.
     */

    public static void main(String[] args) {
        Scanner input = new Scanner(System.in);
        System.out.println("Enter the election year for which you would like to find solid winning states:");
        int year = input.nextInt();

        // Linked lists to hold states that voted Democrat/Republican by nine or more points during specified election year.
        LinkedList<State> republicanStates = new LinkedList<>();
        LinkedList<State> democraticStates = new LinkedList<>();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException cnfe) {
            System.out.println("ClassNotFoundException: " + cnfe);
        }
        
        // Try getting all the states in the database.
        try {  
            String query = "SELECT state, electoralVotes FROM totalvotesbystate WHERE electionYear = " + year + " GROUP BY state;";
            Connection conn = getConnection();
            Statement st = conn.createStatement();

            // execute the query, and get a java resultset
            ResultSet rs = st.executeQuery(query);

            // iterate through the java resultset
            while (rs.next()) {
                State s = new State(rs.getString(1), rs.getInt(2));
                
                // Add each state to the lists of (potential) solid Republican/Democratic states.
                republicanStates.add(s);
                democraticStates.add(s);
            }
            rs.close();
            st.close();

        } catch (Exception e) {
            System.err.println("Exception trying to see if the call exists: " + e.getMessage());
        }

        // Now list all states won by Republicans/Democrats by 9 points or more in the specified election.
        try {  // check that the call does not already xist in the database
            // Query to get fractional vote share for Democrats and Republicans in every state during the specified election.
            String query = "SELECT\n" +
                    "    t1.state,\n" +
                    "    r1.candidate,\n" +
                    "    r1.popVotesReceived / t1.totalPopVotesCast AS 'R_percent',\n" +
                    "    r2.candidate,\n" +
                    "    r2.popVotesReceived / t1.totalPopVotesCast AS 'D_percent'\n" +
                    "FROM\n" +
                    "    totalvotesbystate t1\n" +
                    "JOIN(\n" +
                    "    SELECT\n" +
                    "        *\n" +
                    "    FROM\n" +
                    "        resultspercandidatebystate res1\n" +
                    "    JOIN(\n" +
                    "        SELECT\n" +
                    "            *\n" +
                    "        FROM\n" +
                    "            candidates\n" +
                    "        WHERE\n" +
                    "            party = 'Republican'\n" +
                    "    ) c1\n" +
                    "ON\n" +
                    "    c1.candidateName = res1.candidate\n" +
                    ") r1\n" +
                    "ON\n" +
                    "    r1.electionYear = t1.electionYear AND r1.state = t1.state\n" +
                    "JOIN(\n" +
                    "    SELECT\n" +
                    "        *\n" +
                    "    FROM\n" +
                    "        resultspercandidatebystate res2\n" +
                    "    JOIN(\n" +
                    "        SELECT\n" +
                    "            *\n" +
                    "        FROM\n" +
                    "            candidates\n" +
                    "        WHERE\n" +
                    "            party = 'Democratic'\n" +
                    "    ) c2\n" +
                    "ON\n" +
                    "    c2.candidateName = res2.candidate\n" +
                    ") r2\n" +
                    "ON\n" +
                    "    r2.electionYear = t1.electionYear AND r2.state = t1.state\n" +
                    "WHERE\n" +
                    "    t1.electionYear = " + year + ";";
            Connection conn = getConnection();
            Statement st = conn.createStatement();

            // execute the query, and get a java resultset
            ResultSet rs = st.executeQuery(query);

            // iterate through the java resultset
            while (rs.next()) {
                // Check if the state was a solid Republican state.
                if (rs.getDouble(3) - 0.09 < rs.getDouble(5)) {
                    try {
                        for (int i = 0; i < republicanStates.size(); i++) {
                            if (republicanStates.get(i).state.equals(rs.getString(1))) {
                                republicanStates.remove(i);
                                break;
                            }
                        }
                    } catch (Exception ex) {
                        System.out.println("Error trying to remove state: " + rs.getString(1));
                    }
                }
                
                // Now check if the Democrat won the state solidly.
                if (rs.getDouble(5) - 0.09 < rs.getDouble(3)) {
                    try {
                        for (int i = 0; i < democraticStates.size(); i++) {
                            if (democraticStates.get(i).state.equals(rs.getString(1))) {
                                democraticStates.remove(i);
                                break;
                            }
                        }
                    } catch (Exception ex) {
                        System.out.println("Error trying to remove state: " + rs.getString(1));
                    }
                }
            }

            rs.close();
            st.close();

        } catch (Exception e) {
            System.err.println("Exception trying to see if the call exists: " + e.getMessage());
        }

        displaySolidStates("Republican", republicanStates, year);
        System.out.println("\n");
        displaySolidStates("Democratic", democraticStates, year);
    }

    // Displays results.
    public static void displaySolidStates(String party, LinkedList<State> partyStates, int year) {
        System.out.println("------------------------------");
        System.out.println("Below are the solid " + party + " states...");
        int totalEVotes = 0;
        for (int i = 0; i < partyStates.size(); i++) {
            totalEVotes += partyStates.get(i).electoralVotes;
            System.out.println(partyStates.get(i).state + ", " + partyStates.get(i).electoralVotes);
        }
        System.out.println("Total solid " + party + " electoral votes in " + year + ": " + totalEVotes);
        System.out.println("------------------------------");
    }

    // Connects to the database.
    public static Connection getConnection() {
        // Try getting a connection to the database.
        Connection conn = null;
        try {
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/elections", "root", "");
        } catch (Exception ex) {
            System.out.println("Exception message: " + ex.getMessage());
        }
        return conn;
    }

}

// The State class is used to hold the name of a state and its electoral votes.
class State {
    String state;
    int electoralVotes;

    public State(String stateName, int eVotes) {
        this.state = stateName;
        this.electoralVotes = eVotes;
    }
}
