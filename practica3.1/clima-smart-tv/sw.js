const CACHE_STATIC = 'clima-static-v1';
const CACHE_DYNAMIC = 'clima-dynamic-v1';

const STATIC_URLS = [
  '/',
  '/index.html',
  '/css/styles.css',
  '/js/app.js',
  '/js/weather.js',
  '/js/navigation.js',
  '/js/config.local.js',
  '/manifest.json',
  '/icons/icon-192.png',
  '/icons/icon-512.png',
  '/assets/posters/clear.jpg',
  '/assets/posters/rain.jpg',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_STATIC).then(async (cache) => {
      await Promise.allSettled(
        STATIC_URLS.map(url =>
          cache.add(url).catch(err =>
            console.warn(`No se pudo cachear ${url}:`, err.message)
          )
        )
      );
    })
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  const allowedCaches = [CACHE_STATIC, CACHE_DYNAMIC];
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (!allowedCaches.includes(key)) {
            return caches.delete(key);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  if (event.request.destination === 'video' || url.pathname.includes('/assets/videos/')) {
    return;
  }

  if (url.protocol !== 'http:' && url.protocol !== 'https:') return;
  if (event.request.method !== 'GET') return;

  const isAPI = url.hostname === 'api.openweathermap.org';

  if (isAPI) {
    event.respondWith(networkFirstWithTimeout(event.request));
  } else {
    event.respondWith(cacheFirst(event.request));
  }
});

async function cacheFirst(request) {
  const cached = await caches.match(request);
  if (cached) return cached;

  try {
    const response = await fetch(request);
    if (response && response.ok) {
      const cache = await caches.open(CACHE_DYNAMIC);
      await cache.put(request, response.clone());
    }
    return response;
  } catch {
    return new Response('', { status: 408, statusText: 'Offline' });
  }
}

async function networkFirstWithTimeout(request) {
  const timeout = 5000;
  const timeoutPromise = new Promise((_, reject) =>
    setTimeout(() => reject(new Error('Network timeout')), timeout)
  );

  try {
    const response = await Promise.race([
      fetch(request),
      timeoutPromise,
    ]);

    if (response && response.ok) {
      const cache = await caches.open(CACHE_DYNAMIC);
      await cache.put(request, response.clone());
    }
    return response;
  } catch {
    const cached = await caches.match(request);
    if (cached) return cached;
    return new Response(
      JSON.stringify({ error: 'No hay conexión y no hay datos en caché' }),
      { status: 503, headers: { 'Content-Type': 'application/json' } }
    );
  }
}
