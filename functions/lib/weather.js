"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.refreshWeatherNow = exports.refreshWeatherForecasts = exports.refreshAll = exports.conditionFromWmo = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
/**
 * Keeps the `weather_forecasts` collection filled with a 7-day forecast per
 * province, pulled from Open-Meteo (free, no API key). The app reads this
 * collection by `region` and `date` (see weather_firestore.dart).
 */
// Region names must match what the app queries (e.g. 'Mashonaland East').
const REGIONS = {
    'Harare': { lat: -17.83, lon: 31.05 },
    'Bulawayo': { lat: -20.15, lon: 28.58 },
    'Manicaland': { lat: -18.97, lon: 32.67 },
    'Mashonaland Central': { lat: -17.3, lon: 31.33 },
    'Mashonaland East': { lat: -18.19, lon: 31.55 },
    'Mashonaland West': { lat: -17.37, lon: 30.2 },
    'Masvingo': { lat: -20.07, lon: 30.83 },
    'Matabeleland North': { lat: -18.93, lon: 27.8 },
    'Matabeleland South': { lat: -20.93, lon: 29.0 },
    'Midlands': { lat: -19.45, lon: 29.82 },
};
/** Maps a WMO weather code onto the conditions the app has icons for. */
function conditionFromWmo(code) {
    if (code <= 1)
        return 'sunny';
    if (code === 2)
        return 'partly_cloudy';
    if (code >= 95)
        return 'thunderstorm';
    if ((code >= 51 && code <= 67) || (code >= 80 && code <= 82))
        return 'rain';
    return 'cloudy';
}
exports.conditionFromWmo = conditionFromWmo;
async function fetchDaily(lat, lon) {
    const params = new URLSearchParams({
        latitude: String(lat),
        longitude: String(lon),
        daily: [
            'weather_code',
            'temperature_2m_max',
            'temperature_2m_min',
            'precipitation_sum',
            'precipitation_probability_max',
            'wind_speed_10m_max',
            'relative_humidity_2m_mean',
        ].join(','),
        timezone: 'Africa/Harare',
        forecast_days: '7',
    });
    const res = await fetch(`https://api.open-meteo.com/v1/forecast?${params}`);
    if (!res.ok)
        throw new Error(`Open-Meteo responded ${res.status}`);
    const body = (await res.json());
    if (!body.daily)
        throw new Error('Open-Meteo response had no daily block');
    return body.daily;
}
/** Replaces one region's forecast; returns the number of days written. */
async function refreshRegion(region, lat, lon) {
    const db = admin.firestore();
    const daily = await fetchDaily(lat, lon);
    const slug = region.toLowerCase().replace(/\s+/g, '_');
    const batch = db.batch();
    const keep = new Set();
    daily.time.forEach((day, i) => {
        var _a, _b;
        const id = `${slug}_${day}`;
        keep.add(id);
        batch.set(db.collection('weather_forecasts').doc(id), {
            region,
            // Midday Harare time, so the calendar day is unambiguous in any zone.
            date: admin.firestore.Timestamp.fromDate(new Date(`${day}T12:00:00+02:00`)),
            condition: conditionFromWmo(daily.weather_code[i]),
            tempHigh: Math.round(daily.temperature_2m_max[i]),
            tempLow: Math.round(daily.temperature_2m_min[i]),
            rainChance: Math.round((_a = daily.precipitation_probability_max[i]) !== null && _a !== void 0 ? _a : 0),
            rainfall: Math.round(daily.precipitation_sum[i] * 10) / 10,
            humidity: Math.round((_b = daily.relative_humidity_2m_mean[i]) !== null && _b !== void 0 ? _b : 0),
            windSpeed: `${Math.round(daily.wind_speed_10m_max[i])} km/h`,
            source: 'open-meteo',
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
    });
    // The app asks for the 7 oldest docs by date, so past days must go.
    const existing = await db.collection('weather_forecasts').where('region', '==', region).get();
    existing.docs.filter((d) => !keep.has(d.id)).forEach((d) => batch.delete(d.ref));
    await batch.commit();
    return daily.time.length;
}
async function refreshAll() {
    const results = {};
    for (const [region, { lat, lon }] of Object.entries(REGIONS)) {
        try {
            results[region] = await refreshRegion(region, lat, lon);
        }
        catch (err) {
            // One failing province must not block the rest.
            results[region] = `failed: ${err.message}`;
            functions.logger.error(`Forecast refresh failed for ${region}`, err);
        }
    }
    return results;
}
exports.refreshAll = refreshAll;
/** Runs every 6 hours. */
exports.refreshWeatherForecasts = functions.pubsub
    .schedule('every 6 hours')
    .timeZone('Africa/Harare')
    .onRun(async () => {
    const results = await refreshAll();
    functions.logger.info('Weather forecasts refreshed', results);
    return null;
});
/**
 * Manual trigger for the first fill (and for debugging): call
 *   https://<region>-<project>.cloudfunctions.net/refreshWeatherNow
 * Callable by admins only (a signed-in user with an admins/{uid} document,
 * the same rule firestore.rules uses).
 */
exports.refreshWeatherNow = functions.https.onCall(async (_data, context) => {
    var _a;
    const uid = (_a = context.auth) === null || _a === void 0 ? void 0 : _a.uid;
    const isAdmin = uid ? (await admin.firestore().doc(`admins/${uid}`).get()).exists : false;
    if (!isAdmin) {
        throw new functions.https.HttpsError('permission-denied', 'Admins only.');
    }
    return refreshAll();
});
//# sourceMappingURL=weather.js.map