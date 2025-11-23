# Travel Planner APIs Documentation

This document lists all the APIs used in the Travel Planner app, their endpoints, authentication requirements, and how to obtain API keys.

## Table of Contents
1. [Geocoding API (Nominatim)](#1-geocoding-api-nominatim)
2. [Open-Meteo Weather API](#2-open-meteo-weather-api)
3. [OpenTripMap API](#3-opentripmap-api)
4. [Navitia API](#4-navitia-api)
5. [Amadeus Flight API](#5-amadeus-flight-api)

---

## 1. Geocoding API (Nominatim)

**Service**: OpenStreetMap Nominatim  
**Status**: ✅ **FREE - No API Key Required**  
**Rate Limits**: 1 request per second (be respectful)

### Endpoints

#### Search Location
```
GET https://nominatim.openstreetmap.org/search
```

**Parameters:**
- `q` (required): Search query (e.g., "Paris, France")
- `format`: Response format (default: `json`)
- `limit`: Maximum results (default: 10)
- `addressdetails`: Include address details (1 or 0)

**Example:**
```
https://nominatim.openstreetmap.org/search?q=Paris&format=json&limit=10&addressdetails=1
```

**Headers Required:**
```
User-Agent: YourAppName/1.0
```

#### Reverse Geocoding
```
GET https://nominatim.openstreetmap.org/reverse
```

**Parameters:**
- `lat` (required): Latitude
- `lon` (required): Longitude
- `format`: Response format (default: `json`)

**Example:**
```
https://nominatim.openstreetmap.org/reverse?lat=48.8566&lon=2.3522&format=json
```

### Usage in App
- Location search functionality
- Converting place names to coordinates
- Getting location names from coordinates

### Documentation
- Website: https://nominatim.org/
- Usage Policy: https://operations.osmfoundation.org/policies/nominatim/

---

## 2. Open-Meteo Weather API

**Service**: Open-Meteo  
**Status**: ✅ **FREE - No API Key Required**  
**Rate Limits**: No strict limits (be reasonable)

### Endpoint

#### Daily Weather Forecast
```
GET https://api.open-meteo.com/v1/forecast
```

**Parameters:**
- `latitude` (required): Latitude
- `longitude` (required): Longitude
- `daily`: Comma-separated list of variables
  - `weathercode`: Weather condition code
  - `temperature_2m_max`: Maximum temperature
  - `temperature_2m_min`: Minimum temperature
- `timezone`: Timezone (use `auto` for automatic)

**Example:**
```
https://api.open-meteo.com/v1/forecast?latitude=48.8566&longitude=2.3522&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto
```

### Usage in App
- Weather forecasts for trip locations
- Displaying temperature ranges for itinerary items

### Documentation
- Website: https://open-meteo.com/
- API Docs: https://open-meteo.com/en/docs

---

## 3. OpenTripMap API

**Service**: OpenTripMap  
**Status**: 🔑 **Requires API Key (Free tier available)**

### How to Get API Key
1. Visit: https://opentripmap.io/
2. Sign up for a free account
3. Get your API key from the dashboard
4. Free tier: 1,000 requests/day

### Endpoint

#### Search Nearby Places
```
GET https://api.opentripmap.com/0.1/en/places/radius
```

**Parameters:**
- `lat` (required): Latitude
- `lon` (required): Longitude
- `radius` (required): Search radius in meters
- `apikey` (required): Your API key
- `limit`: Maximum number of results

**Example:**
```
https://api.opentripmap.com/0.1/en/places/radius?radius=5000&lon=2.3522&lat=48.8566&apikey=YOUR_API_KEY&limit=10
```

### Usage in App
- Finding nearby points of interest (POIs)
- Showing attractions near selected locations

### Documentation
- Website: https://opentripmap.io/
- API Docs: https://opentripmap.io/docs

### Running with API Key
```bash
flutter run --dart-define=OPENTRIPMAP_API_KEY=your_key_here
```

---

## 4. Navitia API

**Service**: Navitia (Kisio Digital)  
**Status**: 🔑 **Requires API Key (Free tier available)**  
**Best for**: European public transit

### How to Get API Key
1. Visit: https://www.navitia.io/
2. Sign up for a free account
3. Get your API token from the dashboard
4. Free tier: Limited requests (check current limits)

### Endpoint

#### Get Departures from Stop Area
```
GET https://api.navitia.io/v1/coverage/{region}/stop_areas/{stop_area_id}/departures
```

**Parameters:**
- `{region}`: Coverage region (e.g., `fr-idf` for Île-de-France)
- `{stop_area_id}`: Stop area identifier (e.g., `stop_area:SNCF:87113001`)

**Headers Required:**
```
Authorization: YOUR_API_TOKEN
```

**Example:**
```
GET https://api.navitia.io/v1/coverage/fr-idf/stop_areas/stop_area:SNCF:87113001/departures
Authorization: YOUR_API_TOKEN
```

### Usage in App
- Searching bus/transit departures
- Public transportation information

### Documentation
- Website: https://www.navitia.io/
- API Docs: https://doc.navitia.io/

### Running with API Key
```bash
flutter run --dart-define=NAVITIA_API_KEY=your_token_here
```

---

## 5. Amadeus Flight API

**Service**: Amadeus for Developers  
**Status**: 🔑 **Requires API Keys (Sandbox available for free)**

### How to Get API Keys
1. Visit: https://developers.amadeus.com/
2. Sign up for a free account
3. Create a new app to get:
   - `Client ID`
   - `Client Secret`
4. Sandbox environment is free (test data)
5. Production requires approval

### Endpoints

#### 1. Get Access Token (OAuth2)
```
POST https://test.api.amadeus.com/v1/security/oauth2/token
```

**Headers:**
```
Content-Type: application/x-www-form-urlencoded
```

**Body (form data):**
- `grant_type`: `client_credentials`
- `client_id`: Your Client ID
- `client_secret`: Your Client Secret

**Response:**
```json
{
  "access_token": "token_here",
  "expires_in": 3600
}
```

#### 2. Search Flight Offers
```
GET https://test.api.amadeus.com/v2/shopping/flight-offers
```

**Parameters:**
- `originLocationCode` (required): IATA code (e.g., `PAR`)
- `destinationLocationCode` (required): IATA code (e.g., `NYC`)
- `departureDate` (required): Format `YYYY-MM-DD`
- `adults`: Number of adults (default: 1)
- `currencyCode`: Currency (e.g., `EUR`, `USD`)

**Headers Required:**
```
Authorization: Bearer {access_token}
```

**Example:**
```
GET https://test.api.amadeus.com/v2/shopping/flight-offers?originLocationCode=PAR&destinationLocationCode=NYC&departureDate=2025-02-15&adults=1&currencyCode=EUR
Authorization: Bearer {access_token}
```

### Usage in App
- Searching for flight offers
- Comparing flight prices

### Documentation
- Website: https://developers.amadeus.com/
- API Docs: https://developers.amadeus.com/self-service/category/air/api-doc/flight-offers-search

### Running with API Keys
```bash
flutter run \
  --dart-define=AMADEUS_CLIENT_ID=your_client_id \
  --dart-define=AMADEUS_CLIENT_SECRET=your_client_secret
```

---

## Summary Table

| API Service | Free? | API Key Required? | Rate Limits | Best For |
|------------|-------|-------------------|-------------|----------|
| **Nominatim** | ✅ Yes | ❌ No | 1 req/sec | Location search |
| **Open-Meteo** | ✅ Yes | ❌ No | None (reasonable use) | Weather forecasts |
| **OpenTripMap** | ✅ Yes | ✅ Yes | 1,000/day | Nearby POIs |
| **Navitia** | ✅ Yes | ✅ Yes | Limited | Public transit (EU) |
| **Amadeus** | ✅ Sandbox | ✅ Yes | Varies | Flight search |

---

## Running the App with All API Keys

```bash
flutter run \
  --dart-define=OPENTRIPMAP_API_KEY=your_opentripmap_key \
  --dart-define=NAVITIA_API_KEY=your_navitia_token \
  --dart-define=AMADEUS_CLIENT_ID=your_amadeus_client_id \
  --dart-define=AMADEUS_CLIENT_SECRET=your_amadeus_client_secret
```

## Environment Variables for CI/CD

For GitHub Actions or other CI/CD pipelines, add these as secrets:

- `OPENTRIPMAP_API_KEY`
- `NAVITIA_API_KEY`
- `AMADEUS_CLIENT_ID`
- `AMADEUS_CLIENT_SECRET`

Then use them in your workflow:
```yaml
flutter run \
  --dart-define=OPENTRIPMAP_API_KEY=${{ secrets.OPENTRIPMAP_API_KEY }} \
  --dart-define=NAVITIA_API_KEY=${{ secrets.NAVITIA_API_KEY }} \
  --dart-define=AMADEUS_CLIENT_ID=${{ secrets.AMADEUS_CLIENT_ID }} \
  --dart-define=AMADEUS_CLIENT_SECRET=${{ secrets.AMADEUS_CLIENT_SECRET }}
```

---

## Notes

- **Nominatim** and **Open-Meteo** work without API keys and are perfect for basic functionality
- **OpenTripMap**, **Navitia**, and **Amadeus** require free API keys for enhanced features
- Always respect rate limits and terms of service
- For production apps, consider upgrading to paid tiers for better limits and support

