trigger BookingSeatTrigger on Booking__c (before insert, before update) {
    BookingSeatValidator.validateSeats(
        Trigger.new,
        Trigger.isUpdate ? Trigger.oldMap : new Map<Id, Booking__c>()
    );
}
