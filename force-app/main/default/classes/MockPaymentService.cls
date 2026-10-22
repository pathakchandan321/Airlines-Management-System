/**
 * Creates a local mock payment record without storing card details.
 */
public with sharing class MockPaymentService {
    public static Payment__c processPayment(Id bookingId) {
        if (bookingId == null) {
            throw new AuraHandledException('A booking is required for payment.');
        }

        Booking__c booking = [
            SELECT Id, Amount__c
            FROM Booking__c
            WHERE Id = :bookingId
            LIMIT 1
            FOR UPDATE
        ];

        List<Payment__c> existingPayments = [
            SELECT Id, Booking__c, Amount__c
            FROM Payment__c
            WHERE Booking__c = :booking.Id
            ORDER BY CreatedDate
            LIMIT 1
        ];
        if (!existingPayments.isEmpty()) {
            return existingPayments[0];
        }

        Payment__c payment = new Payment__c(
            Booking__c = booking.Id,
            Amount__c = booking.Amount__c
        );
        insert payment;
        return payment;
    }
}
