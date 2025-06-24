import localforage from 'localforage';

localforage.config({ name: 'utility-bill-logger' });

// Cache fetched data under a key
export async function cacheData(key, data) {
  await localforage.setItem(`data:${key}`, data);
}

// Retrieve cached data or return empty array
export async function getData(key) {
  return (await localforage.getItem(`data:${key}`)) || [];
}

// Queue an offline change
export async function queueChange(model, payload) {
  const queue = (await localforage.getItem('offline-queue')) || [];
  queue.push({ model, payload, timestamp: Date.now() });
  await localforage.setItem('offline-queue', queue);
}

// Pull and clear queued changes
export async function pullQueue() {
  const queue = (await localforage.getItem('offline-queue')) || [];
  await localforage.removeItem('offline-queue');
  return queue;
}
