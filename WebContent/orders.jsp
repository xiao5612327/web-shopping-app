<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*, java.util.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
</head>


<body>
<div class="collapse navbar-collapse">
	<ul class="nav navbar-nav">
		<li><a href="index.jsp">Home</a></li>
		<li><a href="categories.jsp">Categories</a></li>
		<li><a href="products.jsp">Products</a></li>
		<li><a href="orders.jsp">Orders</a></li>
		<li><a href="login.jsp">Logout</a></li>
	</ul>
</div>
<div>
<form action="orders.jsp" method="POST">
	<label># of queries to insert</label>
	<input type="number" name="queries_num">
	<input class="btn btn-primary"  type="submit" name="submit" value="insert"/>
</form>
<form action="orders.jsp" method="POST">
	<input class="btn btn-success"  type="submit" name="submit" value="refresh"/>
</form>

<form action="orders.jsp" method="POST">
	<input class="btn btn-primary"  type="submit" name="submit" value="run"/>
</form>
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
	
	ResultSet colResult = null;
	ResultSet rowResult = null;
	ResultSet row_col_Result = null;
	Statement stmt = conn.createStatement();
	Statement stmt2 = conn.createStatement();
	Statement stmt3 = conn.createStatement();
	
	
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("submit");
		if (action.equals("insert")) {
			int queries_num = Integer.parseInt(request.getParameter("queries_num"));
			Random rand = new Random();
			int random_num = rand.nextInt(30) + 1;
			if (queries_num < random_num) 
				random_num = queries_num;
			stmt = conn.createStatement();
			stmt.executeQuery("SELECT proc_insert_orders(" + queries_num + "," + random_num + ")");
			out.println("<script>alert('" + queries_num + " orders are inserted!');</script>");
		}
		else if (action.equals("refresh")) {
			//Need to implement.
		}
		
		else if (action.equals("run")) {

			String colSQL = "(select s.name as state, COALESCE(SUM(a.price), 0) AS sum "
				+"from users u "
				+"left outer join( "
								+"select o.user_id, o.price, o.quantity "
								+"from orders o "
								+"join products p "
								+"on o.product_id = p.id AND p.category_id > 0 "
								+") AS a "
				+"ON u.id = a.user_id "
				+"right outer join states s "
				+"ON s.id = u.state_id "
				+"GROUP BY s.name "
				+"ORDER BY sum DESC, s.name "
				+"LIMIT 50) ";
			
			String rowSQL = "(select p.id, p.name AS product_name, COALESCE(SUM(o.price), 0) AS sum "
					+" from ( "
							+"select * "
							+"from products p "
							+"where p.category_id > 0 "
							+") as p "
						+"LEFT OUTER JOIN orders o " 
						+"ON p.id = o.product_id "
						+"LEFT OUTER JOIN users u "
						+"ON u.id = o.user_id "
						+"GROUP BY p.id,  p.name "
						+"ORDER BY sum DESC  "
						+"LIMIT 50) ";
						
			String row_col_SQL = "select s.name AS state, p.id, COALESCE(SUM(o.price), 0) AS sum "
					+" from users u "
					+" RIGHT OUTER JOIN states s "
					+" ON s.id = u.state_id "
					+" cross join ( "
							+"select * from products p where p.category_id > 0 ) as p "
					+"INNER JOIN "
					+ colSQL +" l "
					+"ON l.state = s.name "
					+"INNER JOIN "
					+ rowSQL +" r "
					+"ON r.id = p.id "
					+"LEFT OUTER JOIN orders o "
					+"ON o.product_id = p.id and o.user_id = u.id "
					+"group by s.name, p.id, p.name, l.sum, r.sum "
					+"order by l.sum DESC, state, r.sum DESC, SUM DESC ";
			
			colResult = stmt.executeQuery(colSQL);
			rowResult = stmt2.executeQuery(rowSQL);
			row_col_Result = stmt3.executeQuery(row_col_SQL);
			String tempString = null;

			%>
			
			<table class="table table-striped">
			<%  
			%>
			<th><%="hello"%></th>
			<% 
			while(rowResult.next()){%>
					<th><b><% if(rowResult.getString("product_name").length() > 10)
								{ %> <%=(rowResult.getString("product_name")).substring(0,10) %> <%}
					else {%> <%=rowResult.getString("product_name") %> <%}%>

					<br /><%=" (" + Math.ceil(Double.valueOf(rowResult.getString("sum"))*100)/100+ ")"%> 
					</b></th>
			<% } %>
			<tr>
			<%
			
			while(colResult.next()){
			%>
			<tr>
				<td><%=colResult.getString("state") + " (" + 
						 Math.ceil(Double.valueOf(colResult.getString("sum"))*100)/100 + ")"%></td> 
				<%
				
				if (colResult.getString("state").equals(tempString)) { %>
					<td> <%=Math.ceil(Double.valueOf(row_col_Result.getString("sum"))*100)/100%> </td> <%
	            }
	            while(row_col_Result.next()) {
	            	tempString = row_col_Result.getString("state");
	            	   if (!tempString.equals(colResult.getString("state"))) {
      	                	break;
      	                }
	                %>
	                <td> <%=Math.ceil(Double.valueOf(row_col_Result.getString("sum"))*100)/100%> </td> <%
	                		
	            }
				%>
			</tr>
		
			<%
			}
			%>		
			</table>
<% 
		}
	}
	
%>
	

</body>
</html>