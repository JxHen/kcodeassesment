public class AccountTriggerHandler extends TriggerHandler {
    
    public override void afterUpdate() {
        //get all contacts related to all triggering accounts
        List<Contact> AccountContacts = [SELECT ID, AccountId FROM Contact WHERE AccountId in :Trigger.newMap.keySet()];
        Map<Id,List<Contact>> AccountContactMap = new Map<Id,List<Contact>>();
        List<Contact> contactsToUpdate = new List<Contact>();
        //relate each contact to an account by id
        for(Contact c:  AccountContacts){
            List<Contact> tempList = AccountContactMap.get(c.AccountId);
            if(tempList == null){
                tempList = new List<Contact>();
            }
            tempList.add(c);
            AccountContactMap.put(c.AccountId, tempList);
        }
        
        if(AccountContacts.size() < 200){            
            for(Account a : (List<Account>) Trigger.new) {
                //check picklist and update corresponding Contacts for that account
                if(a.PushToVendor__c == 'Yes'){
                	List<Contact> contacts = AccountContactMap.get(a.Id);
                    for(Contact c: contacts){
                        c.Push_Date__c = System.now();
                    	contactsToUpdate.add(c);
                    }
                }
            }
            
            Update contactsToUpdate;
        }else if(AccountContacts.size() >= 200 && AccountContacts.size() < 1000 ){
            updateContactPushDate ucpd = new updateContactPushDate((Map<Id,Account>)Trigger.newMap);
            Id batchId = Database.executeBatch(ucpd, 1000);
        }else {
            updateContactPushDate ucpd = new updateContactPushDate((Map<Id,Account>)Trigger.newMap);
            Id batchId = Database.executeBatch(ucpd, 150);
        }
    }

}