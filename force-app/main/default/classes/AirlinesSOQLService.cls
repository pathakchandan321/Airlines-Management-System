/**
 * SOQL Query Service for Airlines Management System
 * Demonstrates parent-to-child and child-to-parent relationship queries
 */
public class AirlinesSOQLService {
    
    /**
     * PARENT TO CHILD: Query Flight with its related Flight Schedules
     */
    public static List<Flight__c> getFlightWithSchedules(Id flightId) {
        return [
            SELECT Id, Name, Flight_Name__c, Flight_Company__c,
                   (SELECT Id, Name, Source_Name__c, Destination_Name__c,
                           Departure_Date_Time__c, Arrival_Date_Time__c,
                           Duration__c, Status__c
                    FROM Flight_Schedules__r
                    ORDER BY Departure_Date_Time__c DESC)
            FROM Flight__c
            WHERE Id = :flightId
        ];
    }
    
    /**
     * CHILD TO PARENT: Query Flight Schedule with parent Flight details
     */
    public static List<Flight_Schedule__c> getSchedulesWithFlightInfo() {
        return [
            SELECT Id, Name, Source_Name__c, Destination_Name__c,
                   Departure_Date_Time__c, Arrival_Date_Time__c, Status__c,
                   Flight__c, Flight__r.Name, Flight__r.Flight_Name__c,
                   Flight__r.Flight_Company__c
            FROM Flight_Schedule__c
            ORDER BY Departure_Date_Time__c DESC
            LIMIT 100
        ];
    }
    
    /**
     * Query schedules for a selected flight
     */
    public static List<Flight_Schedule__c> getSchedulesByFlight(Id flightId) {
        return [
            SELECT Id, Name, Source_Name__c, Destination_Name__c,
                   Departure_Date_Time__c, Arrival_Date_Time__c,
                   Duration__c, Status__c
            FROM Flight_Schedule__c
            WHERE Flight__c = :flightId
            ORDER BY Departure_Date_Time__c DESC
        ];
    }
    
    /**
     * Query open/cancelled schedules
     */
    public static List<Flight_Schedule__c> getSchedulesByStatus(String status) {
        return [
            SELECT Id, Name, Flight__r.Flight_Name__c,
                   Source_Name__c, Destination_Name__c,
                   Departure_Date_Time__c, Status__c
            FROM Flight_Schedule__c
            WHERE Status__c = :status
            ORDER BY Departure_Date_Time__c DESC
        ];
    }
    
    /**
     * Query schedules departing from selected source city
     */
    public static List<Flight_Schedule__c> getSchedulesBySourceCity(String sourceCity) {
        return [
            SELECT Id, Name, Flight__r.Flight_Name__c, Flight__r.Flight_Company__c,
                   Source_Name__c, Destination_Name__c,
                   Departure_Date_Time__c, Arrival_Date_Time__c, Status__c
            FROM Flight_Schedule__c
            WHERE Source_Name__c = :sourceCity
            ORDER BY Departure_Date_Time__c DESC
        ];
    }
    
    /**
     * Query schedules within a date range
     */
    public static List<Flight_Schedule__c> getSchedulesByDateRange(
        DateTime startDate, 
        DateTime endDate
    ) {
        return [
            SELECT Id, Name, Flight__r.Flight_Name__c,
                   Source_Name__c, Destination_Name__c,
                   Departure_Date_Time__c, Arrival_Date_Time__c,
                   Duration__c, Status__c
            FROM Flight_Schedule__c
            WHERE Departure_Date_Time__c >= :startDate
              AND Departure_Date_Time__c <= :endDate
            ORDER BY Departure_Date_Time__c ASC
        ];
    }
}