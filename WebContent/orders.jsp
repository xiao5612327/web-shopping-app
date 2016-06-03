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
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.List" %>
<%@ page import="cse135.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*"%>

<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
<script type="text/javascript">
function makeRequest(lastId)
{
	$.ajax(
	{
	  type: 'POST',
	  url: "/cse135-for-project3/ajax.jsp?lastId="+lastId,
	  dataType:'json',
	  beforeSend:function(){
		//Update Stats
		$('#status').html('Request Sent');
	  },
	  success:function(response){
		  var response = String(data);
		  var array = eval("[" + response + "]");
		  updateTable(array);
	  },
	  error:function(){
		// Failed request
		$('#status').html('Oops! Error.');
	  }
	});		
}


function updateTable(array)
{
	for(var i = 0; i < array.length; i= i+4)
	{				
		var order_id 	= array[i];	
		var state_id 	= array[i + 1];	
		var product_id 	= array[i + 2];
		var amount 		= array[i + 3];
		
		var cellResult = document.getElementById("sid" + eval(sid) + "pid" + eval(pid) ); 
		
		if(cellResult != null)
		{
			cellResult.innerHTML = eval(eval(cellResult.innerHTML) + amount);	
			cellResult.style.color = "red";
		}
		var stateResult = document.getElementById("sid" + eval(sid)); 
		if(stateResult != null)
		{
			stateResult.innerHTML = "("+eval(eval(stateResult.innerHTML) + price) + ")";	
			stateResult.style.color = "red";
		}	
		
		var productResult = document.getElementById("pid" + eval(pid));  
		
		if(productResult != null)
		{
			productResult.innerHTML = "("+eval(eval(productResult.innerHTML) + price) +")";
			productResult.style.color = "red";
		}		
	}	
}
</script>


<%
	int latestIDthisScope;

	HashMap<StateProductIdPair, Integer> hashmap = new HashMap<StateProductIdPair, Integer>();
	List<ProductColumns> productsList = new ArrayList<ProductColumns>();
	List<StatesRows> statesList = new ArrayList<StatesRows>();


	Connection conn = null;
	try {
		Class.forName("org.postgresql.Driver");
		   String url = "jdbc:postgresql://localhost:5433/shopping";
		  	String admin = "postgres";
		  	String password = "Asdf!23";
  	conn = DriverManager.getConnection(url, admin, password);
	}
	catch (Exception e) {}
	
	String filters;
	
	
	ResultSet colResult = null;
	ResultSet rowResult = null;
	ResultSet row_col_Result = null;
	Statement stmt = conn.createStatement();
	Statement stmt2 = conn.createStatement();
	Statement stmt3 = conn.createStatement();
	
	if(request.getParameter("filter") == null){
		filters = "All";
	}
	else {
		filters = request.getParameter("filter");
	}
	
	ResultSet rs = stmt.executeQuery("SELECT * FROM categories ");
	
	String categoryFilter = filters.equals("All") ? "p.category_id > 0" : "p.category_id =" + filters;
%>

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
	</div>
	<form action="orders.jsp" method="POST">
		<input class="btn btn-success"  type="submit" name="submit" value="refresh"/>
	</form>
	
	
	<form action="orders.jsp" method="post">
	<div class="form-group">
	  	<label for="filter">Sales Filtering</label>
		<select name="filter" id="filter" class="form-control">
			<option value="All">All</option>
			<% while (rs.next()) { %>
				<option value="<%=rs.getString("id")%>"><%=rs.getString("name")%></option>
			<% } %>
		</select>
	</div>
		<input class="btn btn-primary"  type="submit" name="submit" value="run"/>
	</form>
	
	
