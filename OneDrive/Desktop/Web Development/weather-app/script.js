// API Configuration
const API_KEY = '912a441477032ae7a4ff33c1dac30588'
const BASE_URL = 'https://api.openweathermap.org/data/2.5';
const GEO_URL = 'http://api.openweathermap.org/geo/1.0';

// State
let currentUnit = 'metric'; // 'metric' for °C, 'imperial' for °F
let currentCity = 'London';
let recentSearches = JSON.parse(localStorage.getItem('recentSearches')) || ['London', 'New York', 'Tokyo'];

// DOM Elements
const loadingScreen = document.getElementById('loadingScreen');
const cityInput = document.getElementById('cityInput');
const searchBtn = document.getElementById('searchBtn');
const locationBtn = document.getElementById('locationBtn');
const unitToggle = document.getElementById('unitToggle');
const recentSearchesContainer = document.getElementById('recentSearches');
const errorModal = document.getElementById('errorModal');
const errorMessage = document.getElementById('errorMessage');
const retryBtn = document.getElementById('retryBtn');
const closeModal = document.querySelector('.close-modal');

// Chart
let tempChart = null;

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    initRecentSearches();
    loadWeatherData(currentCity);
    updateLastUpdated();
    
    // Event Listeners
    searchBtn.addEventListener('click', handleSearch);
    cityInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') handleSearch();
    });
    
    locationBtn.addEventListener('click', getLocationWeather);
    unitToggle.addEventListener('click', toggleUnits);
    retryBtn.addEventListener('click', () => loadWeatherData(currentCity));
    closeModal.addEventListener('click', () => errorModal.classList.remove('active'));
    
    // Close modal on outside click
    errorModal.addEventListener('click', (e) => {
        if (e.target === errorModal) {
            errorModal.classList.remove('active');
        }
    });
});

// Recent Searches
function initRecentSearches() {
    recentSearchesContainer.innerHTML = '<span>Recent:</span>';
    recentSearches.forEach(city => {
        const btn = document.createElement('button');
        btn.className = 'recent-city';
        btn.textContent = city;
        btn.addEventListener('click', () => {
            cityInput.value = city;
            loadWeatherData(city);
        });
        recentSearchesContainer.appendChild(btn);
    });
}

function addToRecentSearches(city) {
    if (!recentSearches.includes(city)) {
        recentSearches.unshift(city);
        if (recentSearches.length > 5) recentSearches.pop();
        localStorage.setItem('recentSearches', JSON.stringify(recentSearches));
        initRecentSearches();
    }
}

// Handle Search
function handleSearch() {
    const city = cityInput.value.trim();
    if (city) {
        loadWeatherData(city);
        cityInput.value = '';
    }
}

// Get Location
function getLocationWeather() {
    if (!navigator.geolocation) {
        showError('Geolocation is not supported by your browser');
        return;
    }
    
    loadingScreen.classList.remove('hidden');
    navigator.geolocation.getCurrentPosition(
        async (position) => {
            try {
                const { latitude, longitude } = position.coords;
                const city = await getCityName(latitude, longitude);
                loadWeatherData(city);
            } catch (error) {
                showError('Unable to get location. Please search manually.');
            }
        },
        () => {
            loadingScreen.classList.add('hidden');
            showError('Location access denied. Please enable location services.');
        }
    );
}

// Toggle Units
function toggleUnits() {
    currentUnit = currentUnit === 'metric' ? 'imperial' : 'metric';
    unitToggle.classList.toggle('active', currentUnit === 'metric');
    loadWeatherData(currentCity);
}

