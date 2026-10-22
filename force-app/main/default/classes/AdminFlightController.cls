public with sharing class AdminFlightController {

    @AuraEnabled(cacheable=true)
    public static List<Flight__c> getAllFlights() {
        return [
            SELECT Id, Name, Flight_Name__c, Flight_Company__c, CreatedDate
            FROM Flight__c
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Flight_Schedule__c> getFlightSchedules(Id flightId) {
        return [
            SELECT Id, Name, Flight__c, Source_Name__c, Destination_Name__c,
                   Departure_Date_Time__c, Arrival_Date_Time__c, Status__c,
                   First_Pilot__c, Second_Pilot__c, Duration__c
            FROM Flight_Schedule__c
            WHERE Flight__c = :flightId
            ORDER BY Departure_Date_Time__c DESC
        ];
    }

    @AuraEnabled
    public static Id createFlight(String flightName, String flightCompany) {
        try {
            Flight__c newFlight = new Flight__c(
                Flight_Name__c = flightName,
                Flight_Company__c = flightCompany
            );
            insert newFlight;
            return newFlight.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating flight: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateFlight(Id flightId, String flightName, String flightCompany) {
        try {
            Flight__c flight = new Flight__c(
                Id = flightId,
                Flight_Name__c = flightName,
                Flight_Company__c = flightCompany
            );
            update flight;
        } catch (Exception e) {
            throw new AuraHandledException('Error updating flight: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteFlight(Id flightId) {
        try {
            delete [SELECT Id FROM Flight__c WHERE Id = :flightId];
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting flight: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Id createFlightSchedule(
        Id flightId,
        String source,
        String destination,
        DateTime departureTime,
        DateTime arrivalTime,
        String firstPilot,
        String secondPilot,
        String status
    ) {
        try {
            Flight_Schedule__c schedule = new Flight_Schedule__c(
                Flight__c = flightId,
                Source_Name__c = source,
                Destination_Name__c = destination,
                Departure_Date_Time__c = departureTime,
                Arrival_Date_Time__c = arrivalTime,
                First_Pilot__c = firstPilot,
                Second_Pilot__c = secondPilot,
                Status__c = status
            );
            insert schedule;
            return schedule.Id;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating schedule: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteFlightSchedule(Id scheduleId) {
        try {
            delete [SELECT Id FROM Flight_Schedule__c WHERE Id = :scheduleId];
        } catch (Exception e) {
            throw new AuraHandledException('Error deleting schedule: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFlightCompanyOptions() {
        Map<String, Object> result = new Map<String, Object>();
        Schema.DescribeFieldResult fieldResult = Flight__c.Flight_Company__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

        List<Map<String, String>> options = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : picklistValues) {
            options.add(new Map<String, String>{
                'label' => entry.getLabel(),
                'value' => entry.getValue()
            });
        }
        result.put('options', options);
        return result;
    }
}
