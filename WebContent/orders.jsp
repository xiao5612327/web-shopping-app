<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.sql.*, javax.naming.*"%>
<%!
    private final int numRows = 20;
    private final int numCols = 10;
    private final boolean timer = true;
    private long initTime, finalTime;

%>

    <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
<title>CSE135 Project</title>
</head>

<!--
if ("POST".equalsIgnoreCase(request.getMethod())) {
		String action = request.getParameter("submit");
		if (action.equals("insert")) {
			int queries_num = Integer.parseInt(request.getParameter("queries_num"));
			Random rand = new Random();
			int random_num = rand.nextInt(1) + 30;
			if (queries_num < random_num) random_num = queries_num;
			Statement stmt = conn.createStatement();
			stmt.executeQuery("SELECT proc_insert_orders(" + queries_num + "," + random_num + ")");
			out.println("<script>alert('" + queries_num + " orders are inserted!');</script>");
		}
		else if (action.equals("refresh")) {
			//Need to implement.
		}
	}

	-->
<body>
    <%-- INIT VARIABLES --%>
    <form action="orders.jsp" method="POST">
	<label># of queries to insert</label>
	<input type="number" name="queries_num">
	<input class="btn btn-primary"  type="submit" name="submit" value="insert"/>
</form>
<form action="orders.jsp" method="POST">
	<input class="btn btn-success"  type="submit" name="submit" value="refresh"/>
</form>
    <%
    if (timer) initTime = System.currentTimeMillis();
%>
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
	
	Statement stmt = conn.createStatement();
	Statement stmt2 = conn.createStatement();
	Statement stmt3 = conn.createStatement();

	
%>

<div class="collapse navbar-collapse">
	<ul class="nav navbar-nav">
		<li><a href="index.jsp">Home</a></li>
		<li><a href="categories.jsp">Categories</a></li>
		<li><a href="products.jsp">Products</a></li>
		<li><a href="orders.jsp">Orders</a></li>
		<li><a href="similarProducts.jsp">Similar Products</a></li>
		<li><a href="login.jsp">Logout</a></li>
	</ul>
</div>

