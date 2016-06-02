package cse135;

public class StateProductIdPair {
	public Integer stateId;
	public Integer productId;
	public boolean visited;
	
	public StateProductIdPair (Integer stateId, Integer productId, boolean visited)
	{
		this.stateId= stateId;
		this.productId = productId;
		this.visited = visited;
	}

	public int hashCode(){
		int hashcode = 0;
		hashcode = 20;
		hashcode += stateId.hashCode();
		return hashcode;
	}
    public Integer getSid(){
        return stateId;
    }
    public Integer getproductId(){
        return productId;
    }
	public boolean equals(Object obj){
		if (obj instanceof StateProductIdPair) {
			StateProductIdPair pair = (StateProductIdPair) obj;
			return (pair.stateId.equals(this.stateId) && pair.productId.equals(this.productId));
		} else {
			return false;
		}
	}
}
