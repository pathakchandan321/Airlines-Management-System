public with sharing class FlightScheduleQueryService {
    public static List<Flight_Schedule__c> schedulesForFlight(Id flightId) {
        return [
            SELECT Id, Name, Source_Name__c, Destination_Name__c,
                Departure_Date_Time__c, Arrival_Date_Time__c,
                Flight__r.Flight_Name__c, Flight__r.Flight_Company__c
            FROM Flight_Schedule__c
            WHERE Flight__c = :flightId
            ORDER BY Departure_Date_Time__c
        ];
    }

    public static List<Flight_Schedule__c> openOrCancelledSchedules() {
        return [
            SELECT Id, Name, Source_Name__c, Destination_Name__c,
                Departure_Date_Time__c, Arrival_Date_Time__c
            FROM Flight_Schedule__c
            ORDER BY Departure_Date_Time__c
        ];
    }

    public static List<Flight_Schedule__c> departingFrom(String sourceCity) {
        return [
            SELECT Id, Name, Source_Name__c, Destination_Name__c,
                Departure_Date_Time__c, Flight__r.Flight_Name__c
            FROM Flight_Schedule__c
            WHERE Source_Name__c = :sourceCity
            ORDER BY Departure_Date_Time__c
        ];
    }

    public static List<Flight_Schedule__c> withinDateRange(
        Datetime startDate,
        Datetime endDate
    ) {
        return [
            SELECT Id, Name, Source_Name__c, Destination_Name__c,
                Departure_Date_Time__c, Arrival_Date_Time__c,
                Flight__r.Flight_Name__c
            FROM Flight_Schedule__c
            WHERE Departure_Date_Time__c >= :startDate
            AND Departure_Date_Time__c <= :endDate
            ORDER BY Departure_Date_Time__c
        ];
    }

    public static List<Flight__c> flightsWithSchedules() {
        return [
            SELECT Id, Flight_Name__c, Flight_Company__c,
                (SELECT Id, Name, Source_Name__c, Destination_Name__c,
                    Departure_Date_Time__c, Arrival_Date_Time__c
                 FROM Flight_Schedules__r
                 ORDER BY Departure_Date_Time__c)
            FROM Flight__c
            ORDER BY Flight_Name__c
        ];
    }
}
