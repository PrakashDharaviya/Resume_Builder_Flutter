const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

/**
 * HTTP Callable function to broadcast a push notification to all users 
 * who have opted in (notificationsEnabled: true).
 */
exports.sendBroadcastNotification = functions.https.onCall(async (data, context) => {
  // 1. Verify Authentication (Uncomment in production if needed)
  // if (!context.auth) {
  //   throw new functions.https.HttpsError(
  //     "unauthenticated",
  //     "Only authenticated users can send broadcasts."
  //   );
  // }
  
  const title = data.title;
  const body = data.body;

  if (!title || !body) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "The functions requires 'title' and 'body' in the payload."
    );
  }

  try {
    // 2. Fetch all users who have opted-in AND have an FCM token
    const usersSnapshot = await admin.firestore()
      .collection("users")
      .where("notificationsEnabled", "==", true)
      .get();

    if (usersSnapshot.empty) {
      console.log("No users opted in for notifications.");
      return { success: true, count: 0, message: "No users found" };
    }

    const tokens = [];
    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length === 0) {
      console.log("Users opted in, but no FCM tokens found.");
      return { success: true, count: 0, message: "No tokens found" };
    }

    // 3. Create the messaging payload
    const message = {
      notification: {
        title: title,
        body: body,
      },
      tokens: tokens,
    };

    // 4. Send the multicast message
    const response = await admin.messaging().sendEachForMulticast(message);
    
    console.log(`Successfully sent message. Success: ${response.successCount}, Failures: ${response.failureCount}`);
    
    // Optional: Clean up invalid tokens based on responses
    if (response.failureCount > 0) {
      const failedTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          failedTokens.push(tokens[idx]);
          console.error(`Failure error for token ${tokens[idx]}: ${resp.error.message}`);
        }
      });
      // Here you could remove the failed tokens from Firestore if desired
    }

    return { 
      success: true, 
      count: response.successCount 
    };

  } catch (error) {
    console.error("Error broadcasting notification:", error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred while broadcasting the notification."
    );
  }
});
