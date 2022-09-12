@isTest
public class AccountTriggerHandler_Test {
 @testSetup
    static void setup() {
        List<Account> accounts = new List<Account>();
        List<Contact> contacts = new List<Contact>();
        
        for (Integer i=0;i<2000;i++) {
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
    
    @isTest static void testUpdate200() {
        List<Account> accountList = [SELECT Id, PushToVendor__c FROM Account limit 150];
        Test.startTest();
        for(Account acc: accountList){
            acc.PushToVendor__c = 'Yes';
        }
        update accountList;
        
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(150, [select count() from contact where Push_Date__c = TODAY ]);
    }
    
    @isTest static void testUpdate500() {
        List<Account> accountList = [SELECT Id, PushToVendor__c FROM Account limit 500];
        Test.startTest();
        for(Account acc: accountList){
            acc.PushToVendor__c = 'Yes';
        }
        update accountList;
        
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(500, [select count() from contact where Push_Date__c = TODAY ]);
    }
    
    @isTest static void testUpdate1500() {
        List<Account> accountList = [SELECT Id, PushToVendor__c FROM Account limit 1500];
        Test.startTest();
        for(Account acc: accountList){
            acc.PushToVendor__c = 'Yes';
        }
        update accountList;
        
        Test.stopTest();
        // after the testing stops, assert records were updated properly
        System.assertEquals(1500, [select count() from contact where Push_Date__c = TODAY ]);
    }
}