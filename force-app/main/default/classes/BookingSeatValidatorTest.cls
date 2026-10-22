@IsTest
private class BookingSeatValidatorTest {
    @TestSetup
    static void createData() {
        Flight__c flight = new Flight__c(
            Flight_Name__c = 'AM-101',
            Flight_Company__c = 'IndiGo'
        );
        insert flight;

        insert new Passenger__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Passenger',
            Email_Address__c = 'test.passenger@example.com'
        );
    }

    @IsTest
    static void rejectsDuplicateSeatOnSameFlight() {
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];
        Passenger__c passenger = [SELECT Id FROM Passenger__c LIMIT 1];

        insert new Booking__c(
            Flight__c = flight.Id,
            Passenger__c = passenger.Id,
            Seat_Number__c = '12A',
            Booking_Status__c = 'Confirmed'
        );

        Database.SaveResult result;
        Test.startTest();
        result = Database.insert(new Booking__c(
            Flight__c = flight.Id,
            Passenger__c = passenger.Id,
            Seat_Number__c = '12a',
            Booking_Status__c = 'Confirmed'
        ), false);
        Test.stopTest();

        System.assertEquals(false, result.isSuccess());
        System.assert(result.getErrors()[0].getMessage().contains('already booked'));
    }

    @IsTest
    static void allowsSeatAfterCancellation() {
        Flight__c flight = [SELECT Id FROM Flight__c LIMIT 1];
        Passenger__c passenger = [SELECT Id FROM Passenger__c LIMIT 1];
        Booking__c booking = new Booking__c(
            Flight__c = flight.Id,
            Passenger__c = passenger.Id,
            Seat_Number__c = '14C',
            Booking_Status__c = 'Confirmed'
        );
        insert booking;

        booking.Booking_Status__c = 'Cancelled';
        update booking;

        Test.startTest();
        Booking__c replacement = new Booking__c(
            Flight__c = flight.Id,
            Passenger__c = passenger.Id,
            Seat_Number__c = '14C',
            Booking_Status__c = 'Confirmed'
        );
        insert replacement;
        Test.stopTest();

        System.assertNotEquals(null, replacement.Id);
    }
}