// Load Weather Data
async function loadWeatherData(city) {
    try {
        loadingScreen.classList.remove('hidden');
        currentCity = city;
        
        // Get coordinates first
        const coords = await getCoordinates(city);
        if (!coords) {
            throw new Error('City not found');
        }
        
        // Fetch current weather and forecast in parallel
        const [currentData, forecastData, airQualityData] = await Promise.all([
            fetchCurrentWeather(coords.lat, coords.lon),
            fetchForecast(coords.lat, coords.lon),
            fetchAirQuality(coords.lat, coords.lon)
        ]);
        
        updateCurrentWeather(currentData);
        updateForecast(forecastData);
        updateAirQuality(airQualityData);
        updateUVIndex(currentData);
        updateDayLength(currentData.sys);
        
        addToRecentSearches(city);
        updateLastUpdated();
        
        // Animate update
        document.getElementById('currentWeather').classList.add('animate__animated', 'animate__fadeIn');
        setTimeout(() => {
            document.getElementById('currentWeather').classList.remove('animate__animated', 'animate__fadeIn');
        }, 1000);
        
    } catch (error) {
        console.error('Error:', error);
        showError(`Unable to fetch weather data for "${city}". Please try again.`);
    } finally {
        loadingScreen.classList.add('hidden');
    }
}

// API Functions
async function getCoordinates(city) {
    const response = await fetch(
        `${GEO_URL}/direct?q=${encodeURIComponent(city)}&limit=1&appid=${API_KEY}`
    );
    const data = await response.json();
    return data[0];
}

async function getCityName(lat, lon) {
    const response = await fetch(
        `${GEO_URL}/reverse?lat=${lat}&lon=${lon}&limit=1&appid=${API_KEY}`
    );
    const data = await response.json();
    return data[0].name;
}

async function fetchCurrentWeather(lat, lon) {
    const response = await fetch(
        `${BASE_URL}/weather?lat=${lat}&lon=${lon}&units=${currentUnit}&appid=${API_KEY}`
    );
    return await response.json();
}

async function fetchForecast(lat, lon) {
    const response = await fetch(
        `${BASE_URL}/forecast?lat=${lat}&lon=${lon}&units=${currentUnit}&appid=${API_KEY}`
    );
    return await response.json();
}

async function fetchAirQuality(lat, lon) {
    try {
        const response = await fetch(
            `${BASE_URL}/air_pollution?lat=${lat}&lon=${lon}&appid=${API_KEY}`
        );
        return await response.json();
    } catch {
        return null; // Air quality API might fail on free tier
    }
}

// Update UI Functions
function updateCurrentWeather(data) {
    // City and Date
    document.getElementById('cityName').textContent = `${data.name}, ${data.sys.country}`;
    document.getElementById('currentDate').textContent = formatDate(data.dt * 1000);
    
    // Temperature
    const temp = Math.round(data.main.temp);
    const feelsLike = Math.round(data.main.feels_like);
    document.getElementById('currentTemp').textContent = temp;
    document.getElementById('feelsLike').textContent = feelsLike;
    
    // Weather Condition
    const weather = data.weather[0];
    document.getElementById('weatherIcon').src = `https://openweathermap.org/img/wn/${weather.icon}@2x.png`;
    document.getElementById('weatherDescription').textContent = weather.description;
    
    // Weather Details
    document.getElementById('windSpeed').textContent = `${data.wind.speed} ${currentUnit === 'metric' ? 'm/s' : 'mph'}`;
    document.getElementById('humidity').textContent = `${data.main.humidity}%`;
    document.getElementById('pressure').textContent = `${data.main.pressure} hPa`;
    document.getElementById('visibility').textContent = `${(data.visibility / 1000).toFixed(1)} km`;
    
    // Sunrise/Sunset
    document.getElementById('sunrise').textContent = formatTime(data.sys.sunrise * 1000);
    document.getElementById('sunset').textContent = formatTime(data.sys.sunset * 1000);
    
    // Update background based on weather
    updateWeatherBackground(weather.main);
}

