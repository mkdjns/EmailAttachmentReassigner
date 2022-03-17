trigger emailAttachmentReassigner on Attachment (before insert) {
	map<id, id> msgIdToParentId = new map<id, id>();
	Attachment[] reparents = new Attachment[]{};
	Schema.sObjectType email = emailmessage.getsobjecttype();

	for(Attachment a : trigger.new) {
		if(a.parentid != null){
			//see if the parent is an EmailMessage
			if(a.parentid.getsobjecttype() == EmailMessage.getsObjectType()) {
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
