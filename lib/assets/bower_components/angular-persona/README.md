Angular-Persona
===============

angular-persona is a collection of services and directives to make easy the
integration with [Mozilla Persona](https://developer.mozilla.org/en/Persona).

Install
-------

To use angular-persona you have to:

1. include in your index.html the Persona javascript library

    ```<script src="https://login.persona.org/include.js"></script>```

2. install angular-persona with bower:

    ```bower install angular-persona```

3. In your ```index.html```, after the persona library, include the
angular-persona file

    <script src="bower_components/angular-persona/angular-persona.min.js"></script>

In your module declaration you have to include the persona module

    var module = angular.module('yourModule', [
        ...
        'persona',
    ]);

Configuration
-------------

The configuration is very similar to Vanilla Persona: https://developer.mozilla.org/en-US/Persona/Quick_setup

You have to setup a login handler and a logout handler. You should do it in the
run phase, in order to be able to use $http, if necessary.

In this example we suppose you store your user in a user service (it's the sensible thing to do).
Remember, if the user is logged out, user.email should be null.

    app.run(function ($http, Persona, user) {
      Persona.watch({
        loggedInUser: user.email
        onlogin: function(assertion) {
          $http.post(
            '/auth/login', // This is a URL on your website.
            {assertion: assertion}
          ).then(function () {
            // Stuff
            })
        },
        onlogout: function() {
            // Stuff
        })
      });
    });

USAGE
-----

To allow the user to login you should create a login button, and call Persona.request
when it's clicked:

    var controller = function ($scope, Persona) {
        $scope.login = function () {
            Persona.request();
        }
    }

    <a ng-click="login()">Login with Persona</a>


DEVELOPMENT
-----------

Remember to install all dependencies:

    $ npm install -g gulp  // It's like grunt but cooler
    $ npm install -d
    $ bower install

To launch tests simply run

    gulp karma
