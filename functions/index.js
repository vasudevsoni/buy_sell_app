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

const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data , context) => {
    console.log("Token" + data.token) 

    const payload = {
        notification:{
            "title":"BechDe",
            "body":"You have a new chat message",
            "sound":"default"
        }
    }
    
    await admin.messaging().sendToDevice(
        data.token,payload
    ).then(response => {
        console.log("Success" + response) 
    })
        .catch(error => {
        console.log("Error "+error
        )
    })
    // .sendMulticast({
    //     tokens:data.tokens,
    //     notification:{
    //         title : data.title,
    //         body : data.body,
    //     },
    // });
});

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
