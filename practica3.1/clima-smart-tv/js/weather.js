const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';

const CITIES = ['Queretaro', 'Ciudad de Mexico', 'Guadalajara', 'Monterrey'];

const VIDEO_MAP = {
  Clear: { video: 'assets/videos/clear.mp4', poster: 'assets/posters/clear.jpg' },
  Clouds: { video: 'assets/videos/clouds.mp4', poster: 'assets/posters/clouds.jpg' },
  Rain: { video: 'assets/videos/rain.mp4', poster: 'assets/posters/rain.jpg' },
  Drizzle: { video: 'assets/videos/drizzle.mp4', poster: 'assets/posters/drizzle.jpg' },
  Thunderstorm: { video: 'assets/videos/thunderstorm.mp4', poster: 'assets/posters/thunderstorm.jpg' },
  Snow: { video: 'assets/videos/snow.mp4', poster: 'assets/posters/snow.jpg' },
};

function sanitizeCity(city) {
  const map = {
    'ciudad de mexico': 'Ciudad de Mexico',
    'cdmx': 'Ciudad de Mexico',
    'mexico city': 'Ciudad de Mexico',
    'queretaro': 'Queretaro',
    'guadalajara': 'Guadalajara',
    'monterrey': 'Monterrey',
    'monterey': 'Monterrey',
  };
  const lower = city.trim().toLowerCase();
  return map[lower] || city.trim();
}

function validateWeatherResponse(data) {
  if (!data || typeof data !== 'object') return false;
  if (!data.main || typeof data.main.temp !== 'number') return false;
  if (!data.weather || !Array.isArray(data.weather) || data.weather.length === 0) return false;
  const w = data.weather[0];
  if (!w.main || typeof w.main !== 'string') return false;
  if (!w.description || typeof w.description !== 'string') return false;
  return true;
}

async function fetchWeather(city) {
  const sanitized = sanitizeCity(city);
  const url = `${BASE_URL}?q=${encodeURIComponent(sanitized)},MX&appid=${API_KEY}&units=metric&lang=es`;

  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 8000);

  try {
    const response = await fetch(url, { signal: controller.signal });

    if (response.status === 401) {
      throw new Error('API key inválida. Verifica OPENWEATHER_API_KEY en .env');
    }
    if (response.status === 404) {
      throw new Error(`Ciudad no encontrada: ${sanitized}`);
    }
    if (!response.ok) {
      throw new Error(`Error HTTP ${response.status}: ${response.statusText}`);
    }

    const data = await response.json();

    if (!validateWeatherResponse(data)) {
      throw new Error(`Respuesta inválida para ${sanitized}`);
    }

    return {
      city: sanitized,
      temp: Math.round(data.main.temp),
      condition: data.weather[0].main,
      description: data.weather[0].description,
      humidity: data.main.humidity,
    };
  } catch (err) {
    if (err.name === 'AbortError') {
      throw new Error(`Tiempo de espera agotado para ${sanitized}`);
    }
    throw err;
  } finally {
    clearTimeout(timeoutId);
  }
}

function getConditionInSpanish(condition) {
  const map = {
    Clear: 'Despejado',
    Clouds: 'Nublado',
    Rain: 'Lluvia',
    Drizzle: 'Llovizna',
    Thunderstorm: 'Tormenta',
    Snow: 'Nieve',
    Mist: 'Niebla',
    Haze: 'Bruma',
    Fog: 'Niebla',
  };
  return map[condition] || condition;
}

async function fetchAllCities() {
  const results = await Promise.allSettled(CITIES.map(city => fetchWeather(city)));

  const weatherData = {};
  const errors = [];

  results.forEach((result, index) => {
    const city = CITIES[index];
    if (result.status === 'fulfilled') {
      weatherData[city] = result.value;
    } else {
      errors.push({ city, error: result.reason.message });
      weatherData[city] = null;
    }
  });

  return { weatherData, errors };
}
