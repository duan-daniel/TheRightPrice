// Initialize Firebase
var config = {
  apiKey: "AIzaSyAykb9UKgwpTEKXcQR0X4Dc9C3a6f8c8wg",
  authDomain: "loquela-34ea1.firebaseapp.com",
  databaseURL: "https://loquela-34ea1.firebaseio.com",
  projectId: "loquela-34ea1",
  storageBucket: "loquela-34ea1.appspot.com",
  messagingSenderId: "10511979287"
};

firebase.initializeApp(config);

const auth = firebase.auth();
const db = firebase.firestore();

var email = '';

// authentication

function createAccount() {
    window.location.href = "../createAccount/register.html";
}

function login() {
  const txtEmail = document.getElementById('txtEmail');
  const txtPassword = document.getElementById('txtPassword');

  const email = txtEmail.value;
  const pass = txtPassword.value;

  const promise = auth.signInWithEmailAndPassword(email, pass);

  promise.catch(e => console.log(e.message));

  firebase.auth().onAuthStateChanged(firebaseUser => {
	if(firebaseUser) {
	  console.log(firebaseUser);
	  window.location.href = "../home/home.html";
	}
  });
}

function register() {
  const txtEmail = document.getElementById('txtEmail');
  const txtPassword = document.getElementById('txtPassword');
  const txtConfirmPassword = document.getElementById('txtConfirmPassword');

  const email = txtEmail.value;
  const pass = txtPassword.value;
  const confirmPass = txtConfirmPassword.value;

  if(pass.localeCompare(confirmPass) == 0) {
    const promise = auth.createUserWithEmailAndPassword(email, pass);

    var data = {
      email: email
    };

    // Add a new document in collection "cities" with ID 'LA'
    var setDoc = db.collection('users').doc(email).set(data);

    promise.catch(e => console.log(e.message));
  }
} 

firebase.auth().onAuthStateChanged(firebaseUser => {
	if(firebaseUser) {
	  console.log(firebaseUser);
	  window.location.href = "../home/home.html";
	}
});
