@IsTest
private class MockPaymentServiceTest {
    @TestSetup
    static void createData() {
        Flight__c flight = new Flight__c(
            Flight_Name__c = 'PAY-101',
            Flight_Company__c = 'SkyManage'
        );
        insert flight;

        Passenger__c passenger = new Passenger__c(
            First_Name__c = 'Payment',
            Last_Name__c = 'Test',
            Email_Address__c = 'payment.test@example.com'
        );
        insert passenger;

        insert new Booking__c(
            Flight__c = flight.Id,
            Passenger__c = passenger.Id,
            Seat_Number__c = '21B',
            Booking_Status__c = 'Confirmed',
            Amount__c = 5000
        );
    }

    @IsTest
    static void createsOneMockPayment() {
        Booking__c booking = [
            SELECT Id, Amount__c
            FROM Booking__c
            LIMIT 1
        ];

        Test.startTest();
        Payment__c payment = MockPaymentService.processPayment(booking.Id);
        Test.stopTest();

        System.assertNotEquals(null, payment.Id);
        System.assertEquals(booking.Id, payment.Booking__c);
        System.assertEquals(booking.Amount__c, payment.Amount__c);
    }

    @IsTest
    static void repeatedProcessingReturnsExistingPayment() {
        Booking__c booking = [SELECT Id FROM Booking__c LIMIT 1];
        Payment__c firstPayment = MockPaymentService.processPayment(booking.Id);

        Test.startTest();
        Payment__c secondPayment = MockPaymentService.processPayment(booking.Id);
        Test.stopTest();

        System.assertEquals(firstPayment.Id, secondPayment.Id);
        System.assertEquals(1, [
            SELECT COUNT()
            FROM Payment__c
            WHERE Booking__c = :booking.Id
        ]);
    }

    @IsTest
    static void rejectsMissingBooking() {
        try {
            MockPaymentService.processPayment(null);
            System.assert(false, 'Expected a missing-booking error.');
        } catch (AuraHandledException exceptionThrown) {
            System.assertNotEquals(null, exceptionThrown);
        }
    }
}
