@isTest
public class updateContactPushDate_Test {
    @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        
        for (Integer i=0;i<100;i++) {
            accounts.add(new Account(name='Account '+i,
                billingcity='New York', billingcountry='USA', PushToVendor__c = 'Yes'));
        }
        for (Integer i=0;i<100;i++) {
            accounts.add(new Account(name='Account '+i,
                billingcity='New York', billingcountry='USA', PushToVendor__c = 'No'));
        }
        insert accounts;

        for (Account account : [select id from account]) {
            contacts.add(new Contact(firstname='first',
                lastname='last', accountId = account.id));
        }
        insert contacts;
    }
    @isTest static void test() {
        Map<Id, Account> accountMap = new Map<ID, Account>([SELECT Id, PushToVendor__c FROM Account]);
        Test.startTest();
        updateContactPushDate ucpd = new updateContactPushDate(accountMap);
        Id batchId = Database.executeBatch(ucpd,200);
        Test.stopTest();
        System.assertEquals(100, [select count() from contact where Push_Date__c = TODAY ]);
    }
}