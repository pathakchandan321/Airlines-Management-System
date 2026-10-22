trigger FlightScheduleTrigger on Flight_Schedule__c (before insert, before update) {
    FlightScheduleTriggerHandler.validateAndUpdate(
        Trigger.new,
        Trigger.isUpdate ? Trigger.oldMap : new Map<Id, Flight_Schedule__c>()
    );
}
