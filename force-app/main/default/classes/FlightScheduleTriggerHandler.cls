public without sharing class FlightScheduleTriggerHandler {
    public static void validateAndUpdate(
        List<Flight_Schedule__c> schedules,
        Map<Id, Flight_Schedule__c> oldMap
    ) {
        Set<Id> flightIds = new Set<Id>();
        Map<String, Schema.SObjectField> fields =
            Schema.sObjectType.Flight_Schedule__c.fields.getMap();
        for (Flight_Schedule__c schedule : schedules) {
            if (schedule.Flight__c != null) {
                flightIds.add(schedule.Flight__c);
            }
            String currentStatus = (String) schedule.get('Status__c');
            if (currentStatus != 'Cancelled' &&
                schedule.Departure_Date_Time__c != null &&
                schedule.Arrival_Date_Time__c != null) {
                if (schedule.Arrival_Date_Time__c <= System.now()) {
                    setStatusIfAvailable(schedule, 'Closed');
                } else if (schedule.Departure_Date_Time__c <= System.now()) {
                    setStatusIfAvailable(schedule, 'In Progress');
                } else if (String.isBlank(currentStatus)) {
                    setStatusIfAvailable(schedule, 'Open');
                }
            }
        }

        if (flightIds.isEmpty()) {
            return;
        }

        Set<Id> currentIds = new Set<Id>();
        for (Flight_Schedule__c schedule : schedules) {
            if (schedule.Id != null) {
                currentIds.add(schedule.Id);
            }
        }

        List<Flight_Schedule__c> existingSchedules = Database.query(
            'SELECT Id, Flight__c, Source_Name__c, Destination_Name__c, ' +
            'Departure_Date_Time__c, Arrival_Date_Time__c ' +
            'FROM Flight_Schedule__c WHERE Flight__c IN :flightIds AND Id NOT IN :currentIds' +
            ''
        );

        for (Flight_Schedule__c incoming : schedules) {
            for (Flight_Schedule__c existing : existingSchedules) {
                if (incoming.Flight__c == existing.Flight__c &&
                    incoming.Source_Name__c == existing.Source_Name__c &&
                    incoming.Destination_Name__c == existing.Destination_Name__c &&
                    incoming.Departure_Date_Time__c == existing.Departure_Date_Time__c &&
                    incoming.Arrival_Date_Time__c == existing.Arrival_Date_Time__c) {
                    incoming.addError(
                        'An active schedule already exists for this flight, route, and time.'
                    );
                }
            }
        }

    }

    private static void setStatusIfAvailable(
        Flight_Schedule__c schedule,
        String status
    ) {
        if (Schema.sObjectType.Flight_Schedule__c.fields.getMap().containsKey('Status__c')) {
            schedule.put('Status__c', status);
        }
    }
}
