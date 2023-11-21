/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//  logger.info("Hello logs!", {structuredData: true});
//  response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const sgMail = require('@sendgrid/mail');
const admin = require('firebase-admin');

admin.initializeApp();
sgMail.setApiKey(functions.config().sendgrid.key);


exports.notifyOnReport = functions.firestore
  .document('reports/{reportId}')
  .onCreate((snap, context) => {
    const reportData = snap.data();

    let reportTypeDetails = '';

    if (reportData.reportType === 'user') {
      reportTypeDetails = `
      Reported User ID: ${reportData.targetId}
      Reported User Name: ${reportData.targetName}`;
    } else if (reportData.reportType === 'event') {
      reportTypeDetails = `
      Reported Event ID: ${reportData.targetId}
      Reported Event Name: ${reportData.targetName}`;
    } else if (reportData.reportType === 'club') {
      reportTypeDetails = `
      Reported Club ID: ${reportData.targetId}
      Reported Club Name: ${reportData.targetName}`;
    }

    const msg = {
      to: 'communifyy@gmail.com', // Your email
      from: 'communifyy@gmail.com', // Your sender address
      subject: 'New Report in Communify',
      text: `Report Details:\n
             Report ID: ${context.params.reportId}\n
             User: ${reportData.userId}\n
             SentAt: ${reportData.sentAt}\n
             Status: ${reportData.status}\n
      ReportType: ${reportTypeDetails}\n`
    };
    return sgMail.send(msg);
  });





exports.sendFriendRequestNotification = functions.firestore
    .document('users/{userId}/Friend Requests/{requestId}')
    .onCreate(async (snapshot, context) => {
      // Retrieve the current friend request data
      const friendRequestData = snapshot.data();

      // Retrieve the IDs from the document path
      const recipientUserId = context.params.userId;
      const senderUserId = friendRequestData['SenderUserId'];

      if (!senderUserId) {
        return;
      }

      try {
        // Fetch the token of the user to receive the notification (you may need to adjust this based on your data structure)
        const userDoc = await admin.firestore().doc(`users/${recipientUserId}`).get();
        const token = userDoc.get('token');

        // Fetch the sender's name for a more personalized message
        const senderDoc = await admin.firestore().doc(`users/${senderUserId}`).get();
        const senderName = senderDoc.get('first_name') + ' ' + senderDoc.get('last_name');

        // Define the message for the notification
        const message = {
          notification: {
            title: 'New Friend Request',
            body: `You received a new friend request from ${senderName}!`,
          },
          token: token,
          data: {
              route: 'FRIEND_REQUEST_SCREEN'
            },
            apns: {
              payload: {
                aps: {
                  contentAvailable: true,
                },
              },
              headers: {
                'apns-priority': '5',
              },
            },
          };

        // Send the notification
        await admin.messaging().send(message);
      } catch (error) {
        functions.logger.log('Error sending message:', error);
      }
    });
