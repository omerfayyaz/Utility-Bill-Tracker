// PWA Service Worker Registration and Offline Functionality
import { queueChange, pullQueue, cacheData, getData } from './offline';
import axios from 'axios';

class PWA {
    constructor() {
        this.isOnline = navigator.onLine;
        this.offlineData = [];
        this.init();
    }

    async init() {
        await this.registerServiceWorker();
        this.setupEventListeners();
        this.loadOfflineData();
        this.checkConnectivity();
        this.checkInstallability();
    }

    async registerServiceWorker() {
        if ('serviceWorker' in navigator) {
            try {
                const registration = await navigator.serviceWorker.register('/sw.js');
                console.log('Service Worker registered:', registration);

                // Handle updates
                registration.addEventListener('updatefound', () => {
                    const newWorker = registration.installing;
                    newWorker.addEventListener('statechange', () => {
                        if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                            this.showUpdateNotification();
                        }
                    });
                });
            } catch (error) {
                console.error('Service Worker registration failed:', error);
            }
        } else {
            console.log('Service Worker not supported');
        }
    }

    setupEventListeners() {
        // Online/offline events
        window.addEventListener('online', () => this.handleOnline());
        window.addEventListener('offline', () => this.handleOffline());

        // Form submissions for offline handling
        document.addEventListener('submit', (e) => this.handleFormSubmit(e));

        // PWA installation events
        window.addEventListener('beforeinstallprompt', (e) => this.handleBeforeInstallPrompt(e));
        window.addEventListener('appinstalled', () => this.handleAppInstalled());
    }

    handleBeforeInstallPrompt(e) {
        console.log('beforeinstallprompt event fired');
        e.preventDefault();

        // Store the event for later use
        window.deferredPrompt = e;

        // Show custom install prompt
        this.showInstallPrompt();
    }

    handleAppInstalled() {
        console.log('App was installed');
        this.hideInstallPrompt();
        this.showNotification('App installed successfully!', 'success');
    }

    showInstallPrompt() {
        const prompt = document.getElementById('pwa-install-prompt');
        if (prompt) {
            prompt.classList.remove('hidden');
            console.log('Install prompt shown');
        }
    }

    hideInstallPrompt() {
        const prompt = document.getElementById('pwa-install-prompt');
        if (prompt) {
            prompt.classList.add('hidden');
        }
    }

    checkInstallability() {
        const isInstallable = this.isInstallable();
        console.log('App is installable:', isInstallable);

        if (isInstallable) {
            console.log('PWA criteria met - app can be installed');
        } else {
            console.log('PWA criteria not met - checking why:');
            console.log('- Service Worker supported:', 'serviceWorker' in navigator);
            console.log('- Push Manager supported:', 'PushManager' in window);
            console.log('- Already installed:', window.matchMedia('(display-mode: standalone)').matches);
        }
    }

    handleOnline() {
        this.isOnline = true;
        this.showNotification('Back online! Syncing offline data...', 'success');
        this.syncOfflineData();
    }

    handleOffline() {
        this.isOnline = false;
        this.showNotification('You\'re offline. Changes will sync when you\'re back online.', 'warning');
    }

    async handleFormSubmit(event) {
        const form = event.target;
        const isReadingForm = form.action.includes('daily-readings') || form.action.includes('billing-cycles');

        if (!isReadingForm) return;

        if (!this.isOnline) {
            event.preventDefault();
            await this.storeOfflineForm(form);
            this.showNotification('Data saved offline. Will sync when online.', 'info');
        }
    }

    async storeOfflineForm(form) {
        const formData = new FormData(form);
        const data = Object.fromEntries(formData);
        // Use localForage queue for daily readings
        if (form.action.includes('daily-readings')) {
            await queueChange('daily-readings', data);
        } else if (form.action.includes('billing-cycles')) {
            await queueChange('billing-cycles', data);
        }
    }

    async syncOfflineData() {
        if (!this.isOnline) return;
        // Use localForage queue
        const queued = await pullQueue();
        for (let { model, payload } of queued) {
            try {
                await axios.post(`/api/${model}/offline-sync`, payload);
            } catch (err) {
                console.error('Sync failed for', model, payload, err);
                // Optionally re-queue
                await queueChange(model, payload);
            }
        }
        if (queued.length) {
            this.showNotification('All offline data synced successfully!', 'success');
        }
    }

    loadOfflineData() {
        const data = localStorage.getItem('offlineData');
        this.offlineData = data ? JSON.parse(data) : [];
        console.log('Loaded offline data:', this.offlineData.length, 'items');
    }

    checkConnectivity() {
        if (!this.isOnline) {
            this.showNotification('You\'re currently offline. Some features may be limited.', 'warning');
        }
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `pwa-notification pwa-notification-${type}`;
        notification.innerHTML = `
            <div class="pwa-notification-content">
                <span>${message}</span>
                <button class="pwa-notification-close">&times;</button>
            </div>
        `;

        // Add styles
        notification.style.cssText = `
            position: fixed;
            top: 20px;
            right: 20px;
            background: ${type === 'success' ? '#10b981' : type === 'warning' ? '#f59e0b' : '#3b82f6'};
            color: white;
            padding: 12px 16px;
            border-radius: 8px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            z-index: 1000;
            max-width: 300px;
            animation: slideIn 0.3s ease-out;
        `;

        // Add animation styles
        if (!document.querySelector('#pwa-styles')) {
            const style = document.createElement('style');
            style.id = 'pwa-styles';
            style.textContent = `
                @keyframes slideIn {
                    from { transform: translateX(100%); opacity: 0; }
                    to { transform: translateX(0); opacity: 1; }
                }
                .pwa-notification-content {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                }
                .pwa-notification-close {
                    background: none;
                    border: none;
                    color: white;
                    font-size: 18px;
                    cursor: pointer;
                    margin-left: 12px;
                }
            `;
            document.head.appendChild(style);
        }

        document.body.appendChild(notification);

        // Auto remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.remove();
            }
        }, 5000);

        // Close button
        notification.querySelector('.pwa-notification-close').addEventListener('click', () => {
            notification.remove();
        });
    }

    showUpdateNotification() {
        this.showNotification('New version available! Refresh to update.', 'info');
    }

    // Public method to check if app is installable
    isInstallable() {
        return 'serviceWorker' in navigator &&
               'PushManager' in window &&
               window.matchMedia('(display-mode: standalone)').matches === false;
    }

    // Public method to get offline data count
    getOfflineDataCount() {
        return this.offlineData.length;
    }

    // Public method to trigger install
    triggerInstall() {
        if (window.deferredPrompt) {
            window.deferredPrompt.prompt();
            window.deferredPrompt.userChoice.then((choiceResult) => {
                if (choiceResult.outcome === 'accepted') {
                    console.log('User accepted the install prompt');
                } else {
                    console.log('User dismissed the install prompt');
                }
                window.deferredPrompt = null;
                this.hideInstallPrompt();
            });
        }
    }
}

// Initialize PWA when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.pwa = new PWA();

    // Set up install button event listeners
    const installNowBtn = document.getElementById('pwa-install-now');
    const installLaterBtn = document.getElementById('pwa-install-later');

    if (installNowBtn) {
        installNowBtn.addEventListener('click', () => {
            window.pwa.triggerInstall();
        });
    }

    if (installLaterBtn) {
        installLaterBtn.addEventListener('click', () => {
            window.pwa.hideInstallPrompt();
            localStorage.setItem('pwa-install-dismissed', 'true');
        });
    }
});

// Export for use in other modules
export default PWA;
