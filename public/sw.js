const CACHE_NAME = 'utility-bill-logger-v1';
const urlsToCache = [
    '/',
    '/offline'
];

// Install event - cache resources
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then((cache) => {
                console.log('Opened cache');
                // Only cache resources that exist
                return Promise.allSettled(
                    urlsToCache.map(url =>
                        cache.add(url).catch(error => {
                            console.warn(`Failed to cache ${url}:`, error);
                            return null;
                        })
                    )
                );
            })
    );
});

// Fetch event - serve from cache when offline
self.addEventListener('fetch', (event) => {
    event.respondWith(
        caches.match(event.request)
            .then((response) => {
                // Return cached version or fetch from network
                return response || fetch(event.request);
            })
            .catch(() => {
                // Return offline page for navigation requests
                if (event.request.mode === 'navigate') {
                    return caches.match('/offline');
                }
            })
    );
});

// Background sync for offline data
self.addEventListener('sync', (event) => {
    if (event.tag === 'background-sync') {
        event.waitUntil(syncOfflineData());
    }
});

// Sync offline data when connection is restored
async function syncOfflineData() {
    try {
        const offlineData = await getOfflineData();

        for (const data of offlineData) {
            try {
                const response = await fetch(data.url, {
                    method: data.method,
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': data.csrfToken
                    },
                    body: JSON.stringify(data.body)
                });

                if (response.ok) {
                    // Remove from offline storage after successful sync
                    await removeOfflineData(data.id);
                }
            } catch (error) {
                console.error('Sync failed for:', data, error);
            }
        }
    } catch (error) {
        console.error('Background sync failed:', error);
    }
}

// Store data for offline sync
async function storeOfflineData(data) {
    const offlineData = await getOfflineData();
    offlineData.push({
        id: Date.now().toString(),
        timestamp: new Date().toISOString(),
        ...data
    });

    localStorage.setItem('offlineData', JSON.stringify(offlineData));
}

// Get stored offline data
async function getOfflineData() {
    const data = localStorage.getItem('offlineData');
    return data ? JSON.parse(data) : [];
}

// Remove specific offline data
async function removeOfflineData(id) {
    const offlineData = await getOfflineData();
    const filteredData = offlineData.filter(item => item.id !== id);
    localStorage.setItem('offlineData', JSON.stringify(filteredData));
}

// Listen for messages from the main thread
self.addEventListener('message', (event) => {
    if (event.data && event.data.type === 'STORE_OFFLINE') {
        storeOfflineData(event.data.payload);
    }
});
