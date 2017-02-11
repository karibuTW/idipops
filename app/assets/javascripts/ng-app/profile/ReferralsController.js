angular
  .module('uneo.controllers')
  .controller(
    'ReferralsController',
    ['$rootScope', '$scope', '$state', '$timeout', '$uibModal', 'User', 'Alerts','Referral',
    'Profession', 'Place', 'GoogleServices', 'Tags', ReferralsController]
  )
  .controller('ModalInstanceController',['$scope','$rootScope','$modalInstance','Alerts','Referral','Authentication','referrals','message','subject','reward', 'intro', ModalInstanceController]);
  function ReferralsController($rootScope, $scope, $state, $timeout, $uibModal, User, Alerts, Referral, Profession, Place, GoogleServices, Tags) {
    $rootScope.setTitle(I18n.t("referrals.title"));
	  $scope.isSaving = false;
	  $scope.isLoadingReferrals	= true;
	  $scope.referrals = [];
	  $scope.reward = '0';
    $scope.totalReferralRewards = 0;
    
	  $scope.$on('referralsChange', function(event, data) {
	    $scope.referrals = data;
	  });

    var initAll = function() {
      $scope.invitationLink = $rootScope.rootURL + $state.href("referral-accept") + $scope.session.user.token;
      $scope.subject = I18n.t("referrals.email_subject", {pro_name: $scope.session.user.display_name});
      Referral.getData()
        .then(function(data){
          $scope.isLoadingReferrals = false;
          $scope.referrals = data.referrals;
          $scope.reward = data.reward;
          $scope.message = I18n.t("referrals.email_message", {reward: $scope.reward, name: $scope.session.user.display_name});
          $scope.totalReferralRewards = data.total_referral_rewards;
        }, function(message) {
          $scope.isLoadingReferrals = false;
          Alerts.add('danger', message);
      });
    };
    if ($scope.session.connected) {
      initAll();
    }
    $rootScope.$on('user-loaded', function(event, args) {
      initAll();
    });

    

	  $scope.openReferralModal = function(index){
	    var modalInstance = $uibModal.open({
	      animation: true,
        size: 'lg',
	      templateUrl: 'modals/referral-user-modal.html',
	      controller: 'ModalInstanceController',
	      resolve: {
	        referrals: function () {
	          return $scope.referrals;
	        },
          message: function(){
            return $scope.message;
          },
          subject: function(){
            return $scope.subject;
          },
          reward: function(){
            return $scope.reward;
          },
          intro: function(){
            return ($scope.session.user.user_type == 'pro' ? I18n.t('referrals.content_pro', { reward: $scope.reward }) : I18n.t('referrals.content_user') );
          }
	      }
	    });
	  };
	}

function ModalInstanceController($scope,$rootScope,$modalInstance,Alerts,Referral,Authentication,referrals,message,subject,reward, intro){
  $scope.referrals = referrals;
  $scope.message = message;
  $scope.subject = subject;
  $scope.reward = reward;
  $scope.emails = [];
  $scope.isUpdating = false;
  $scope.intro = intro;
  var authService = Authentication;
  $scope.cancel = function () {
    $modalInstance.dismiss('cancel');
  };
  $scope.confirm = function(){
  	$scope.isUpdating = true;
  	var emails = transformTagsIntoArray($scope.emails);
  	Referral.saveData(emails,$scope.subject,$scope.message)
  	  .then(function(data){
  	  	$scope.isUpdating = false;
  	  	$rootScope.$broadcast('referralsChange', data.referrals);
  	  	$modalInstance.dismiss('cancel');
  	  	Alerts.add('success', I18n.t("referrals.referral_email_sent"));
  	  },function(message){
  	  	$scope.isUpdating = false;
  	  	Alerts.add('danger', message);
  	  })
  }; 
  $scope.checkExitReferral = function(tag){
    $scope.isUpdating = true;
    var email = tag.text;
    var emailIsFree = true;
    authService.checkEmailIsFree(email)
      .then(function(isFree) {
        $scope.isUpdating = false;
        emailIsFree = isFree;
        if (!emailIsFree) {
          $scope.emails.pop();
          Alerts.add('danger', I18n.t("referrals.referral_email_exists"));
        }
      }, function(message) {
        $scope.isUpdating = false;
      })
  return emailIsFree;
  };
}