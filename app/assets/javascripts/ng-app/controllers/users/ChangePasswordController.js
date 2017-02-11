angular
  .module('uneo.controllers')
  .controller('ChangePasswordController',[
    '$scope', '$rootScope', '$state', 'User', 'Alerts', ChangePasswordController
    ]  
  );

function ChangePasswordController($scope, $rootScope, $state, User, Alerts) {
  $scope.user = { old_password: "", password: "", password_confirmation: "" }
  $scope.isUpdatingPassword = false;

  $scope.submit = function() {
    $scope.isUpdatingPassword = true;
    User.changePassword($scope.user)
      .then(function() {
        Alerts.add('success', I18n.t("user.edit.change_password.password_changed"));
        $scope.isUpdatingPassword = false;
        $state.go('home.users-edit');
      }, function(messages) {
        for (var i=0; i<messages.length; i++) {
          Alerts.add('danger', messages[i]);
        }
        $scope.isUpdatingPassword = false;
      });
  }
};