<% 
	


	
	 %>

 <% 
	if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("submit");
		if (action.equals("insert")) {
			//get the latest order id
			stmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT id FROM orders ORDER BY id DESC LIMIT 1");
			rs.next();
			int latestID = rs.getInt("id");
			System.out.println(latestID);
			
			int queries_num = Integer.parseInt(request.getParameter("queries_num"));
			Random rand = new Random();
			int random_num = rand.nextInt(30) + 1;
			if (queries_num < random_num) 
				random_num = queries_num;
			stmt = conn.createStatement();
			stmt.executeQuery("SELECT proc_insert_orders(" + queries_num + "," + random_num + ")");
			out.println("<script>alert('" + queries_num + " orders are inserted!');</script>");
			
			stmt = conn.createStatement();
			/*
			ResultSet neworders = stmt.executeQuery("SELECT s.id, o.product_id, (o.quantity * o.price) as amount "
					+ " FROM states s, orders o, users u "
					+ " WHERE u.state_id = s.id AND o.id > " + latestID + " AND o.user_id = u.id");
			while(neworders.next()) {
				String insertquery = "INSERT INTO u_t(sid, pid, amount)"
									+ " VALUES ("+neworders.getInt(1)+", "+neworders.getInt(2)+", "+neworders.getInt(3)+");";
				stmt = conn.createStatement();
				stmt.execute(insertquery);
			}
			*/
			ResultSet neworders = stmt.executeQuery("SELECT o.id, s.id, o.product_id, (o.quantity * o.price) as amount "
					+ " FROM states s, orders o, users u "
					+ " WHERE u.state_id = s.id AND o.id > " + latestID + " AND o.user_id = u.id");
			while(neworders.next()) {
				String insertquery = "INSERT INTO log_table(order_id, state_id, product_id, amount)"
									+ " VALUES ("+neworders.getInt(1)+", "+neworders.getInt(2)+", "+neworders.getInt(3)+", "+neworders.getInt(4)+");";
				stmt = conn.createStatement();
				stmt.execute(insertquery);
			}
			
		}		
		else if (action.equals("run") || action.equals("refresh") ) { 
			if (action.equals("request")){
				%> <script> makeRequest(latestIDthisScope) </script><%
			}
				
			if (action.equals("run")) {
			stmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT id FROM orders ORDER BY id DESC LIMIT 1");
			rs.next();
			latestIDthisScope = rs.getInt("id");
			
			String query1 = "drop table if exists products_precomputed;";
			stmt.executeUpdate(query1);
			String query2 = "drop table if exists states_precomputed;";
			stmt.executeUpdate(query2);
			String query3 = "drop table if exists cell_precomputed;";
			stmt.executeUpdate(query3);
				        
			
			String index2 = "create index bb on orders(product_id)";
			stmt.executeUpdate(index2);
			
			String queryS = "CREATE TABLE states_precomputed AS "
					+ " SELECT st.name, st.id AS sid, SUM(s.quantity*s.price) AS price "
					+ " FROM states st "
					+ " LEFT OUTER JOIN users u "
					+ " ON st.id = u.state_id"
					+ " LEFT OUTER JOIN orders s "
					+ " ON s.user_id=u.id"
					+ " GROUP BY st.id, st.name"
					+ " ORDER BY price DESC nulls last";
			stmt.executeUpdate(queryS);
					
			String queryP = "CREATE TABLE products_precomputed AS "
					+ " SELECT p.name, p.id AS pid, p.category_id, COALESCE( SUM(s.quantity * s.price), 0 ) AS price "
					+ " FROM products p "
					+ " JOIN categories c"
					+ " ON p.category_id = c.id"
					+ " LEFT OUTER JOIN orders s "
					+ " ON s.product_id = p.id  "
					+ " GROUP BY p.id, p.name "
					+ " ORDER BY price DESC nulls last";
			stmt.executeUpdate(queryP);
			
			String queryC = "CREATE TABLE cell_precomputed AS"
					+ " SELECT u.state_id, s.product_id, SUM(s.quantity * s.price) "
					+ " FROM users u, orders s "
					+ " WHERE s.user_id = u.id "
					+ " GROUP BY u.state_id, s.product_id";
			stmt.executeUpdate(queryC);     
			
			
			String indexDrop2 = "drop index bb ";
			stmt.executeUpdate(indexDrop2);
			}
			//Filling in statesList
			String query = "SELECT * FROM states_precomputed"
							+ " ORDER BY price DESC NULLS LAST"
							+ " LIMIT 50";
			rs = stmt.executeQuery(query);
			while(rs.next()) {
				String stateName = rs.getString("name");
				Integer stateId = rs.getInt("sid");
				double total = rs.getDouble("price");
				statesList.add(new StatesRows(stateName, stateId, total));
			}
				
			query = "SELECT * FROM products_precomputed p"
					+ " WHERE " + categoryFilter
					+ " ORDER BY price DESC NULLS LAST LIMIT 50";
			rs = stmt.executeQuery(query);
			while (rs.next()) {
				String productName = rs.getString(1);
				Integer productId = rs.getInt(2);
				Integer categoryId = rs.getInt(3);
				double total = rs.getDouble(4);
				productsList.add(new ProductColumns(productName, productId, categoryId, total));    	            
			}
			 
			 
			query = "SELECT * FROM cell_precomputed x "
					+ " WHERE x.state_id IN (SELECT sid FROM states_precomputed ORDER BY price DESC NULLS LAST LIMIT 50)"
					+ " AND x.product_id IN (SELECT pid FROM products_precomputed ORDER BY price DESC NULLS LAST LIMIT 50)";
			rs = stmt.executeQuery(query);
			while (rs.next()) {
			   	Integer stateId = rs.getInt(1);
			    Integer productId = rs.getInt(2);
			    Integer total = rs.getInt(3);
			    hashmap.put(new StateProductIdPair(stateId, productId, true),total);
			}
		}

		%>
			<table 
			class="table table-striped"
			align="center">
		 	<thead>
		 		<tr align="center">
		 			<th> States </th>
		 			<%	 				
						for(ProductColumns pr : productsList)
				    	{							
					%>
					<th>
							<%=pr.productName%>
							<div id = <%="pid"+ Integer.toString(pr.productId) %> >
							<%=pr.total%></div>
					</th>
					<% 
						}
					%>  		
				<tr>
			</thead>
			<tbody> 
				<%
					//int cols = 0; // Columns
					int rows = 0; // rows
					while(rows < productsList.size())
					{					
				%>
				<tr>
					<td>
						<b> <%= statesList.get(rows).stateName %></b>			 
						<b><div id = <%="sid" + Integer.toString(statesList.get(rows).stateId) %>>
						<%= statesList.get(rows).total %>
						</div></b>
						 
					</td>
				<%
						for(ProductColumns pcIter : productsList)
						{
							StateProductIdPair getPair = new StateProductIdPair(statesList.get(rows).stateId, pcIter.productId, true);
							if(hashmap.get(getPair) == null){
								%>
								<td id = <%="sid" + Integer.toString(statesList.get(rows).stateId) + "pid" + Integer.toString(pcIter.productId) %>>
								<%=0%>
								</td>
								<%
							}
							else{
								%>
								<td id = <%="sid" + Integer.toString(statesList.get(rows).stateId) + "pid" + Integer.toString(pcIter.productId) %>>
								<%=hashmap.get(getPair)%></td>
								<%
								
							}
		    			}
						rows++;
					}
				%>			  				
		    </tbody>
		</table>
	<% } %>

	

</body>
</html>