public with sharing class BookingConsoleController {
    public class BookingRow {
        @AuraEnabled public Id id;
        @AuraEnabled public String pnr;
        @AuraEnabled public String flightName;
        @AuraEnabled public String passengerName;
        @AuraEnabled public String seatNumber;
        @AuraEnabled public String status;
        @AuraEnabled public Decimal amount;

        public BookingRow(Booking__c booking) {
            id = booking.Id;
            pnr = booking.Name;
            flightName = booking.Flight__r == null ? null : booking.Flight__r.Flight_Name__c;
            passengerName = booking.Passenger__r == null
                ? null
                : booking.Passenger__r.First_Name__c + ' ' + booking.Passenger__r.Last_Name__c;
            seatNumber = booking.Seat_Number__c;
            status = booking.Booking_Status__c;
            amount = booking.Amount__c;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<BookingRow> getRecentBookings() {
        List<BookingRow> rows = new List<BookingRow>();
        for (Booking__c booking : [
            SELECT Id, Name, Seat_Number__c, Booking_Status__c, Amount__c,
                Flight__r.Flight_Name__c, Passenger__r.First_Name__c, Passenger__r.Last_Name__c
            FROM Booking__c
            ORDER BY CreatedDate DESC
            LIMIT 50
        ]) {
            rows.add(new BookingRow(booking));
        }
        return rows;
    }

    @AuraEnabled
    public static BookingRow cancelBooking(Id bookingId) {
        return new BookingRow(BookingCancellationService.cancelBooking(bookingId));
    }
}