<% 
	String rows, order, filter;
	String action = request.getParameter("action");
	int columnOffset = 0;
	int rowOffset = 0;
	
	// Check if one of the two buttons was pressed, so we can grab the previous criteria passed on from the button
	if(request.getParameter("filter") != null)
	{
		rows = request.getParameter("rows");
		order = request.getParameter("order");
		filter = request.getParameter("filter");
	}
	// Otherwise we haven't set any criteria. 
	else {
	    rows = "Customers";
	    order = "Alphabetical";
	    filter = "All";
	}
	// action relates to which button was pressed i.e. "Next 20 customers" or "Next 10 products". Will implement later.
	if (action != null) {
	    columnOffset = Integer.parseInt(request.getParameter("columnOffset"));
	    rowOffset = Integer.parseInt(request.getParameter("rowOffset"));
	    // Keep track of internal counter to set OFFSET. No need for vectors/lists to hold the next values.
	    if (action.equals("nextColumn")) {
	        columnOffset += numCols;
	    }
	    else if(action.equals("nextRow")) {
	        rowOffset = rowOffset + numRows;
		}
	}

	String topRowFilter = order.equals("Alphabetical") ? "p.name" : "sum DESC";
	String orderProductFilter = order.equals("Alphabetical") ? "u.name, p.name" : "l.sum DESC, u.id, r.sum DESC, sum DESC";
	String orderCustomerFilter = order.equals("Alphabetical") ? "u.name" : "sum DESC, u.id";
	String orderStateColumnFilter = order.equals("Alphabetical") ? "u.state" : "sum DESC, u.state";
	String orderStateRowFilter = order.equals("Alphabetical") ? "u.state, p.name" : "l.sum DESC, state, r.sum DESC, sum DESC";
	
	// category filter
	String categoryFilter = filter.equals("All") ? "p.category_id > 0" : "p.category_id=" + filter;
	// Query that depends on whether we are looking at a specific category or all categories
	String orderTable = "(SELECT o.user_id, o.price, o.quantity"
	        	 	  + " FROM orders o JOIN products p ON o.product_id = p.id AND " + categoryFilter +") s";
	
	// ----------------------------------------------------------------
	// PRODUCTS TEMP TABLE. Contains all products under the category filter e.g. "All", "labtop", etc.
	String tempProducts = "(SELECT * FROM products p WHERE "+categoryFilter+")";

	// Drop previous instantiations of the tables because criteria can change and we don't want leftover tables
	//stmt.executeUpdate("DROP TABLE IF EXISTS tempProducts");
	//stmt.executeUpdate(tempProducts);
	
	
	
	String topRowInfo, leftColumnInfo, rowByColumnInfo;
	String EXPLAINTOPROW, EXPLAINLEFTCOLUMN, EXPLAINSEARCH;
	// top row info. Gives product name and total money made from the product across all users/orders
	// coalesce returns the first value i.e. if there's no order for a certain product, there will still be a row dedicated to show that the user spent $0 on a product
	topRowInfo = "(SELECT p.id, p.name AS product_name, COALESCE(SUM(o.price), 0) AS sum"
               + " FROM " + tempProducts + " AS p"
               + " LEFT OUTER JOIN orders o ON p.id=o.product_id"
               + " LEFT OUTER JOIN users u ON u.id=o.user_id"
               + " GROUP BY p.id, p.name ORDER BY " + topRowFilter
               + " LIMIT "+(numCols)+" OFFSET "+columnOffset+")";
	EXPLAINTOPROW = "EXPLAIN " + topRowInfo;
	             
	// states
    if (rows.equals("States")) {
        
        
    	// Gives table of sale by state's alphabetical or revenue order depending on orderStateColumnFilter 
        leftColumnInfo = 
                "(SELECT u.state AS state, COALESCE(SUM(s.price), 0) AS sum"
              + " FROM users u"
              + " LEFT OUTER JOIN "+orderTable+" ON u.id = s.user_id"
              + " GROUP BY u.state ORDER BY " + orderStateColumnFilter
	          + " LIMIT "+(numRows)+" OFFSET "+rowOffset+")";
    	
        // Gives table of each states' amount of money spent for each product
        rowByColumnInfo = "SELECT u.state AS state, p.id, COALESCE(SUM(o.price), 0) AS sum"
		                + " FROM users u"
		                + " CROSS JOIN " + tempProducts + " AS p"
		                + " INNER JOIN " + leftColumnInfo + " l ON l.state = u.state"
		                + " INNER JOIN " + topRowInfo + " r ON r.id = p.id"
		                + " LEFT OUTER JOIN orders o ON o.product_id=p.id AND o.user_id = u.id"
		                + " GROUP BY u.state, p.id, p.name, l.sum, r.sum ORDER BY " + orderStateRowFilter;
        EXPLAINLEFTCOLUMN = "EXPLAIN " + leftColumnInfo;
        EXPLAINSEARCH = "EXPLAIN " + rowByColumnInfo;
    }
	// customers
    else
    {
    	leftColumnInfo = "(SELECT u.id AS id, u.name AS name, COALESCE(SUM(s.price), 0) AS sum"
		               + " FROM users u "
		               + " LEFT OUTER JOIN "+orderTable+" ON u.id=s.user_id"
		               + " GROUP BY u.id, u.name ORDER BY " + orderCustomerFilter
			           + " LIMIT "+(numRows)+" OFFSET "+rowOffset+")";
    	
        rowByColumnInfo = "SELECT u.id AS id, p.id, u.name, p.name, COALESCE(SUM(o.price), 0) AS sum"
			            + " FROM users u"
				        + " CROSS JOIN " + tempProducts + " AS p"
			            + " INNER JOIN " + leftColumnInfo + " l ON l.id = u.id"
			            + " INNER JOIN " + topRowInfo + " r ON r.id = p.id"
			            + " LEFT OUTER JOIN orders o ON o.product_id = p.id AND o.user_id = u.id"
			            + " GROUP BY u.id, p.id, u.name, p.name, l.sum, r.sum"
			            + " ORDER BY " + orderProductFilter;
        EXPLAINLEFTCOLUMN = "EXPLAIN " + leftColumnInfo;
        EXPLAINSEARCH = "EXPLAIN " + rowByColumnInfo;
    }
    ResultSet rsEXPLAINTOPROW = stmt.executeQuery(EXPLAINTOPROW);
    while(rsEXPLAINTOPROW.next()){ 

        System.out.println(rsEXPLAINTOPROW.getString(1));
   
    } 
    
    ResultSet rsEXPLAINLEFTCOLUMN = stmt.executeQuery(EXPLAINLEFTCOLUMN);
    while(rsEXPLAINLEFTCOLUMN.next()){ 

        System.out.println(rsEXPLAINLEFTCOLUMN.getString(1));
   
    } 
    ResultSet rsEXPLAINSEARCH = stmt.executeQuery(EXPLAINSEARCH);
     while(rsEXPLAINSEARCH.next()){ 

         System.out.println(rsEXPLAINSEARCH.getString(1));
    
     } 
     	ResultSet rs = stmt.executeQuery("SELECT * FROM categories");