function updateForecast(data) {
    const forecastList = document.getElementById('forecastList');
    forecastList.innerHTML = '';
    
    // Group by day
    const dailyData = {};
    data.list.forEach(item => {
        const date = new Date(item.dt * 1000).toDateString();
        if (!dailyData[date]) {
            dailyData[date] = {
                temps: [],
                weather: []
            };
        }
        dailyData[date].temps.push(item.main.temp);
        dailyData[date].weather.push(item.weather[0]);
    });
    
    // Get next 5 days
    const days = Object.keys(dailyData).slice(0, 5);
    
    days.forEach((date, index) => {
        const dayData = dailyData[date];
        const avgTemp = Math.round(dayData.temps.reduce((a, b) => a + b) / dayData.temps.length);
        const maxTemp = Math.round(Math.max(...dayData.temps));
        const minTemp = Math.round(Math.min(...dayData.temps));
        const mainWeather = getMostFrequentWeather(dayData.weather);
        
        const forecastItem = document.createElement('div');
        forecastItem.className = 'forecast-item animate-in';
        forecastItem.style.animationDelay = `${index * 0.1}s`;
        
        forecastItem.innerHTML = `
            <div class="forecast-day">${formatDay(date)}</div>
            <div class="forecast-icon">
                <img src="https://openweathermap.org/img/wn/${mainWeather.icon}.png" alt="${mainWeather.description}">
            </div>
            <div class="forecast-temp">
                <span class="temp-high">${maxTemp}°</span>
                <span class="temp-low">${minTemp}°</span>
            </div>
        `;
        
        forecastList.appendChild(forecastItem);
    });
    
    // Update temperature chart
    updateTemperatureChart(data.list.slice(0, 8)); // Next 24 hours (3-hour intervals)
}

function updateTemperatureChart(hourlyData) {
    const ctx = document.getElementById('temperatureChart').getContext('2d');
    
    // Destroy existing chart
    if (tempChart) {
        tempChart.destroy();
    }
    
    const labels = hourlyData.map(item => 
        new Date(item.dt * 1000).getHours() + ':00'
    );
    
    const temperatures = hourlyData.map(item => Math.round(item.main.temp));
    
    tempChart = new Chart(ctx, {
        type: 'line',
        data: {
            labels: labels,
            datasets: [{
                label: 'Temperature',
                data: temperatures,
                borderColor: '#ff006e',
                backgroundColor: 'rgba(255, 0, 110, 0.1)',
                borderWidth: 3,
                fill: true,
                tension: 0.4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: false
                }
            },
            scales: {
                y: {
                    grid: {
                        color: 'rgba(0, 0, 0, 0.1)'
                    },
                    ticks: {
                        callback: function(value) {
                            return value + '°';
                        }
                    }
                },
                x: {
                    grid: {
                        color: 'rgba(0, 0, 0, 0.1)'
                    }
                }
            }
        }
    });
}

function updateAirQuality(data) {
    if (!data || !data.list || data.list.length === 0) {
        document.getElementById('aqiValue').textContent = '--';
        document.getElementById('aqiLabel').textContent = 'Data unavailable';
        return;
    }
    
    const aqi = data.list[0].main.aqi;
    const aqiLabels = ['Good', 'Fair', 'Moderate', 'Poor', 'Very Poor'];
    const aqiColors = ['#4CAF50', '#8BC34A', '#FFC107', '#FF9800', '#F44336'];
    
    document.getElementById('aqiValue').textContent = aqi;
    document.getElementById('aqiLabel').textContent = aqiLabels[aqi - 1];
    document.getElementById('aqiValue').style.color = aqiColors[aqi - 1];
}

function updateUVIndex(data) {
    // Note: UV index requires separate API call in OpenWeatherMap premium
    // For demo, we'll simulate based on time of day and cloudiness
    const hour = new Date(data.dt * 1000).getHours();
    const clouds = data.clouds.all;
    
    // Simulate UV index (0-11 scale)
    let uvIndex = Math.min(11, Math.max(0, 
        (hour >= 10 && hour <= 14 ? 8 : 4) * (1 - clouds/100)
    ));
    
    uvIndex = Math.round(uvIndex * 10) / 10;
    
    document.getElementById('uvValue').textContent = uvIndex;
    
    let uvLabel = 'Low';
    if (uvIndex >= 3) uvLabel = 'Moderate';
    if (uvIndex >= 6) uvLabel = 'High';
    if (uvIndex >= 8) uvLabel = 'Very High';
    if (uvIndex >= 11) uvLabel = 'Extreme';
    
    document.getElementById('uvLabel').textContent = uvLabel;
    document.getElementById('uvFill').style.width = `${(uvIndex / 11) * 100}%`;
}

