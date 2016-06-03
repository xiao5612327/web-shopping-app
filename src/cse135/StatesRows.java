package cse135;

public class StatesRows {

	public String stateName;
	public int stateId;
	public double total;

	public StatesRows(String stateName, int stateId, double total) 
	{
		this.stateName = stateName;
		this.stateId = stateId;
		this.total = total;
	}

	public String getstateName() {
		return stateName;
	}

	public double gettotal() {
		return total;
	}
		
	public int getstateId() {
		return stateId;
	}

}
