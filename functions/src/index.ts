import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

// 1. Maintain `totalSaved` for Savings Groups
// This executes whenever a savings transaction is added, updated, or deleted.
export const rollupSavingsTransactions = functions.firestore
  .document('savings_transactions/{txId}')
  .onWrite(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Identify the group associated with the transaction
    const groupId = afterData?.groupId || beforeData?.groupId;
    if (!groupId) return null;

    // Calculate delta amount
    // Assumes unconfirmed transactions or failed ones shouldn't be counted (adjust logic to your confirmed rules)
    const beforeAmount = (beforeData && beforeData.isConfirmed === 1) ? (beforeData.amount || 0) : 0;
    const afterAmount = (afterData && afterData.isConfirmed === 1) ? (afterData.amount || 0) : 0;
    
    const difference = afterAmount - beforeAmount;

    // Only update if there's an actual change in the recognized balance
    if (difference === 0) return null;

    return db.doc(`savings_groups/${groupId}`).update({
        totalSaved: admin.firestore.FieldValue.increment(difference),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  });

// 2. Maintain `currentQuantity` for Group Orders
// Executes whenever a participant joins, updates, or leaves a group order
export const rollupGroupOrderQuantities = functions.firestore
  .document('group_orders/{orderId}/participants/{participantId}')
  .onWrite(async (change: functions.Change<functions.firestore.DocumentSnapshot>, context: functions.EventContext) => {
    const orderId = context.params.orderId;

    const beforeQuantity = change.before.data()?.quantity || 0;
    const afterQuantity = change.after.data()?.quantity || 0;
    
    const difference = afterQuantity - beforeQuantity;

    if (difference === 0) return null;

    return db.doc(`group_orders/${orderId}`).update({
        currentQuantity: admin.firestore.FieldValue.increment(difference),
        updatedAt: admin.firestore.FieldValue.serverTimestamp()
    });
  });

// 3. Mark Farm Updated Timestamp
// Triggered to update `updatedAt` on a farm when sub-details or arrays are modified
export const onFarmModified = functions.firestore
  .document('farms/{farmId}')
  .onUpdate(async (change: functions.Change<functions.firestore.QueryDocumentSnapshot>, context: functions.EventContext) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Prevent infinite loops by checking if only `updatedAt` changed
    if (change.after.isEqual(change.before)) return null;

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
export const notifyOnCommunityAlert = functions.firestore
  .document('community_posts/{postId}')
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
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
      } catch (error) {
        console.error("Error sending alert notification:", error);
      }
    }
  });

// 5. Smart IoT Telemetry Monitor
// Sends a push notification if an IoT device reports dangerously low soil moisture
export const monitorIotTelemetry = functions.firestore
  .document('iot_telemetry/{readingId}')
  .onCreate(async (snapshot: functions.firestore.QueryDocumentSnapshot, context: functions.EventContext) => {
    const data = snapshot.data();
    
    if (data.sensorType === 'soil_moisture' && data.value < 15.0) {
      // Find the user who owns this sensor
      const sensorDoc = await db.collection('iot_devices').doc(data.deviceId).get();
      if (!sensorDoc.exists) return;
      
      const userId = sensorDoc.data()?.ownerId;
      if (!userId) return;

      const userDoc = await db.collection('user_profiles').doc(userId).get();
      const fcmToken = userDoc.data()?.fcmToken;

      if (fcmToken) {
        await admin.messaging().send({
          token: fcmToken,
          notification: {
            title: '💧 Irrigation Warning!',
            body: `Moisture levels for ${sensorDoc.data()?.name || 'your field'} dropped below critical threshold.`,
          }
        });
      }
    }
  });
