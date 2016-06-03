<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>

<%@page import="java.util.List" import="java.sql.*" import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="java.lang.Object" %>

<%
	Connection conn = null;
	try {
		Class.forName("org.postgresql.Driver");
		String url = "jdbc:postgresql://localhost:5433/shopping";
		String admin = "postgres";
		String password = "Asdf!23";
  		conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}
	
	int lastId = Integer.parseInt(request.getParameter("lastId"));
	PreparedStatement query = conn.prepareStatement("SELECT * FROM log_table WHERE order_id > ? ;");
	query.setInt(1, lastId);
	ResultSet rs = query.executeQuery();
	JSONArray resultArray = new JSONArray();
	while(rs.next())
	{
		JSONObject resultObj = new JSONObject();
		resultObj.put("order_id", rs.getInt(1));
		resultObj.put("state_id", rs.getInt(2));
		resultObj.put("product_id", rs.getInt(3));
		resultObj.put("amount", rs.getInt(4));
		resultArray.add(resultObj);
	}
	
	out.print(resultArray);
	out.flush();
%>

</body>
</html>