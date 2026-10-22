import { LightningElement, wire } from 'lwc';
import getMetrics from '@salesforce/apex/AirlineAnalyticsController.getMetrics';

export default class AnalyticsSummary extends LightningElement {
    metrics = {
        totalBookings: 0,
        activeBookings: 0,
        cancelledBookings: 0,
        activeRevenue: 0,
        totalPayments: 0
    };
    errorMessage;

    @wire(getMetrics)
    loadMetrics({ data, error }) {
        if (data) {
            this.metrics = data;
            this.errorMessage = undefined;
        } else if (error) {
            this.errorMessage = error?.body?.message || 'Unable to load analytics.';
        }
    }

    get formattedRevenue() {
        return new Intl.NumberFormat('en-IN', {
            style: 'currency',
            currency: 'INR',
            maximumFractionDigits: 0
        }).format(this.metrics.activeRevenue || 0);
    }

    get statusBars() {
        const maximum = Math.max(...(this.metrics.statusMetrics || []).map(item => item.count), 1);
        return (this.metrics.statusMetrics || []).map(item => ({
            ...item,
            width: `width: ${(item.count / maximum) * 100}%`
        }));
    }

    get flightBars() {
        const maximum = Math.max(...(this.metrics.flightMetrics || []).map(item => item.bookings), 1);
        return (this.metrics.flightMetrics || []).map(item => ({
            ...item,
            width: `width: ${(item.bookings / maximum) * 100}%`,
            revenueLabel: new Intl.NumberFormat('en-IN', {
                style: 'currency',
                currency: 'INR',
                maximumFractionDigits: 0
            }).format(item.revenue || 0)
        }));
    }
}
