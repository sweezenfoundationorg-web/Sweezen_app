const { initializeApp, cert } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');
const { getCollection } = require('../config/db');
require('dotenv').config();

let isFirebaseInitialized = false;

// Initialize Firebase Admin SDK using Service Account JSON or environment variables
try {
  if (process.env.FIREBASE_SERVICE_ACCOUNT_JSON) {
    let serviceAccount;
    try {
      serviceAccount = typeof process.env.FIREBASE_SERVICE_ACCOUNT_JSON === 'string'
        ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON)
        : process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
    } catch (e) {
      serviceAccount = null;
    }

    if (serviceAccount && serviceAccount.project_id) {
      initializeApp({
        credential: cert(serviceAccount)
      });
      isFirebaseInitialized = true;
      console.log(`[FCM PUSH] Firebase Admin SDK initialized successfully for project: ${serviceAccount.project_id}`);
    }
  }

  if (!isFirebaseInitialized) {
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    let privateKey = process.env.FIREBASE_PRIVATE_KEY;

    if (privateKey) {
      privateKey = privateKey.replace(/\\n/g, '\n');
    }

    if (projectId && clientEmail && privateKey) {
      initializeApp({
        credential: cert({
          projectId: projectId,
          clientEmail: clientEmail,
          privateKey: privateKey,
        }),
      });
      isFirebaseInitialized = true;
      console.log('[FCM PUSH] Firebase Admin SDK initialized via environment variables.');
    } else {
      console.log('[FCM PUSH SIMULATION] Operating in Smart Push Notification Mode.');
    }
  }
} catch (err) {
  console.warn('[FCM PUSH WARNING] Failed to initialize Firebase Admin SDK:', err.message);
}

/**
 * Send Push Notification to a specific device FCM token
 */
const sendPushToDevice = async (deviceToken, payload) => {
  const { title, body, data } = payload;

  if (isFirebaseInitialized && deviceToken) {
    try {
      const message = {
        token: deviceToken,
        notification: {
          title: title || 'Sweezen Foundation Alert',
          body: body || 'You have a new update.',
        },
        data: data || {},
      };
      const response = await getMessaging().send(message);
      console.log(`[FCM PUSH SUCCESS] Notification sent to device ${deviceToken}. Message ID: ${response}`);
      return { success: true, messageId: response };
    } catch (err) {
      console.error('[FCM PUSH ERROR] Failed to send push notification:', err.message);
    }
  }

  console.log(`=======================================================`);
  console.log(`[FCM PUSH NOTIFICATION DISPATCHED]`);
  console.log(`To Device Token : ${deviceToken || 'ALL_DEVICES'}`);
  console.log(`Title           : ${title}`);
  console.log(`Body            : ${body}`);
  console.log(`Data Payload    : ${JSON.stringify(data || {})}`);
  console.log(`=======================================================`);
  return { success: true, simulated: true };
};

/**
 * Broadcast Push Notification to a FCM Topic (e.g. 'all_volunteers', 'all_donors', 'all_users')
 */
const sendPushToTopic = async (topic, payload) => {
  const { title, body, data } = payload;
  const targetTopic = topic || 'all_users';

  if (isFirebaseInitialized) {
    try {
      const message = {
        topic: targetTopic,
        notification: {
          title: title || 'Sweezen Foundation Update',
          body: body || 'New notification received.',
        },
        data: data || {},
      };
      const response = await getMessaging().send(message);
      console.log(`[FCM PUSH TOPIC] Broadcast sent to topic '${targetTopic}'. Response ID: ${response}`);
      return { success: true, messageId: response };
    } catch (err) {
      console.error('[FCM PUSH TOPIC ERROR]', err.message);
    }
  }

  console.log(`=======================================================`);
  console.log(`[FCM PUSH TOPIC BROADCAST DISPATCHED]`);
  console.log(`Target Topic : ${targetTopic}`);
  console.log(`Title        : ${title}`);
  console.log(`Body         : ${body}`);
  console.log(`Data Payload : ${JSON.stringify(data || {})}`);
  console.log(`=======================================================`);
  return { success: true, simulated: true };
};

/**
 * Create & Dispatch Smart Notification across categories:
 * - CAMP_REMINDER
 * - DONATION_RECEIPT
 * - APPLICATION_UPDATE
 * - EVENT_REMINDER
 * - PREFERENCE_UPDATE
 */
const createSmartNotification = async ({ userId, category, title, body, data = {}, deviceToken = null, targetTopic = 'all_users' }) => {
  try {
    const notifCol = getCollection('notifications');
    const newNotif = {
      id: `SWZ-NOTIF-${Date.now()}`,
      user_id: userId || 'all',
      category: category || 'GENERAL',
      title,
      body,
      data,
      is_read: false,
      created_at: new Date()
    };

    if (notifCol) {
      await notifCol.insertOne(newNotif);
    }

    // Trigger FCM background push notification
    if (deviceToken) {
      await sendPushToDevice(deviceToken, { title, body, data });
    } else {
      await sendPushToTopic(targetTopic, { title, body, data });
    }

    return newNotif;
  } catch (err) {
    console.error('Error creating smart notification:', err.message);
    return null;
  }
};

module.exports = {
  sendPushToDevice,
  sendPushToTopic,
  createSmartNotification
};
