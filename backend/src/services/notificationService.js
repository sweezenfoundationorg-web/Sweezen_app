const admin = require('firebase-admin');
require('dotenv').config();

let isFirebaseInitialized = false;

// Initialize Firebase Admin SDK
try {
  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  let privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (privateKey) {
    privateKey = privateKey.replace(/\\n/g, '\n');
  }

  if (projectId && clientEmail && privateKey) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: projectId,
        clientEmail: clientEmail,
        privateKey: privateKey,
      }),
    });
    isFirebaseInitialized = true;
    console.log('[FCM PUSH] Firebase Admin SDK initialized successfully.');
  } else {
    console.log('[FCM PUSH DEV MODE] Firebase credentials not fully provided in .env. Operating in Push Notification Simulation Mode.');
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
      const response = await admin.messaging().send(message);
      console.log(`[FCM PUSH] Notification sent to device ${deviceToken}. Message ID: ${response}`);
      return { success: true, messageId: response };
    } catch (err) {
      console.error('[FCM PUSH ERROR] Failed to send push notification:', err.message);
    }
  }

  // Simulation mode output
  console.log(`=======================================================`);
  console.log(`[FCM PUSH NOTIFICATION SIMULATED]`);
  console.log(`To Device Token : ${deviceToken || 'ALL_REGISTERED_DEVICES'}`);
  console.log(`Title           : ${title}`);
  console.log(`Body            : ${body}`);
  console.log(`Data Payload    : ${JSON.stringify(data || {})}`);
  console.log(`=======================================================`);
  return { success: true, simulated: true };
};

/**
 * Broadcast Push Notification to a FCM Topic (e.g. 'all_volunteers', 'all_donors')
 */
const sendPushToTopic = async (topic, payload) => {
  const { title, body, data } = payload;
  const targetTopic = topic || 'all_volunteers';

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
      const response = await admin.messaging().send(message);
      console.log(`[FCM PUSH TOPIC] Broadcast sent to topic '${targetTopic}'. Response ID: ${response}`);
      return { success: true, messageId: response };
    } catch (err) {
      console.error('[FCM PUSH TOPIC ERROR]', err.message);
    }
  }

  console.log(`=======================================================`);
  console.log(`[FCM PUSH TOPIC BROADCAST SIMULATED]`);
  console.log(`Target Topic : ${targetTopic}`);
  console.log(`Title        : ${title}`);
  console.log(`Body         : ${body}`);
  console.log(`Data Payload : ${JSON.stringify(data || {})}`);
  console.log(`=======================================================`);
  return { success: true, simulated: true };
};

module.exports = {
  sendPushToDevice,
  sendPushToTopic,
};
