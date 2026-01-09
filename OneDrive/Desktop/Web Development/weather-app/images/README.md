 SkyWatch Weather Dashboard
A beautiful, responsive weather dashboard that provides real-time weather data, forecasts, and interactive visualizations using the OpenWeatherMap API.

Live Demo
View Live Site: https://github.com/Wilfred123816/Weather-App.git

Features
Real-time Weather Data - Current conditions, temperature, humidity, wind speed

5-Day Forecast - Daily weather predictions with high/low temperatures

Interactive Charts - Temperature trends using Chart.js

Air Quality Index - Real-time air pollution data

UV Index Tracking - Sun exposure safety information

Geo-location - Automatic location detection

City Search - Search any city worldwide

Recent Searches - Quick access to previously searched cities

Unit Toggle - Switch between °C and °F

Responsive Design - Works on mobile, tablet, and desktop

Weather Animations - Visual feedback for different weather conditions


Technologies Used
HTML5 - Semantic markup

CSS3 - Flexbox, Grid, CSS Variables, Animations

JavaScript (ES6+) - Async/await, Fetch API, LocalStorage

OpenWeatherMap API - Real-time weather data

Chart.js - Data visualization

Animate.css - CSS animations

Font Awesome - Icons

Google Fonts - Typography


Key Learnings
API integration and handling asynchronous data

Error handling and user feedback

Dynamic DOM manipulation

Chart creation and data visualization

LocalStorage for persistent data

Responsive design with CSS Grid

Mobile-first development approach

Weather condition-based UI theming


Setup Instructions
1. Get API Key
Go to OpenWeatherMap

Sign up for a free account

Verify your email

Navigate to API Keys

Copy your API key (starts with letters/numbers)

2. Configure API Key
Open script.js and replace the API key:

javascript
const API_KEY = 'YOUR_API_KEY_HERE'; // Replace with your key
3. Run Locally
bash
# Clone the repository
git clone https://github.com/Wilfred123816/Weather-App.git

# Navigate to project directory
cd weather-app

# Open in browser
open index.html
# or
start index.html

Project Structure
text
weather-app/
├── index.html          # Main HTML file
├── style.css          # All CSS styles
├── script.js          # JavaScript with API integration
├── images/            # Weather icons and backgrounds
├── README.md          # Documentation (this file)
└── .gitignore         # Git ignore file

API Endpoints Used
Current Weather: api.openweathermap.org/data/2.5/weather

5-Day Forecast: api.openweathermap.org/data/2.5/forecast

Air Pollution: api.openweathermap.org/data/2.5/air_pollution

Geocoding: api.openweathermap.org/geo/1.0/direct

Reverse Geocoding: api.openweathermap.org/geo/1.0/reverse


Design Features
Dynamic Backgrounds - Changes based on weather conditions

Weather Icons - Real weather icons from OpenWeatherMap

Temperature Charts - Interactive line charts for temperature trends

Progress Bars - Visual indicators for UV index and day length

Toast Notifications - Error handling and user feedback

Loading States - Smooth loading animations

Responsive Grid - Adapts to all screen sizes

Responsive Breakpoints
Mobile: 320px - 480px

Tablet: 481px - 768px

Desktop: 769px - 1200px

Large Desktop: 1201px+


Performance Optimizations
Lazy loading for weather map

Cached API responses

Optimized image assets

Minimized API calls

Efficient chart rendering


Known Issues & Limitations
Free OpenWeatherMap API has rate limits (60 calls/minute)

Air quality data might not be available for all locations

UV index is simulated (requires premium API for real data)

Weather map requires manual activation due to iframe limitations

Future Enhancements
Weather alerts and notifications

Historical weather data

Multiple location tracking

Weather widget creation

Dark/light mode toggle

Weather-related tips and recommendations

Weather data export (PDF/CSV)

Voice search functionality

PWA (Progressive Web App) capabilities


Contributing
Contributions are welcome! Please follow these steps:

Fork the repository

Create a feature branch (git checkout -b feature/AmazingFeature)

Commit your changes (git commit -m 'Add some AmazingFeature')

Push to the branch (git push origin feature/AmazingFeature)

Open a Pull Request


License
This project is licensed under the MIT License - see the LICENSE file for details.


Acknowledgments
OpenWeatherMap for providing the weather API

Chart.js for beautiful charts

Animate.css for animations

Font Awesome for icons

Unsplash for beautiful background images

Author
Wilfred Monyenye

GitHub: @Wilfred123816

Portfolio: wilfredmonyenye.github.io

LinkedIn: Wilfred Monyenye

Support
For support, please:

Check the OpenWeatherMap FAQ

Open an issue in this repository

Contact via email: wilfredmonyenye@gmail.com

API Usage Example
javascript
// Example API call for current weather
const response = await fetch(
  `https://api.openweathermap.org/data/2.5/weather?q=London&units=metric&appid=${API_KEY}`
);
const data = await response.json();
Quick Start for Developers
bash
# 1. Clone and setup
git clone https://github.com/Wilfred123816/weather-app.git
cd weather-app

# 2. Get API key from OpenWeatherMap
# 3. Update script.js with your API key
# 4. Open index.html in browser

# 5. Optional: Use Live Server in VS Code
#    Install Live Server extension
#    Right-click index.html → "Open with Live Server"
Star History
If you find this project useful, please give it a star!

Made with love by Wilfred Monyenye

Last Updated: January 202