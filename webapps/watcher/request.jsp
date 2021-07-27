<%@ page contentType="text/html" %>
<%@ page import="java.sql.*" %>
<%@ page import = "java.util.Date,java.text.SimpleDateFormat,java.text.ParseException,java.util.Calendar"%>
<%@ page import="org.sqlite.*" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <title>Check Service</title>
    </head>
    <body>
        <table>
            <thead>
                <tr>
                    <th>Computer</th>
                    <th>Request Results</th>
                </tr>
            </thead>
            <tbody>
            <%

				boolean noErrorFlag = true;
				if (request.getParameter("action") != null && request.getParameter("target") != null) {
					noErrorFlag = false;
				} else {
					out.println("No parameters found!");
				}

				if(noErrorFlag == false)
				{
				Class.forName("org.sqlite.JDBC");
				Connection conn =
				DriverManager.getConnection("jdbc:sqlite:./requests.db");
				Statement stat = conn.createStatement();
				
				
				// Determine if request should be skipped
				
				String checkSQL = "SELECT tempActions.cooldown AS thiscooldown, tempActions.action, tempActions.target, req.timedate AS latestRequestTime FROM (SELECT * FROM actions WHERE action=? and target=? LIMIT 1) AS tempActions JOIN (SELECT timedate, action, target FROM requests ORDER BY timedate DESC LIMIT 1) AS req ON tempActions.target = req.target AND tempActions.action = req.action;";
				PreparedStatement checkpreparedStatement = conn.prepareStatement(checkSQL);
				checkpreparedStatement.setString(1, request.getParameter("action"));
				checkpreparedStatement.setString(2, request.getParameter("target"));
				
				ResultSet checkResultSet = checkpreparedStatement.executeQuery();
				
				String latestRequestTime = null;
				Integer cooldown = null;
	
				// Check if the results (requests) are there
				if (checkResultSet.next() == false) {
					out.println("No pending requests found </br>");
				} else {
					do {
						cooldown = Integer.parseInt(checkResultSet.getString("thiscooldown"));
						latestRequestTime = checkResultSet.getString("latestRequestTime");
					} while (checkResultSet.next());
				}	

				checkResultSet.close();	
				
				boolean requestIsEmpty = (latestRequestTime == null || latestRequestTime.length() == 0);
				
				if (requestIsEmpty){
					out.println("Request Submitted</br>");
					// Run to add a request
					String requestSQL = "INSERT INTO requests (timedate,action,target) VALUES( datetime('now'), ?,?);";
					PreparedStatement insertpreparedStatement = conn.prepareStatement(requestSQL);
					insertpreparedStatement.setString(1, request.getParameter("action"));
					insertpreparedStatement.setString(2, request.getParameter("target"));
					insertpreparedStatement.executeUpdate();
					out.println("<b>Request was submitted to the system</b>");
				}else{
					SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					Date latestRequestDate = formatter.parse(latestRequestTime);

					Calendar calendar = Calendar.getInstance();
					calendar.add(Calendar.HOUR, (int) 7);
					Date currentTime = calendar.getTime();

					long diffInSeconds = (currentTime.getTime() - latestRequestDate.getTime()) / 1000;
					if(diffInSeconds < cooldown){
						out.println("Request still on cooldown. Not able to submit new request </br>");
						long difference = (cooldown - diffInSeconds);
						out.println("You will be able to request again in " + difference + " seconds </br>");						
					}else{
						out.println("A new request has been submitted </br>");
						// Run to add a request
						String requestSQL = "INSERT INTO requests (timedate,action,target) VALUES( datetime('now'), ?,?);";
						PreparedStatement insertpreparedStatement = conn.prepareStatement(requestSQL);
						insertpreparedStatement.setString(1, request.getParameter("action"));
						insertpreparedStatement.setString(2, request.getParameter("target"));
						insertpreparedStatement.executeUpdate();
						out.println("<b>Request was submitted to the system</b>");
					}
					
				}				
				
				// Run regardless to get results
				String sql = "SELECT timedate, action, target, result FROM results WHERE action=? and target=? ORDER BY timedate desc limit 10;";
				PreparedStatement preparedStatement = conn.prepareStatement(sql);

				preparedStatement.setString(1, request.getParameter("action"));
				preparedStatement.setString(2, request.getParameter("target"));
				
				ResultSet rs = preparedStatement.executeQuery();
				out.println("</br></br>");
                while (rs.next()) {
                    out.println("<tr>");
					out.println("<td>" + rs.getString("target") + "</td>");
					out.println("<td>" + rs.getString("result") + "</td>");
                    out.println("</tr>");
                }
				
                rs.close();
                conn.close();
						
				}else
				{
					out.println("Sorry there was an error with the request");
				}

            %>
            </tbody>
        </table>
    </body>
</html>