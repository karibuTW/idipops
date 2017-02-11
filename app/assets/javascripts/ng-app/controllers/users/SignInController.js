angular
  .module('uneo.controllers')
  .controller('SignInController',[
    '$scope', '$rootScope', '$stateParams', '$uibModal', 'Alerts', SignInController
    ]  
  )
  .controller('RequestPasswordModalController',['$scope','$uibModalInstance','Alerts','User', RequestPasswordModalController]);

function SignInController($scope, $rootScope, $stateParams, $uibModal, Alerts) {
  $scope.user = { email: "", password: "", password_confirmation: "" }
  $scope.regType = "sign_in";
  var token = $stateParams.token;
  if (token) {
    $scope.regType = "sign_up";
  } else {
    $scope.regType = "sign_in";
  }

  $scope.switchToSignIn = function() {
    $scope.regType = 'sign_in';
  }

  $scope.switchToSignUp = function() {
    $scope.regType = 'sign_up';
  }

  $scope.submit = function() {
    if ($scope.regType == 'sign_in') {
      $rootScope.signIn($scope.user.email, $scope.user.password);
    } else {
      if ($scope.user.password == $scope.user.password_confirmation) {
        $rootScope.signUp($scope.user.email, $scope.user.password, $scope.user.password_confirmation, token);
      } else {
        Alerts.add('danger', I18n.t("user.signin.passwords_no_match"));
      }
    }
  }

  $scope.sendPassword = function() {
    var modalInstance = $uibModal.open({
      templateUrl: 'modals/request-password-modal.html',
      controller: 'RequestPasswordModalController'
    });
  }
}

function RequestPasswordModalController ($scope, $uibModalInstance, Alerts, User){
    $scope.isUpdating = false;

    $scope.confirm = function () {
      if ($scope.email != '') {
        $scope.isUpdating = true;
        User.requestPassword($scope.email)
          .then(function() {
            Alerts.add('success', I18n.t("user.signin.password_sent"));
            $uibModalInstance.close();
          }, function(message) {
            Alerts.add('danger', message);
            $scope.isUpdating = false;
          });
        }
    };

    $scope.cancel = function () {
      $uibModalInstance.dismiss('cancel');
    };
  };