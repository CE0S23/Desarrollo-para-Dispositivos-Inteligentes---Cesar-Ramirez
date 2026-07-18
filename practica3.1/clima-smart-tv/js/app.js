const DAYS_ES = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
const MONTHS_ES = ['enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio', 'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'];

const CONDITION_VIDEO_FALLBACK = {
  Clear: 'Clear',
  Rain: 'Rain',
  Drizzle: 'Rain',
  Thunderstorm: 'Rain',
  Clouds: 'Rain',
  Snow: 'Rain',
};

let lastCondition = 'Clear';
let weatherDataCache = {};
let currentVideoSrc = '';

const CONDITION_COLORS = {
  Clear: '#1a4d8f',
  Rain: '#37474f',
  Clouds: '#546e7a',
  Thunderstorm: '#263238',
  Snow: '#b0bec5',
  Drizzle: '#455a64',
};

function updateClock() {
  const now = new Date();
  const hours = String(now.getHours()).padStart(2, '0');
  const minutes = String(now.getMinutes()).padStart(2, '0');
  const seconds = String(now.getSeconds()).padStart(2, '0');

  const clockEl = document.getElementById('clock');
  if (clockEl) {
    clockEl.textContent = `${hours}:${minutes}:${seconds}`;
    clockEl.setAttribute('datetime', now.toISOString());
  }

  const dateEl = document.getElementById('current-date');
  if (dateEl) {
    const dayName = DAYS_ES[now.getDay()];
    const day = now.getDate();
    const month = MONTHS_ES[now.getMonth()];
    const year = now.getFullYear();
    dateEl.textContent = `${dayName}, ${day} de ${month} de ${year}`;
  }
}

function updateBackground(condition) {
  if (!condition) condition = 'Clear';
  lastCondition = condition;

  const videoEl = document.getElementById('bg-video');
  if (!videoEl) return;

  const videoCondition = CONDITION_VIDEO_FALLBACK[condition] || null;

  if (videoCondition === null) {
    videoEl.style.display = 'none';
    document.body.style.backgroundImage = '';
    document.body.style.backgroundColor = CONDITION_COLORS[condition] || '#0a0e1a';
    return;
  }

  const media = VIDEO_MAP[videoCondition] || VIDEO_MAP['Clear'];

  if (currentVideoSrc === media.video) return;

  currentVideoSrc = media.video;
  const sourceEl = videoEl.querySelector('source');

  videoEl.style.display = '';
  document.body.style.backgroundImage = '';
  document.body.style.backgroundColor = '';

  if (sourceEl) {
    sourceEl.src = media.video;
  }

  const applyPoster = () => {
    const posterUrl = media.poster;
    const img = new Image();
    img.onload = () => {
      document.body.style.backgroundImage = `url('${posterUrl}')`;
      document.body.style.backgroundSize = 'cover';
      document.body.style.backgroundColor = '';
    };
    img.onerror = () => {
      document.body.style.backgroundImage = '';
      document.body.style.backgroundColor = CONDITION_COLORS[condition] || '#0a0e1a';
    };
    img.src = posterUrl;
  };

  const handleError = () => {
    currentVideoSrc = '';
    videoEl.style.display = 'none';
    applyPoster();
  };

  videoEl.removeEventListener('error', handleError);
  videoEl.addEventListener('error', handleError, { once: true });

  videoEl.poster = media.poster;
  videoEl.load();
  videoEl.play().catch(handleError);
}

function renderCard(city, data) {
  const suffix = cityToSuffix(city);
  const tempEl = document.getElementById(`temp-${suffix}`);
  const conditionEl = document.getElementById(`condition-${suffix}`);
  const humidityEl = document.getElementById(`humidity-${suffix}`);

  if (!data) {
    if (tempEl) tempEl.textContent = '--°C';
    if (conditionEl) conditionEl.textContent = 'Sin datos';
    if (humidityEl) humidityEl.textContent = '--% humedad';
    return;
  }

  if (tempEl) tempEl.textContent = `${data.temp}°C`;
  if (conditionEl) conditionEl.textContent = getConditionInSpanish(data.condition);
  if (humidityEl) humidityEl.textContent = `${data.humidity}% humedad`;
}

function cityToSuffix(city) {
  const map = {
    'Queretaro': 'queretaro',
    'Ciudad de Mexico': 'cdmx',
    'Guadalajara': 'guadalajara',
    'Monterrey': 'monterrey',
  };
  return map[city] || city.toLowerCase().replace(/\s+/g, '');
}

function handleCardSelect(e) {
  const { city } = e.detail;
  const data = weatherDataCache[city];
  if (data) {
    updateBackground(data.condition);
  }
}

function getDominantCondition(weatherData) {
  const conditions = Object.values(weatherData).filter(Boolean).map(d => d.condition);
  if (conditions.length === 0) return 'Clear';

  const counts = {};
  conditions.forEach(c => { counts[c] = (counts[c] || 0) + 1; });

  return Object.entries(counts).sort((a, b) => b[1] - a[1])[0][0];
}

async function loadWeatherData() {
  const { weatherData, errors } = await fetchAllCities();
  weatherDataCache = weatherData;

  if (errors.length > 0) {
    errors.forEach(({ city, error }) => {
      console.warn(`Error cargando ${city}: ${error}`);
    });
  }

  CITIES.forEach(city => {
    renderCard(city, weatherData[city]);
  });

  const dominant = getDominantCondition(weatherData);

  const condEl = document.getElementById('current-condition');
  const conditions = Object.values(weatherData).filter(Boolean);
  if (condEl && conditions.length > 0) {
    condEl.textContent = getConditionInSpanish(dominant);
  }
}

async function init() {
  updateClock();
  setInterval(updateClock, 1000);

  initNavigation();

  document.addEventListener('card-select', handleCardSelect);

  await loadWeatherData();

  const qroData = weatherDataCache['Queretaro'];
  if (qroData) {
    updateBackground(qroData.condition);
  } else {
    updateBackground('Clear');
  }

  setInterval(loadWeatherData, 600000);

  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('sw.js').catch(err => {
      console.warn('Service Worker registration failed:', err);
    });
  }
}

document.addEventListener('DOMContentLoaded', init);
