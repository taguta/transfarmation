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