function updateDayLength(sunData) {
    const sunrise = sunData.sunrise * 1000;
    const sunset = sunData.sunset * 1000;
    const dayLength = sunset - sunrise;
    
    const hours = Math.floor(dayLength / (1000 * 60 * 60));
    const minutes = Math.floor((dayLength % (1000 * 60 * 60)) / (1000 * 60));
    
    document.getElementById('dayLength').textContent = `${hours}h ${minutes}m`;
    document.getElementById('sunriseTime').textContent = formatTime(sunrise);
    document.getElementById('sunsetTime').textContent = formatTime(sunset);
    
    // Calculate progress through day
    const now = Date.now();
    const dayProgress = ((now - sunrise) / (sunset - sunrise)) * 100;
    document.getElementById('dayProgress').style.width = `${Math.min(100, Math.max(0, dayProgress))}%`;
}

function updateWeatherBackground(weatherCondition) {
    const weatherCard = document.querySelector('.weather-card');
    
    // Remove existing weather classes
    weatherCard.classList.remove('clear', 'clouds', 'rain', 'snow');
    
    // Add new class based on condition
    switch(weatherCondition.toLowerCase()) {
        case 'clear':
            weatherCard.classList.add('clear');
            break;
        case 'clouds':
            weatherCard.classList.add('clouds');
            break;
        case 'rain':
        case 'drizzle':
        case 'thunderstorm':
            weatherCard.classList.add('rain');
            break;
        case 'snow':
            weatherCard.classList.add('snow');
            break;
    }
}

// Utility Functions
function formatDate(timestamp) {
    return new Date(timestamp).toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

function formatTime(timestamp) {
    return new Date(timestamp).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: false
    });
}

function formatDay(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-US', { weekday: 'short' });
}

function getMostFrequentWeather(weatherArray) {
    const counts = {};
    let max = 0;
    let result;
    
    weatherArray.forEach(w => {
        counts[w.id] = (counts[w.id] || 0) + 1;
        if (counts[w.id] > max) {
            max = counts[w.id];
            result = w;
        }
    });
    
    return result;
}

function updateLastUpdated() {
    const now = new Date();
    document.getElementById('lastUpdated').textContent = 
        now.toLocaleTimeString('en-US', { 
            hour: '2-digit', 
            minute: '2-digit',
            second: '2-digit'
        });
}

function showError(message) {
    errorMessage.textContent = message;
    errorModal.classList.add('active');
}

// Weather Map Integration (Optional - using OpenWeatherMap maps)
document.getElementById('loadMapBtn').addEventListener('click', function() {
    const mapContainer = document.getElementById('weatherMap');
    mapContainer.innerHTML = `
        <iframe 
            width="100%" 
            height="400" 
            frameborder="0" 
            scrolling="no" 
            marginheight="0" 
            marginwidth="0" 
            src="https://openweathermap.org/weathermap?basemap=map&cities=true&layer=temperature&lat=51.5&lon=0&zoom=5">
        </iframe>
    `;
    
    this.style.display = 'none';
});

// Map layer controls
document.querySelectorAll('.map-layer').forEach(button => {
    button.addEventListener('click', function() {
        document.querySelectorAll('.map-layer').forEach(btn => btn.classList.remove('active'));
        this.classList.add('active');
        
        // In a real implementation, you would update the map layer here
        // This requires a more complex map integration
    });
});

// Initialize with default city
loadWeatherData(currentCity);