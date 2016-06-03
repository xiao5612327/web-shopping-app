<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Insert title here</title>
</head>
<body>



<%@page import="java.util.List" import="helpers.*" import="java.sql.*"
	import="java.util.*"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="org.json.simple.JSONArray"%>
<%@page import="java.lang.Object" %>
<%@page import="com.google.gson.*" %>


<%
System.out.println("ajax.jsp called");

if(request.getParameter("action").equals("black"))
{
	System.out.println("action is black");
	ArrayList<int[]> arraylist = new ArrayList<int[]>();
	try {
		int sid;
		int pid;
		int amount;
		Connection con = null;
		try {
			Class.forName("org.postgresql.Driver");
			   String url = "jdbc:postgresql://localhost:5433/shopping";
			  	String admin = "postgres";
			  	String password = "Asdf!23";
	  		con = DriverManager.getConnection(url, admin, password);
		}
		catch (Exception e) {}
		Statement stmt = con.createStatement();
		
		String statement = "select sid,pid from p_u_t group by sid,pid";
		PreparedStatement ps = con.prepareStatement(statement);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {

			int[] inner = new int[2];
			inner[0] =rs.getInt(1);
			inner[1] =rs.getInt(2);

			arraylist.add(inner);
		}
		
		Gson gson = new GsonBuilder().create();
		JsonArray myCustomArray = gson.toJsonTree(arraylist).getAsJsonArray();
		response.setContentType("application/json");	
		response.getWriter().print(myCustomArray);		
		response.setStatus(200);
		con.close();
			
	} catch (Exception e) {
		e.printStackTrace();
	}
}



else if(request.getParameter("action").equals("cell"))
{
	System.out.println("action is cell");
	ArrayList<int[]> arraylist = new ArrayList<int[]>();
	try {
		int sid;
		int pid;
		int amount;
		Connection con = null;
		try {
			Class.forName("org.postgresql.Driver");
			   String url = "jdbc:postgresql://localhost:5433/shopping";
			  	String admin = "postgres";
			  	String password = "Asdf!23";
	  		con = DriverManager.getConnection(url, admin, password);
		}
		catch (Exception e) {}
		String statement = "select sid,pid,sum(amount) from u_t group by sid,pid";
		PreparedStatement ps = con.prepareStatement(statement);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {

			int[] inner = new int[3];
			inner[0] =rs.getInt(1);
			inner[1] =rs.getInt(2);
			inner[2] =rs.getInt(3);

			arraylist.add(inner);
		}
		
		Gson gson = new GsonBuilder().create();
		JsonArray myCustomArray = gson.toJsonTree(arraylist).getAsJsonArray();
		response.setContentType("application/json");	
		response.getWriter().print(myCustomArray);	
		
		Statement stmt = con.createStatement();
		String drop = "drop table if exists p_u_t;";
        stmt.executeUpdate(drop);
		con.close();
			
	} catch (Exception e) {
		e.printStackTrace();
	}
}

else if(request.getParameter("action").equals("state"))
{
	System.out.println("action is state");
	ArrayList<int[]> arraylist = new ArrayList<int[]>();
	try {
		int sid;
		int pid;
		int amount;
		Connection con = null;
		try {
			Class.forName("org.postgresql.Driver");
			   String url = "jdbc:postgresql://localhost:5433/shopping";
			  	String admin = "postgres";
			  	String password = "Asdf!23";
	  		con = DriverManager.getConnection(url, admin, password);
		}
		catch (Exception e) {}
		String statement = "select sid,sum(amount) from u_t group by sid";
		PreparedStatement ps = con.prepareStatement(statement);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {

			int[] inner = new int[2];
			inner[0] =rs.getInt(1);
			inner[1] =rs.getInt(2);

			arraylist.add(inner);
		}		
		Gson gson = new GsonBuilder().create();
		JsonArray myCustomArray = gson.toJsonTree(arraylist).getAsJsonArray();
		response.setContentType("application/json");	
		response.getWriter().print(myCustomArray);				
		response.setStatus(200);
		con.close();
			
	} catch (Exception e) {
		e.printStackTrace();
	}
}

else if(request.getParameter("action").equals("product"))
{
	System.out.println("action is product");
	ArrayList<int[]> arraylist = new ArrayList<int[]>();
	try {
		int sid;
		int pid;
		int amount;
		Connection con = null;
		try {
			Class.forName("org.postgresql.Driver");
			   String url = "jdbc:postgresql://localhost:5433/shopping";
			  	String admin = "postgres";
			  	String password = "Asdf!23";
	  		con = DriverManager.getConnection(url, admin, password);
		}
		catch (Exception e) {}
		String statement = "select pid,sum(amount) from u_t group by pid";
		PreparedStatement ps = con.prepareStatement(statement);
		ResultSet rs = ps.executeQuery();
		while (rs.next()) {

			int[] inner = new int[2];
			inner[0] =rs.getInt(1);
			inner[1] =rs.getInt(2);
			arraylist.add(inner);
		}		
		Gson gson = new Gson();
		
		JsonArray myCustomArray = gson.toJsonTree(arraylist).getAsJsonArray();
		response.setContentType("application/json");	
		response.getWriter().print(myCustomArray);				

		Statement stmt = con.createStatement();
		
		String drop = "drop table if exists p_u_t;";
        stmt.executeUpdate(drop);
        String create = "create table p_u_t as (select * from u_t);";
        stmt.executeUpdate(create);
        
        String query = "delete from u_t";
        stmt.executeUpdate(query);
		con.close();
			
	} catch (Exception e) {
		e.printStackTrace();
	}
}



%>

</body>
</html>