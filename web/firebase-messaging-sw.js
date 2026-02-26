importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyCwyG5_yH1rKd-CBQGwQylw2n8jrPbn17o",
    authDomain: "zyiarah-app.firebaseapp.com",
    projectId: "zyiarah-app",
    storageBucket: "zyiarah-app.firebasestorage.app",
    messagingSenderId: "275681992607",
    appId: "1:275681992607:web:6dc4a0042fab5b69b127aa",
    measurementId: "G-K82D1GDJNF"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
    console.log('Received background message ', payload);
    const notificationTitle = payload.notification.title;
    const notificationOptions = {
        body: payload.notification.body,
        icon: '/favicon.png'
    };

    return self.registration.showNotification(notificationTitle, notificationOptions);
});
