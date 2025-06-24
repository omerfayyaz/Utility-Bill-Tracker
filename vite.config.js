import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import tailwindcss from '@tailwindcss/vite';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
        tailwindcss(),
        VitePWA({
            registerType: 'autoUpdate',
            includeAssets: ['favicon.ico', 'robots.txt', 'icons/icon.svg'],
            manifest: {
                name: 'Utility Bill Tracker',
                short_name: 'UtilityTracker',
                description: 'Track your utility consumption daily with offline support',
                theme_color: '#14532d',
                background_color: '#f9fafb',
                display: 'standalone',
                start_url: '/',
                icons: [
                    {
                        src: 'icons/icon.svg',
                        sizes: '192x192',
                        type: 'image/svg+xml',
                    },
                ],
            },
            workbox: {
                runtimeCaching: [
                    {
                        urlPattern: /\/api\//,
                        handler: 'NetworkFirst',
                        options: {
                            cacheName: 'api-cache',
                            networkTimeoutSeconds: 3,
                            expiration: { maxEntries: 50, maxAgeSeconds: 300 },
                            backgroundSync: {
                                name: 'api-queue',
                                options: { maxRetentionTime: 1440 },
                            },
                        },
                    },
                    {
                        urlPattern: /\.(?:js|css|html|png|jpg|svg)$/,
                        handler: 'StaleWhileRevalidate',
                        options: { cacheName: 'asset-cache' },
                    },
                ],
            },
        }),
    ],
});
