/**
 * Validates seat uniqueness for active bookings on the same flight.
 */
public without sharing class BookingSeatValidator {
    private static final String CANCELLED_STATUS = 'Cancelled';

    public static void validateSeats(List<Booking__c> newBookings, Map<Id, Booking__c> oldBookings) {
        Set<Id> flightIds = new Set<Id>();
        Set<String> requestedSeats = new Set<String>();

        for (Booking__c booking : newBookings) {
            if (booking.Flight__c == null ||
                String.isBlank(booking.Seat_Number__c) ||
                booking.Booking_Status__c == CANCELLED_STATUS) {
                continue;
            }

            flightIds.add(booking.Flight__c);
            requestedSeats.add(seatKey(booking.Flight__c, booking.Seat_Number__c));
        }

        if (flightIds.isEmpty()) {
            return;
        }

        Map<String, Id> existingSeats = new Map<String, Id>();
        for (Booking__c booking : [
            SELECT Id, Flight__c, Seat_Number__c
            FROM Booking__c
            WHERE Flight__c IN :flightIds
            AND Booking_Status__c != :CANCELLED_STATUS
            AND Seat_Number__c != null
        ]) {
            existingSeats.put(seatKey(booking.Flight__c, booking.Seat_Number__c), booking.Id);
        }

        Set<String> seatsInTransaction = new Set<String>();
        for (Booking__c booking : newBookings) {
            if (booking.Flight__c == null ||
                String.isBlank(booking.Seat_Number__c) ||
                booking.Booking_Status__c == CANCELLED_STATUS) {
                continue;
            }

            String key = seatKey(booking.Flight__c, booking.Seat_Number__c);
            Id existingId = existingSeats.get(key);
            Boolean isCurrentRecord = existingId != null && existingId == booking.Id;

            if ((existingId != null && !isCurrentRecord) || seatsInTransaction.contains(key)) {
                booking.Seat_Number__c.addError(
                    'This seat is already booked for the selected flight. Choose another seat.'
                );
            } else {
                seatsInTransaction.add(key);
            }
        }
    }

    private static String seatKey(Id flightId, String seatNumber) {
        return String.valueOf(flightId) + '|' + seatNumber.trim().toUpperCase();
    }
}
