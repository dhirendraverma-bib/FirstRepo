//PageBlockTableSortingCon
public class Account_Searcher {
 
 //public String searchString {public get; public set;}
 //public List<String> accountList {get; set;}
 public String delID {get;set;}
 //public String getAccID {get;set;}
 
    
 //Search fields   
 public String searchTerm {get; set;}
 //public String selectedAcc {get; set;}
  public Integer countOfLst {get; set;}
 public Event tracker{get; set;}
 
 public Account_Searcher (){ 
      
      tracker = new Event();
      //build the full sort expression
      string sortFullExp = sortExpression  + ' ' + sortDirection;      
      //query the database based on the sort expression
           
      /* Start*/
      getData();     
      /* End */
      
      //accounts = Database.query('Select id, Name, BillingCity, BillingCountry, Phone from Account order by ' + sortFullExp + ' limit 1000');            
      //string sortFullExpname = '%Sun%';
      //accounts = Database.query('Select id, Name, BillingCity, BillingCountry, Phone from Account where name like : sortFullExpname order by ' + sortFullExp + ' limit 1000');
 } 
 
   private List<Account> accounts;
   private List<Account> Taccounts;
   private String sortDirection = 'ASC';
   private String sortExp = 'name';

 public String sortExpression
   {
     get
     {
        return sortExp;
     }
     set
     {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
   }

 public String getSortDirection()
 {
    //if not column is selected 
    if (sortExpression == null || sortExpression == '')
      return 'ASC';
    else
     return sortDirection;
 }

 public void setSortDirection(String value)
 {  
   sortDirection = value;
 }
  
   public List<Account> getAccounts() { 
       return accounts;
   }
   
   //accountsTrue
   public List<Account> getTAccounts() { 
       return Taccounts;
   }

    
    public PageReference SaveEvent()
    {
        System.debug('test >>>>>>> called SaveEvent');
        string accid = ApexPages.currentPage().getParameters().get('param');
        tracker.OwnerId = UserInfo.getUserId();      
        tracker.Subject = 'Fleet Tyre Inspection';              
        tracker.WhatId = accid;
        //tracker.AccountId = accid;
        
        System.debug('test >>>>> StartDateTime'+tracker.StartDateTime + '@@@@@@@@@@@@@@@@@@@@@ EndDateTime : '+tracker.EndDateTime);
        System.debug('test >>>>> '+accid + '@@@@@@@@@@@@@@@@@@@@@ '+tracker.Description);
        
        if( (tracker.EndDateTime != null) && (tracker.StartDateTime != null)  )
                insert tracker;
                
        System.debug('@@@@@@@@@@@@@@@@@@@@@ Completed');
        return null;    
    }

    public boolean TacRecords{get;set;}
    public PageReference SaveData() 
    {
        List<Account> lstA = new List<Account>();
        List<Account> lstANew = new List<Account>();
        for (Account acc :  accounts){
        if(acc.Tyrecheck__c){
                    lstANew.add(acc);
                }
        } 
        for (Account acc :  Taccounts){            
                lstANew.add(acc);           
        } 
        if(lstANew.size() <=10){
            lstANew = new List<Account>();
            for (Account acc :  accounts){
            
            if(acc.Tyrecheck__c)
            {
                    System.debug('TEST RECORD FOUND : '+ acc.Name);
                    TacRecords = false;
                    lstA.add(acc);
                    Taccounts.add(acc);
            } 
            else{
                lstANew.add(acc);          
            }
         }
         accounts.clear();
         for (Account acclst :  lstANew){
             accounts.add(acclst);
         }
             update lstA;
             PageReference pageRef = new PageReference('/apex/vf_Account_Searcher_one');
            pageRef.setRedirect(true);
            return pageRef; 
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You cannot have more than 10 selected fleets'));
            return null;
        }
    //    return null;
    }
        
    
    public PageReference RemoveAllTData() 
    { 
        system.debug('RemoveAllTData>>>>>>>>>>>>>>>>>');
        if(Taccounts.size() > 0)
        {
            List<Account> lst = Taccounts;
            List<Account> lst1 = new List<Account>();  
            for (Account acc :  lst){           
                acc.Tyrecheck__c = false;
                lst1.add(acc);                  
        } 
            
            update lst1;
            
            Taccounts = lst1; 
            Taccounts.clear();
            
            PageReference pageRef = new PageReference('/apex/vf_Account_Searcher_Second');
            pageRef.setRedirect(true);
            return pageRef;                     
     }        
     return null;    
    }
    
    public PageReference RemoveByIDTData()
    {               
        System.debug('@@@@@@## : '+ delID);
        Account a = [ Select Tyrecheck__c  from Account where Id =: delID ];
        a.Tyrecheck__c = false;
        update a;      
        
        PageReference pageRef = new PageReference('/apex/vf_Account_Searcher_One');
        pageRef.setRedirect(true);
        return pageRef; 
 
    }     
 
   public PageReference ViewData() {
       //build the full sort expression
       string sortFullExp = sortExpression  + ' ' + sortDirection;
      
       //query the database based on the sort expression
       //accounts = Database.query('Select id, Name, BillingCity, BillingCountry, Phone from Account order by ' + sortFullExp + ' limit 1000');
              
      /* Start*/
      getData();     
      /* End */
                    
       return null;
   }
   
   public void getData()
   {
     this.searchTerm = String.isBlank(this.searchTerm) ? '' : this.searchTerm;
     String s = '%'+searchTerm+'%';
     system.debug('@@@searchTerm'+s);
       
     //---------------------------  
       
     List<string> lstID = new List<string>();
     id iid = UserInfo.getUserId();
     //Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Site').getRecordTypeId();
     Id devRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'account' and DeveloperName ='Site'].ID;
     
    for(UserTerritory2Association a : [SELECT Territory2ID from UserTerritory2Association where UserID =: iid])
    {       
            lstID.add(a.Territory2ID);    
    }    
    System.debug('>>>>>>>>> Territory2ID : '+lstID);
       
       List<Group> map_group = [Select Id, RelatedId from Group where Type='Territory' AND RelatedId =: lstID];
       
     //---------------------------  
       
      //List<Group> map_group = [Select Id, RelatedId from Group where Type='Territory' AND RelatedId =: '0MI4E0000004IKU'];
      System.debug('TEST : '+map_group);
      List<AccountShare> lst_AccountShare = [Select Id, UserOrGroupId, AccountId from AccountShare where 
                                       (UserOrGroupId IN : map_group) AND 
                                       RowCause IN ('Territory', 'TerritoryManual', 'TerritoryRule')];

        System.debug('TEST 2 : '+ lst_AccountShare);  System.debug('TEST 2 : '+ lst_AccountShare.size()); 

        List<Id> ls1 = new List<Id>();
        for(AccountShare a : lst_AccountShare)
            {
                ls1.add(a.AccountId); //System.debug('Account ID : ' + a.AccountId );                
            }
            
            

        System.debug('Account ID : ' + ls1 );
        List<Account> lst_Account = [Select id, Name, Phone, Tyrecheck__c, ShippingStreet, ShippingCity, 
                                     ShippingState, ShippingCountry, ShippingPostalCode,Legacy_Id__c, CreatedDate
                                    from Account where (Id IN : ls1) 
                                     AND name like :s 
                                     and Type__c = 'PROF_END_USER'
                                     AND RecordTypeId =: devRecordTypeId limit 1000
                                     ];    
                                     
       
       system.debug('@@@Lst_Account' + lst_Account);
        
        
        List<Account> lstAT = new List<Account>();
        List<Account> lstAF = new List<Account>();
        for(Account a : lst_Account )
        {
            if(a.Tyrecheck__c)
            {
                lstAT.add(a);                
            }
            else
            {
                lstAF.add(a);
            }            
        }
        
        Taccounts = lstAT;
        accounts = lstAF;             
   }
   
   public PageReference search(){
        
      ViewData();           
      return null;
   }  
  
 
}