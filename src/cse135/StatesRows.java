package cse135;

public class StatesRows {

	public String stateName;
	public int stateId;
	public int total;

	public StatesRows(String stateName, int stateId, int total) 
	{
		this.stateName = stateName;
		this.stateId = stateId;
		this.total = total;
	}

	public String getstateName() {
		return stateName;
	}

	public int gettotal() {
		return total;
	}
		
	public int getstateId() {
		return stateId;
	}

}
