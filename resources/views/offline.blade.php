<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Offline - Utility Bill Logger</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background-color: #f9fafb;
            margin: 0;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            text-align: center;
        }
        .offline-container {
            background: white;
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            max-width: 400px;
            width: 100%;
        }
        .offline-icon {
            width: 64px;
            height: 64px;
            margin: 0 auto 1rem;
            background: #fef3c7;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .offline-icon svg {
            width: 32px;
            height: 32px;
            color: #d97706;
        }
        h1 {
            color: #1f2937;
            margin: 0 0 0.5rem;
            font-size: 1.5rem;
            font-weight: 600;
        }
        p {
            color: #6b7280;
            margin: 0 0 1.5rem;
            line-height: 1.5;
        }
        .btn {
            background: #3b82f6;
            color: white;
            padding: 0.75rem 1.5rem;
            border: none;
            border-radius: 8px;
            font-weight: 500;
            text-decoration: none;
            display: inline-block;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .btn:hover {
            background: #2563eb;
        }
        .offline-data {
            margin-top: 1.5rem;
            padding: 1rem;
            background: #f3f4f6;
            border-radius: 8px;
            text-align: left;
        }
        .offline-data h3 {
            margin: 0 0 0.5rem;
            font-size: 0.875rem;
            color: #374151;
        }
        .offline-data p {
            margin: 0;
            font-size: 0.75rem;
            color: #6b7280;
        }
    </style>
</head>
<body>
    <div class="offline-container">
        <div class="offline-icon">
            <svg fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18.364 5.636l-3.536 3.536m0 5.656l3.536 3.536M9.172 9.172L5.636 5.636m3.536 9.192L5.636 18.364M12 2.25a9.75 9.75 0 100 19.5 9.75 9.75 0 000-19.5z"></path>
            </svg>
        </div>

        <h1>You're Offline</h1>
        <p>Don't worry! You can still add readings and view cached data. Your changes will sync when you're back online.</p>

        <a href="/" class="btn">Go Home</a>

        <div class="offline-data">
            <h3>Offline Features Available:</h3>
            <p>• Add new readings (will sync when online)<br>
            • View cached readings<br>
            • View cached billing cycles<br>
            • Quick add functionality</p>
        </div>
    </div>

    <script>
        // Check for offline data and show sync status
        window.addEventListener('load', () => {
            const offlineData = localStorage.getItem('offlineData');
            if (offlineData) {
                const data = JSON.parse(offlineData);
                if (data.length > 0) {
                    const offlineDataDiv = document.querySelector('.offline-data');
                    offlineDataDiv.innerHTML += `
                        <h3 style="margin-top: 1rem; color: #059669;">📱 ${data.length} item(s) waiting to sync</h3>
                        <p style="color: #059669;">Your offline changes will automatically sync when you're back online.</p>
                    `;
                }
            }
        });

        // Listen for online/offline events
        window.addEventListener('online', () => {
            // Trigger background sync
            if ('serviceWorker' in navigator && 'sync' in window.ServiceWorkerRegistration.prototype) {
                navigator.serviceWorker.ready.then(registration => {
                    registration.sync.register('background-sync');
                });
            }
        });
    </script>
</body>
</html>
