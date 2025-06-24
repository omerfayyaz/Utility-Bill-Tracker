// Minimal service worker: disables all offline/caching features
// Shows a custom offline page if the user is offline

self.addEventListener('fetch', (event) => {
    if (event.request.mode === 'navigate') {
        event.respondWith(
            fetch(event.request).catch(() => {
                return new Response(`
                    <html lang="en">
                    <head><meta name="viewport" content="width=device-width, initial-scale=1"><title>Internet Required</title></head>
                    <body style="display:flex;align-items:center;justify-content:center;height:100vh;background:#f9fafb;font-family:sans-serif;">
                        <div style="text-align:center;">
                            <h1>Internet is required</h1>
                            <p>Please connect to the internet to use this app.</p>
                        </div>
                    </body>
                    </html>
                `, {
                    headers: { 'Content-Type': 'text/html' }
                });
            })
        );
    }
    // For all other requests, just use the network
});
