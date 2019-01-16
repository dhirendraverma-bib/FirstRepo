trigger AccountAddressOnEvenTrigger on Event(before insert, before update){
    /*Created By: Dinesh Singh
      Created Date: 07-June-2018
      Description: W-014216 - This trigger will copy address from account to event.
     */
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
     AccountAddressOnEventTriggerHandler.setAccountAddressOnEvent(Trigger.new); 
    }
}