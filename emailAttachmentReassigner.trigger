trigger emailAttachmentReassigner on Attachment (before insert) {
	map<id, id> msgIdToParentId = new map<id, id>();
	Attachment[] reparents = new Attachment[]{};
		
	for(Attachment a : trigger.new) {
		if(a.parentid != null){
			// Check the parent ID - if it's 02s, this is for an email message
			if(string.valueof(a.parentid).substring(0, 3) == '02s') {
				msgIdToParentId.put(a.parentid, null);
				reparents.add(a);
			}
		}
	}
	
	if(!reparents.isEmpty()){
		for(EmailMessage em : [select id, parentID from EmailMessage where id =: msgIdToParentId.keyset()]){
			msgIdToParentId.put(em.id, em.parentId);
		}
	
		for(Attachment a : reparents) {
			a.parentId = msgIdToParentId.get(a.parentId);
		}
	}
	
}