Flight__c flightOne = [
    SELECT Id
    FROM Flight__c
    WHERE Flight_Name__c = 'AM-101'
    LIMIT 1
];
Flight__c flightTwo = [
    SELECT Id
    FROM Flight__c
    WHERE Flight_Name__c = 'AI-202'
    LIMIT 1
];

Passenger__c passengerOne;
List<Passenger__c> existingPassengers = [
    SELECT Id
    FROM Passenger__c
    WHERE Email_Address__c = 'demo.passenger1@example.com'
    LIMIT 1
];
if (existingPassengers.isEmpty()) {
    passengerOne = new Passenger__c(
        First_Name__c = 'Demo',
        Last_Name__c = 'Passenger',
        Email_Address__c = 'demo.passenger1@example.com',
        Phone__c = '9000000001'
    );
    insert passengerOne;
} else {
    passengerOne = existingPassengers[0];
}

Passenger__c passengerTwo;
existingPassengers = [
    SELECT Id
    FROM Passenger__c
    WHERE Email_Address__c = 'demo.passenger2@example.com'
    LIMIT 1
];
if (existingPassengers.isEmpty()) {
    passengerTwo = new Passenger__c(
        First_Name__c = 'Sample',
        Last_Name__c = 'Traveller',
        Email_Address__c = 'demo.passenger2@example.com',
        Phone__c = '9000000002'
    );
    insert passengerTwo;
} else {
    passengerTwo = existingPassengers[0];
}

List<Booking__c> bookings = [
    SELECT Id, Flight__c, Seat_Number__c
    FROM Booking__c
    WHERE (Flight__c = :flightOne.Id AND Seat_Number__c = '12A')
       OR (Flight__c = :flightTwo.Id AND Seat_Number__c = '7C')
];
Set<String> existingBookingKeys = new Set<String>();
for (Booking__c booking : bookings) {
    existingBookingKeys.add(String.valueOf(booking.Flight__c) + '|' + booking.Seat_Number__c);
}

List<Booking__c> bookingsToInsert = new List<Booking__c>();
if (!existingBookingKeys.contains(String.valueOf(flightOne.Id) + '|12A')) {
    bookingsToInsert.add(new Booking__c(
        Flight__c = flightOne.Id,
        Passenger__c = passengerOne.Id,
        Seat_Number__c = '12A',
        Booking_Status__c = 'Confirmed',
        Amount__c = 4500
    ));
}
if (!existingBookingKeys.contains(String.valueOf(flightTwo.Id) + '|7C')) {
    bookingsToInsert.add(new Booking__c(
        Flight__c = flightTwo.Id,
        Passenger__c = passengerTwo.Id,
        Seat_Number__c = '7C',
        Booking_Status__c = 'Pending',
        Amount__c = 6200
    ));
}
if (!bookingsToInsert.isEmpty()) {
    insert bookingsToInsert;
}

System.debug('Airlines demo data created or already present.');

List<Pilot__c> pilots = [
    SELECT Id, Email_Address__c
    FROM Pilot__c
    WHERE Email_Address__c IN ('pilot.one@example.com', 'pilot.two@example.com')
];
Set<String> pilotEmails = new Set<String>();
for (Pilot__c pilot : pilots) {
    pilotEmails.add(pilot.Email_Address__c);
}
List<Pilot__c> pilotsToInsert = new List<Pilot__c>();
if (!pilotEmails.contains('pilot.one@example.com')) {
    pilotsToInsert.add(new Pilot__c(
        First_Name__c = 'Demo',
        Email_Address__c = 'pilot.one@example.com',
        Experience__c = 'More than 5 years'
    ));
}
if (!pilotEmails.contains('pilot.two@example.com')) {
    pilotsToInsert.add(new Pilot__c(
        First_Name__c = 'Sample',
        Email_Address__c = 'pilot.two@example.com',
        Experience__c = '2–5 years'
    ));
}
if (!pilotsToInsert.isEmpty()) {
    insert pilotsToInsert;
    pilots.addAll(pilotsToInsert);
}

List<Flight_Schedule__c> schedules = [
    SELECT Id
    FROM Flight_Schedule__c
    WHERE Flight__c IN :new Set<Id>{flightOne.Id, flightTwo.Id}
];
if (schedules.isEmpty()) {
    insert new List<Flight_Schedule__c>{
        new Flight_Schedule__c(
            Name = 'AM-101 Delhi to Mumbai',
            Flight__c = flightOne.Id,
            Source_Name__c = 'Delhi',
            Destination_Name__c = 'Mumbai',
            Departure_Date_Time__c = System.now().addDays(1),
            Arrival_Date_Time__c = System.now().addDays(1).addHours(2)
        ),
        new Flight_Schedule__c(
            Name = 'AI-202 Mumbai to Pune',
            Flight__c = flightTwo.Id,
            Source_Name__c = 'Mumbai',
            Destination_Name__c = 'Pune',
            Departure_Date_Time__c = System.now().addDays(2),
            Arrival_Date_Time__c = System.now().addDays(2).addHours(1)
        )
    };
}

Set<Id> bookingIds = new Map<Id, Booking__c>([
    SELECT Id
    FROM Booking__c
    WHERE Id IN :new Map<Id, Booking__c>([
        SELECT Id
        FROM Booking__c
        WHERE Flight__c IN :new Set<Id>{flightOne.Id, flightTwo.Id}
        ORDER BY CreatedDate
        LIMIT 2
    ]).keySet()
]).keySet();
if (!bookingIds.isEmpty()) {
    List<Payment__c> payments = [
        SELECT Id
        FROM Payment__c
        WHERE Booking__c IN :bookingIds
    ];
    if (payments.isEmpty()) {
        List<Booking__c> paymentBookings = [
            SELECT Id, Amount__c
            FROM Booking__c
            WHERE Id IN :bookingIds
            ORDER BY CreatedDate
            LIMIT 2
        ];
        List<Payment__c> paymentsToInsert = new List<Payment__c>();
        for (Booking__c paymentBooking : paymentBookings) {
            paymentsToInsert.add(new Payment__c(
                Booking__c = paymentBooking.Id,
                Amount__c = paymentBooking.Amount__c
            ));
        }
        insert paymentsToInsert;
    }
}
