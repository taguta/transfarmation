"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.refreshWeatherNow = exports.refreshWeatherForecasts = exports.monitorIotTelemetry = exports.notifyOnCommunityAlert = exports.onFarmModified = exports.rollupGroupOrderQuantities = exports.rollupSavingsTransactions = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();
const db = admin.firestore();
// 1. Maintain `totalSaved` for Savings Groups
// This executes whenever a savings transaction is added, updated, or deleted.
exports.rollupSavingsTransactions = functions.firestore
    .document('savings_transactions/{txId}')
    .onWrite(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    // Identify the group associated with the transaction
    const groupId = (afterData === null || afterData === void 0 ? void 0 : afterData.groupId) || (beforeData === null || beforeData === void 0 ? void 0 : beforeData.groupId);
    if (!groupId)
        return null;
    // Calculate delta amount
    // Assumes unconfirmed transactions or failed ones shouldn't be counted (adjust logic to your confirmed rules)
    const beforeAmount = (beforeData && beforeData.isConfirmed === 1) ? (beforeData.amount || 0) : 0;
    const afterAmount = (afterData && afterData.isConfirmed === 1) ? (afterData.amount || 0) : 0;
    const difference = afterAmount - beforeAmount;
    // Only update if there's an actual change in the recognized balance
    if (difference === 0)
        return null;
    return db.doc(`savings_groups/${groupId}`).update({
        totalSaved: admin.firestore.FieldValue.increment(difference),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
});
// 2. Maintain `currentQuantity` for Group Orders
// Executes whenever a participant joins, updates, or leaves a group order
exports.rollupGroupOrderQuantities = functions.firestore
    .document('group_orders/{orderId}/participants/{participantId}')
    .onWrite(async (change, context) => {
    var _a, _b;
    const orderId = context.params.orderId;
    const beforeQuantity = ((_a = change.before.data()) === null || _a === void 0 ? void 0 : _a.quantity) || 0;
    const afterQuantity = ((_b = change.after.data()) === null || _b === void 0 ? void 0 : _b.quantity) || 0;
    const difference = afterQuantity - beforeQuantity;
    if (difference === 0)
        return null;
    return db.doc(`group_orders/${orderId}`).update({
        currentQuantity: admin.firestore.FieldValue.increment(difference),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
});
// 3. Mark Farm Updated Timestamp
// Triggered to update `updatedAt` on a farm when sub-details or arrays are modified
exports.onFarmModified = functions.firestore
    .document('farms/{farmId}')
    .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    // Prevent infinite loops by checking if only `updatedAt` changed
    if (change.after.isEqual(change.before))
        return null;
    // If the client didn't supply an updated timestamp, force it server-side
    // This allows the Delta Polling mechanism (Client-side) to catch the update implicitly
    if (beforeData.updatedAt === afterData.updatedAt) {
        return change.after.ref.update({
            updatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
    }
    return null;
});
// 4. Send Push Notifications for Community Alerts
// Triggers when a new post is categorized as isAlert (e.g. disease outbreak in a region)
exports.notifyOnCommunityAlert = functions.firestore
    .document('community_posts/{postId}')
    .onCreate(async (snapshot, context) => {
    const data = snapshot.data();
    if (data.isAlert === true) {
        const payload = {
            notification: {
                title: `⚠️ FARMER ALERT: ${data.region}`,
                body: data.title || 'A new urgent agricultural alert was posted in your region.',
            },
            topic: `region_${data.region.replace(/\s+/g, '_').toLowerCase()}`,
        };
        try {
            await admin.messaging().send(payload);
            console.log(`Alert sent to topic region_${data.region}`);
        }
        catch (error) {
            console.error("Error sending alert notification:", error);
        }
    }
});
// 5. Smart IoT Telemetry Monitor
// Sends a push notification if an IoT device reports dangerously low soil moisture
exports.monitorIotTelemetry = functions.firestore
    .document('iot_telemetry/{readingId}')
    .onCreate(async (snapshot, context) => {
    var _a, _b, _c;
    const data = snapshot.data();
    if (data.sensorType === 'soil_moisture' && data.value < 15.0) {
        // Find the user who owns this sensor
        const sensorDoc = await db.collection('iot_devices').doc(data.deviceId).get();
        if (!sensorDoc.exists)
            return;
        const userId = (_a = sensorDoc.data()) === null || _a === void 0 ? void 0 : _a.ownerId;
        if (!userId)
            return;
        const userDoc = await db.collection('users').doc(userId).get();
        const fcmToken = (_b = userDoc.data()) === null || _b === void 0 ? void 0 : _b.fcmToken;
        if (fcmToken) {
            await admin.messaging().send({
                token: fcmToken,
                notification: {
                    title: '💧 Irrigation Warning!',
                    body: `Moisture levels for ${((_c = sensorDoc.data()) === null || _c === void 0 ? void 0 : _c.name) || 'your field'} dropped below critical threshold.`,
                }
            });
        }
    }
});
// 6. Weather forecasts (Open-Meteo → weather_forecasts)
var weather_1 = require("./weather");
Object.defineProperty(exports, "refreshWeatherForecasts", { enumerable: true, get: function () { return weather_1.refreshWeatherForecasts; } });
Object.defineProperty(exports, "refreshWeatherNow", { enumerable: true, get: function () { return weather_1.refreshWeatherNow; } });
//# sourceMappingURL=index.js.map