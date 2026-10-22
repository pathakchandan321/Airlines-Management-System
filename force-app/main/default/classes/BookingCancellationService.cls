/**
 * Cancels a booking while locking the record to avoid concurrent updates.
 */
public with sharing class BookingCancellationService {
    private static final String CANCELLED_STATUS = 'Cancelled';

    public static Booking__c cancelBooking(Id bookingId) {
        if (bookingId == null) {
            throw new AuraHandledException('A booking is required for cancellation.');
        }

        Booking__c booking = [
            SELECT Id, Name, Booking_Status__c, Seat_Number__c,
                Amount__c, Flight__r.Flight_Name__c,
                Passenger__r.First_Name__c, Passenger__r.Last_Name__c
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
            FOR UPDATE
        ];

        if (booking.Booking_Status__c != CANCELLED_STATUS) {
            booking.Booking_Status__c = CANCELLED_STATUS;
            update booking;
        }

        return booking;
    }
}
