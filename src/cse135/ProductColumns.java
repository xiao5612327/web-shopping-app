package cse135;

public class ProductColumns {
	public String productName;
	public int productId;
	public int categoryId;
	public int total;

	/**
	 * @param id
	 * @param name
	 * @param description
	 * @param count
	 */
	public ProductColumns(String productName, int productId, int categoryId, int total) 
	{
		this.productName = productName;
		this.productId = productId;
		this.categoryId = categoryId;
		this.total = total;
	}

	public String getproductName() {
		return productName;
	}


	public int getproductId() {
		return productId;
	}
	
	public int gettotal() {
		return total;
	}
}