%>
<% if(rowOffset == 0 && columnOffset == 0) { %>
<div>
<form action="orders.jsp" method="post">
	<div class="form-group">
	  	<label for="rows">Rows</label>
		<select name="rows" id="rows" class="form-control">
			<option value="Customers">Customers</option>
			<option value="States">States</option>
		</select>
	</div>
	<div class="form-group">
	  	<label for="order">Order</label>
		<select name="order" id="order" class="form-control">
			<option value="Alphabetical">Alphabetical</option>
			<option value="Top-K">Top-K</option>
		</select>
	</div>
	<div class="form-group">
	  	<label for="filter">Sales Filtering</label>
		<select name="filter" id="filter" class="form-control">
			<option value="All">All</option>
			<% while (rs.next()) { %>
				<option value="<%=rs.getString("id")%>"><%=rs.getString("name")%></option>
			<% } %>
		</select>
	</div>
	<div class="form-group">
  		<input class="btn btn-primary" type="submit" value="Run Query">
  	</div>
</form>
</div>
<%} %>
    <%
    String CorS;
    // next rows button
    // get number of products available. todo figure out how to get exact number since the table is limited to the max
    rs = stmt.executeQuery("SELECT count(*) AS cnt FROM "+topRowInfo + " AS k");
    if (rs.next() && (rs.getInt("cnt") == (numCols))) {
        %>
        <form action="" method="POST">
            <input type="hidden" name="action"  value="<%="nextColumn" %>" />
            <input type="hidden" name="rows"     value="<%=rows %>"/>
            <input type="hidden" name="order"   value="<%=order %>"/>
            <input type="hidden" name="filter"     value="<%=filter %>"/>
            <input type="hidden" name="columnOffset" value="<%=columnOffset %>"/>
            <input type="hidden" name="rowOffset" value="<%=rowOffset %>"/>
            <input class="btn btn-default btn-sm"
                   type="submit" value="Next <%=numCols %> <%="Products" %> >>" />
        </form>
     
    <%   
    }
    CorS = rows;
    rs = stmt.executeQuery("SELECT count(*) AS cnt FROM "+leftColumnInfo + " AS l");
    if (rs.next() && (rs.getInt("cnt") == (numRows))) {
        %>
        <form action="" method="POST">
            <input type="hidden" name="action"  value="<%="nextRow" %>" />
            <input type="hidden" name="rows"     value="<%=rows %>"/>
            <input type="hidden" name="order"   value="<%=order %>"/>
            <input type="hidden" name="filter"     value="<%=filter %>"/>
            <input type="hidden" name="columnOffset" value="<%=columnOffset %>"/>
            <input type="hidden" name="rowOffset" value="<%=rowOffset %>"/>
            <input class="btn btn-default btn-sm"
                   type="submit" value="Next <%=numRows %> <%=CorS %> >>" />
        </form>
    <%   
    } 
    if ("POST".equalsIgnoreCase(request.getMethod())) { %>
	<table class="table table-striped">
		<%
		// Has all product names and revenue under category filter
		rs = stmt.executeQuery(topRowInfo);

		%>
		<th><%= request.getParameter("rows") %></th>
		<% 
		while(rs.next()){%>
				<th><b><% if(rs.getString("product_name").length() > 10)
							{ %> <%=(rs.getString("product_name")).substring(0,10) %> <%}
				else {%> <%=rs.getString("product_name") %> <%}%>

				<br /><%=" (" + Math.ceil(Double.valueOf(rs.getString("sum"))*100)/100+ ")"%> 
				</b></th>
		<% } %>
		<tr>
		<%
		// Helps us keep track of the first product to display in each row
			int productTracker = -1;
			String tempString = null;
			stmt = conn.createStatement();
			rows = request.getParameter("rows");
			ResultSet rowResult;
			ResultSet rowSales;
			if (rows.equals("Customers")) {
				rowResult = stmt2.executeQuery(leftColumnInfo);
				rowSales = stmt3.executeQuery(rowByColumnInfo);
				while(rowResult.next()){
		        	%>
				<tr>
					<td><b><% if(rowResult.getString("name").length() > 10)
					{ %> <%=rowResult.getString("name").substring(0,10) %> <%}
				   else {%> <%=rowResult.getString("name") %> <%}%> <%=" (" + 
					// TEMP STUFF FOR MONEY SPENT
							 Math.ceil(Double.valueOf(rowResult.getString("sum"))*100)/100 + ")"%></b></td> 
					<%
					if (productTracker == rowResult.getInt("id")) { %>
						<td> <%=Math.ceil(Double.valueOf(rowSales.getString("sum"))*100)/100%> </td> <%
		            }
		            while(rowSales.next()) {
		            	productTracker = rowSales.getInt("id");
		                if (productTracker != rowResult.getInt("id")) {
		                    break;
		                }
		                %>
		                <td> <%=Math.ceil(Double.valueOf(rowSales.getString("sum"))*100)/100%> </td> <%
		            }
					%>
				</tr>
			<%
				}
			}	
			
			else if (rows.equals("States")) {
				rowResult = stmt2.executeQuery(leftColumnInfo);
				rowSales = stmt3.executeQuery(rowByColumnInfo);
				while(rowResult.next()){%>
				<tr>
					<td><%=rowResult.getString("state") + " (" + 
// 							 TEMP STUFF FOR MONEY SPENT
							 Math.ceil(Double.valueOf(rowResult.getString("sum"))*100)/100 + ")"%></td> 
					<%
					
					if (rowResult.getString("state").equals(tempString)) { %>
						<td> <%=Math.ceil(Double.valueOf(rowSales.getString("sum"))*100)/100%> </td> <%
		            }
		            while(rowSales.next()) {
		            	tempString = rowSales.getString("state");
		                if (!tempString.equals(rowResult.getString("state"))) {
		                	break;
		                }
		                %>
		                <td> <%=Math.ceil(Double.valueOf(rowSales.getString("sum"))*100)/100%> </td> <%
		            }
					%>
				</tr>
			<%
				}
			}	
			//rs = stmt.executeQuery("SELECT name FROM products");
		%>
		<%if (timer) {
            finalTime = System.currentTimeMillis() - initTime;
            System.out.println("final time is " + finalTime + " ms = " + (float)finalTime/1000 + "sec\n");
        }%>
	</table>
<% } %>
</body>
</html>