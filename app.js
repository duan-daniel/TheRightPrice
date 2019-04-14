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

function login() {
  const txtEmail = document.getElementById('txtEmail');
  const txtPassword = document.getElementById('txtPassword');

  const email = txtEmail.value;
  const pass = txtPassword.value;

  const promise = auth.signInWithEmailAndPassword(email, pass);
  promise.catch(e => console.log(e.message));
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

function logout() {
  firebase.auth().signOut();
}

var app = angular.module('myApp', ['ngRoute']);

app.config(function($routeProvider) {
  $routeProvider

  .when('/', {
    templateUrl : 'pages/register/register.html',
    controller  : 'RegisterController'
  })

  .when('/create', {
    templateUrl : 'pages/register/create.html',
    controller  : 'RegisterController'
  })

  .when('/home', {
    templateUrl : 'pages/home/home.html',
    controller  : 'HomeController'
  })

  .otherwise({redirectTo: '/'});
});

app.controller('RegisterController', function($scope) {
  firebase.auth().onAuthStateChanged(firebaseUser => {
    if(firebaseUser) {
      console.log(firebaseUser);

      $scope.email = firebaseUser.email;
      $scope.$apply();
    }
  });
});

app.controller('HomeController', function($scope) {
  firebase.auth().onAuthStateChanged(firebaseUser => {
    if(firebaseUser) {
      console.log(firebaseUser);

      email = firebaseUser.email;
      $scope.email = firebaseUser.email;
      $scope.$apply();

      db.collection("users").doc(email).collection('words').onSnapshot(function(querySnapshot) {
        $(".wordCard").remove();    // clear all existing cards before re-populating


        querySnapshot.forEach(function(doc) {
            var stringVal = '<div class="wordCard flip-container" ontouchstart="this.classList.toggle(\'hover\');">'+
            '                  <div class="flippable appcon blueCard">'+
            '                    <div class="front">'+
            '                      <span>'+doc.data().word+'</span>'+
            '                      <img class="wordPic" width="75%" height="auto" src="'+doc.data().url+'"></img>'+
            // '                      <span>'+doc.data().language+'</span>'+
            '                    </div>'+
            '                    <div class="back">'+
            '                      ' + doc.data().term +
            '                    </div>'+
            '                  </div>'+
            '              </div>';


            $( ".words" ).append(stringVal);
          });
      });
    }
  });
});