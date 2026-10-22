public with sharing class FlightSearchController {
    public class FlightRow {
        @AuraEnabled public Id id;
        @AuraEnabled public String scheduleName;
        @AuraEnabled public String flightName;
        @AuraEnabled public String source;
        @AuraEnabled public String destination;
        @AuraEnabled public Datetime departure;
        @AuraEnabled public Datetime arrival;
        @AuraEnabled public Integer activeBookings;

        public FlightRow(Flight_Schedule__c schedule, Integer bookingCount) {
            id = schedule.Id;
            scheduleName = schedule.Name;
            flightName = schedule.Flight__r == null
                ? null
                : schedule.Flight__r.Flight_Name__c;
            source = schedule.Source_Name__c;
            destination = schedule.Destination_Name__c;
            departure = schedule.Departure_Date_Time__c;
            arrival = schedule.Arrival_Date_Time__c;
            activeBookings = bookingCount;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<FlightRow> searchFlights(String source, String destination) {
        if (String.isBlank(source) || String.isBlank(destination)) {
            throw new AuraHandledException('Select both source and destination.');
        }

        List<Flight_Schedule__c> schedules = [
            SELECT Id, Name, Source_Name__c, Destination_Name__c,
                Departure_Date_Time__c, Arrival_Date_Time__c,
                Flight__c, Flight__r.Flight_Name__c
            FROM Flight_Schedule__c
            WHERE Source_Name__c = :source
            AND Destination_Name__c = :destination
            AND Departure_Date_Time__c >= :System.now()
            ORDER BY Departure_Date_Time__c
            LIMIT 50
        ];

        Set<Id> flightIds = new Set<Id>();
        for (Flight_Schedule__c schedule : schedules) {
            flightIds.add(schedule.Flight__c);
        }

        Map<Id, Integer> bookingCounts = new Map<Id, Integer>();
        for (AggregateResult result : [
            SELECT Flight__c flightId, COUNT(Id) bookingCount
            FROM Booking__c
            WHERE Flight__c IN :flightIds
            AND Booking_Status__c != 'Cancelled'
            GROUP BY Flight__c
        ]) {
            bookingCounts.put(
                (Id) result.get('flightId'),
                (Integer) result.get('bookingCount')
            );
        }

        List<FlightRow> rows = new List<FlightRow>();
        for (Flight_Schedule__c schedule : schedules) {
            rows.add(new FlightRow(
                schedule,
                bookingCounts.containsKey(schedule.Flight__c)
                    ? bookingCounts.get(schedule.Flight__c)
                    : 0
            ));
        }
        return rows;
    }
}
