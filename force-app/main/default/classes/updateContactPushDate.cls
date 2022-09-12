public class updateContactPushDate implements Database.Batchable<sObject> {
    private Map<Id, Account> accountMap;

    public updateContactPushDate(Map<Id,Account> accounts) {
        accountMap = accounts;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        //get all contacts related to the accounts
        Set<Id> accountIds = accountMap.keySet();
        return Database.getQueryLocator('SELECT ID, AccountId, Push_Date__c FROM Contact WHERE AccountId in :accountIds');
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> records){
        //map the contacts to their corresponding accounts
        Map<Id,List<Contact>> AccountContactMap = new Map<Id,List<Contact>>();
        List<Contact> contactsToUpdate = new List<Contact>();
        for(Contact c:  records){
            List<Contact> tempList = AccountContactMap.get(c.AccountId);
            if(tempList == null){
                tempList = new List<Contact>();
            }
            tempList.add(c);
            AccountContactMap.put(c.AccountId, tempList);
        }
        
        //check picklist "PushToVendor__c" and update corresponding Contacts for that account        
        for(String accountId : accountMap.keySet()) {
            Account acc = accountMap.get(accountId);
                if(acc.PushToVendor__c == 'Yes'){
                	List<Contact> contacts = AccountContactMap.get(acc.Id);
                    for(Contact c: contacts){
                        c.Push_Date__c = System.now();
                    	contactsToUpdate.add(c);
                    }
                }
        }
system.debug(contactsToUpdate);
        Update contactsToUpdate;
    }
    public void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }
}