/**
 * Email Notification Trigger for Flight Schedule
 * Sends automated emails on schedule creation, status changes, and cancellations
 */
trigger FlightScheduleEmailNotification on Flight_Schedule__c (after insert, after update) {

    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    // Get admin email - replace with actual admin email
    String adminEmail = UserInfo.getUserEmail(); // Uses current user's email for demo

    for (Flight_Schedule__c schedule : Trigger.new) {

        // NOTIFICATION 1: Schedule Created
        if (Trigger.isInsert) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[]{adminEmail});
            email.setSubject('New Flight Schedule Created: ' + schedule.Name);
            email.setPlainTextBody(
                'Flight Schedule Details:\n\n' +
                'Schedule ID: ' + schedule.Name + '\n' +
                'Source: ' + schedule.Source_Name__c + '\n' +
                'Destination: ' + schedule.Destination_Name__c + '\n' +
                'Departure: ' + schedule.Departure_Date_Time__c + '\n' +
                'Arrival: ' + schedule.Arrival_Date_Time__c + '\n' +
                'Status: ' + schedule.Status__c + '\n\n' +
                'This is an automated notification from Airlines Management System.'
            );
            emails.add(email);
        }

        // NOTIFICATION 2 & 3: Status Change Alerts
        if (Trigger.isUpdate) {
            Flight_Schedule__c oldSchedule = Trigger.oldMap.get(schedule.Id);

            // Status changed to "In Progress" - Departure Alert
            if (schedule.Status__c == 'In Progress' &&
                oldSchedule.Status__c != 'In Progress') {

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{adminEmail});
                email.setSubject('Flight Departing - ' + schedule.Name);
                email.setPlainTextBody(
                    'DEPARTURE ALERT\n\n' +
                    'Flight Schedule: ' + schedule.Name + '\n' +
                    'Route: ' + schedule.Source_Name__c + ' → ' + schedule.Destination_Name__c + '\n' +
                    'Departure Time: ' + schedule.Departure_Date_Time__c + '\n' +
                    'Status: IN PROGRESS\n\n' +
                    'Flight has departed.'
                );
                emails.add(email);
            }

            // Status changed to "Cancelled" - Cancellation Alert
            if (schedule.Status__c == 'Cancelled' &&
                oldSchedule.Status__c != 'Cancelled') {

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{adminEmail});
                email.setSubject('URGENT: Flight Cancelled - ' + schedule.Name);
                email.setPlainTextBody(
                    '*** CANCELLATION ALERT ***\n\n' +
                    'Flight Schedule: ' + schedule.Name + '\n' +
                    'Route: ' + schedule.Source_Name__c + ' to ' + schedule.Destination_Name__c + '\n' +
                    'Originally Scheduled: ' + schedule.Departure_Date_Time__c + '\n' +
                    'Status: CANCELLED\n\n' +
                    'Action Required: Contact pilots and arrange alternate schedule.\n\n' +
                    'Automated alert from Airlines Management System.'
                );
                emails.add(email);
            }

            // Status changed to "Closed" - Arrival Notification
            if (schedule.Status__c == 'Closed' &&
                oldSchedule.Status__c != 'Closed') {

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[]{adminEmail});
                email.setSubject('Flight Arrived - ' + schedule.Name);
                email.setPlainTextBody(
                    'ARRIVAL NOTIFICATION\n\n' +
                    'Flight Schedule: ' + schedule.Name + '\n' +
                    'Route: ' + schedule.Source_Name__c + ' → ' + schedule.Destination_Name__c + '\n' +
                    'Arrival Time: ' + schedule.Arrival_Date_Time__c + '\n' +
                    'Status: CLOSED\n\n' +
                    'Flight has arrived successfully.'
                );
                emails.add(email);
            }
        }
    }

    // Send all emails
    if (!emails.isEmpty()) {
        try {
            Messaging.sendEmail(emails);
            System.debug('Successfully sent ' + emails.size() + ' email notification(s)');
        } catch (Exception e) {
            System.debug('Error sending emails: ' + e.getMessage());
        }
    }
}
