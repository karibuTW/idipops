'use strict';

var getDisplayName = function(userType, companyName, firstName, lastName) {
  return (userType == 'pro' ? companyName : firstName + " " + lastName);
}

var getRawTime = function(hour, minute) {
  var rawTime =  '';
  if(hour < 10) {
    rawTime += '0' + hour;
  } else {
    rawTime += hour;
  }
  rawTime += 'h';
  if(minute < 10) {
    rawTime += '0' + minute;
  } else {
    rawTime += minute;
  }
  return rawTime;
}

var transformTagsIntoArray = function(inputTags) {
  var tags = [];
  for (var i=0; i<inputTags.length; i++) {
    tags.push(inputTags[i].text);
  }
  return tags;
};

var transformTagsIntoString = function(inputTags) {
  return transformTagsIntoArray(inputTags).join();
};

var getActivity = function(activityId, professions, filter) {
  var activities;
  activities = filter('filter')(professions, {id: activityId}, true);
  if (activities.length > 0) {
    return activities[0].name;
  } else {
    return null;
  }
};

var getActivitiesForPro = function(user, professions, filter) {
  var activities = { primaryActivity: null, secondaryActivity: null, tertiaryActivity: null, quaternaryActivity: null };
  
  for (var i=0; i<professions.length; i++) {
    if (activities.primaryActivity == null) {
      activities.primaryActivity = getActivity(user.primary_activity_id, professions[i].children, filter);
    }
    if (activities.secondaryActivity == null) {
      activities.secondaryActivity = getActivity(user.secondary_activity_id, professions[i].children, filter);
    }
    if (activities.tertiaryActivity == null) {
      activities.tertiaryActivity = getActivity(user.tertiary_activity_id, professions[i].children, filter);
    }
    if (activities.quaternaryActivity == null) {
      activities.quaternaryActivity = getActivity(user.quaternary_activity_id, professions[i].children, filter);
    }
  }

  return activities;
  
};

var buyAuthorization = function(authorizationType, classifiedAdId, title, returnId, scope, modal, state, authorizations, alerts, rootScope, quotationRequests) {
  scope.isPayingCredits = false;
  var modalInstance;
  modalInstance = modal.open({
    templateUrl: 'modals/unlock-classified-ad-modal.html',
    controller: 'UnlockClassifiedAdModalController',
    resolve: {
      authorizationType: function () {
        return authorizationType;
      },
      title: function () {
        return title;
      },
      userBalance: function() {
        return scope.session.user.balance;
      }
    }
  });
  modalInstance.result.then(function (userIsPaying) {
    if (userIsPaying) {
      scope.isPayingCredits = true;
      authorizations.payForUnlockingClassified(classifiedAdId)
        .then(function(authorization) {
          scope.session.user.balance = authorization.balance;
          scope.isPayingCredits = false;
          if (authorizationType == 'classifiedAd') {
            state.go('ad-details', {adid: returnId});
          } else {
            state.go('qr-details', {qrid: returnId});
          }
        }, function(message) {
          scope.isPayingCredits = false;
          alerts.add('danger', message);
        });
    } else {
      state.go("home.pro-credits");
    }
  }, function () {
    if (authorizationType == 'quotationRequest') {
      quotationRequests.markRead(returnId)
        .then(function() {
          rootScope.$broadcast('notificationsCountUpdated');
        }, function(message) {
          
        });
    }
  });
};

var buyQuotationRequest = function(quotationRequest, scope, modal, state, authorizations, alerts, rootScope, quotationRequests) {
  buyAuthorization('quotationRequest', quotationRequest.classified_ad_id, quotationRequest.title, quotationRequest.id, scope, modal, state, authorizations, alerts, rootScope, quotationRequests);
};

var buyClassifiedAd = function(classifiedAd, scope, modal, state, authorizations, alerts) {
  buyAuthorization('classifiedAd', classifiedAd.id, classifiedAd.title, classifiedAd.id, scope, modal, state, authorizations, alerts);
};

var showProfessionSelectModal = function(profession, professions, modal, state) {
  var modalInstance;
  modalInstance = modal.open({
    templateUrl: 'modals/sub-profession-modal.html',
    controller: 'SubItemModalController',
    size: 'lg',
    resolve: {
      items: function () {
        return professions;
      },
      selectedItem: function () {
        return profession;
      }
    }
  });
  modalInstance.result.then(function (pid) {
    state.go('pros-list', {pids: pid});
  }, function () {
    
  });
};

var askToSignin = function(uibModal, rootScope) {
  var modalInstance = uibModal.open({
    templateUrl: 'modals/confirm-modal.html',
    controller: 'ConfirmModalController',
    resolve: {
      confirmTitle: function () {
        return I18n.t("general.signup_modal.title");
      },
      confirmText: function () {
        return I18n.t("general.signup_modal.message");
      },
      confirmLabel: function () {
        return I18n.t("general.signup_modal.confirm_label");
      },
      cancelLabel: function () {
        return I18n.t("general.signup_modal.cancel_label");
      }
    }
  });
  modalInstance.result.then(function () {
    rootScope.signIn();
  }, function () {
    // Cancelled
  });
};

/* Controllers */

angular.module('uneo.controllers', [])
  .controller('AlertsController', ['$scope', '$rootScope', '$sce', 'toastr', 'Alerts', function( $scope, $rootScope, $sce, toastr, Alerts ){
    // var messageTemplate = '<div><span>{{message}}</span></div>';
    
    $rootScope.$on('new-alert', function(event, args) {
      switch(args.type) {
        case 'success':
          toastr.success(args.msg);
          break;
        case 'info':
          toastr.info(args.msg);
          break;
        case 'danger':
          // toastr.error($sce.trustAsHtml(args.msg));
          toastr.error(args.msg);
          break;
      }
    });
  }])

  .controller('LightboxController', ['$scope', '$window', '$mdDialog', 'index', 'images', function($scope, $window, $mdDialog, index, images) {
    var maxWidth = $window.innerWidth;
    var maxHeight = $window.innerHeight;
    var PADDING = 24;
    $scope.containerStyle = { 'max-width': (maxWidth-PADDING*2) + 'px', 'max-height': (maxHeight-PADDING*2) + 'px' };
    $scope.imageStyle = { 'max-width': (maxWidth-PADDING*4) + 'px', 'max-height': (maxHeight-PADDING*4) + 'px' };
    $scope.images = images;
    $scope.currentIndex = index; // Initially the index is at the first image
 
    $scope.next = function() {
      $scope.currentIndex < $scope.images.length - 1 ? $scope.currentIndex++ : $scope.currentIndex = 0;
    };
     
    $scope.prev = function() {
      $scope.currentIndex > 0 ? $scope.currentIndex-- : $scope.currentIndex = $scope.images.length - 1;
    };

    $scope.$watch('currentIndex', function() {
      $scope.images.forEach(function(image) {
        image.visible = false; // make every image invisible
      });
     
      $scope.images[$scope.currentIndex].visible = true; // make the current image visible
    });
  }])

  .controller('SessionController', ['$rootScope', '$scope', '$document', '$state', '$stateParams', '$interval', '$timeout', '$filter', '$location', '$uibModal', '$mdSidenav', '$mdDialog', '$mdMedia', '$window', 'toastr', 'Authentication', 'User', 'Alerts', 'GeoLocation', 'SocketMessages', 'Conversations', 'Profession', 'Analytics', function($rootScope, $scope, $document, $state, $stateParams, $interval, $timeout, $filter, $location, $uibModal, $mdSidenav, $mdDialog, $mdMedia, $window, toastr, Authentication, User, Alerts, GeoLocation, SocketMessages, Conversations, Profession, Analytics) {
    var alertsService = Alerts;
    var authService = Authentication;
    var hasToGetUserData = false;
    var wsReconnectPromise;
    var wsInitialTimeout = 5000;
    var wsCurrentTimeout = wsInitialTimeout;
    var theController = this;
    $scope.session = $rootScope.session = { connected : authService.state.signedIn, user: {} };
    $scope.isRetrievingProfile = true;
    $scope.discoverCollapsed = true;

    $rootScope.setTitle = function(title) {
      var prefix = ($rootScope.session.user.unread_conversations_count > 0 ? '(' + $rootScope.session.user.unread_conversations_count + ') ' : '');

      $rootScope.title = prefix + title;

      setTimeout(function(){Analytics.trackPage();},0);
    }

    Profession.getData()
      .then(function(professions) {
        $scope.professions = professions;
      }, function(message) {
        Alerts.add('danger', message);
      });

    $scope.$back = function() { 
      $window.history.back();
    };

    $scope.closeMenu = function() {
      if ($mdMedia('xs')) {
        $rootScope.menuClass = '';
      } else if ($state.current.name == 'pros-list') {
        $rootScope.menuClass = 'menu-for-map';
      }
    };

    $scope.toggleMobileMenu = function() {
      $rootScope.menuClass = 'opened';
    };

    $scope.gotoHowItWorks = function() {
      $state.go($scope.session.user.user_type == 'pro' ? 'how-it-works-pros.profile' : 'how-it-works-users.search');
    };

    $scope.allProfessionSelectHandler = function() {
      if ($state.current.name != 'pros-list') {
        showProfessionSelectModal(null, $scope.professions, $uibModal, $state);
      }
      // $mdSidenav('professionSidenav').toggle();
      // $rootScope.selectedProfession = null;
    };

    $scope.toggleMenuSidenav = function() {
      $mdSidenav('menuSidenav').toggle();
    };
    // authService.watchWith(undefined);
    var handleUsersOnlineStatus = function(onlineUsers) {
      for (var i=0; i<Conversations.data.conversations.length; i++) {
        var index = onlineUsers.users_id.indexOf(Conversations.data.conversations[i].user.id);
        Conversations.data.conversations[i].user.online = (index != -1);
      }
      if (Conversations.data.selectedConversation) {
        Conversations.data.selectedConversation.user.online = (onlineUsers.users_id.indexOf(Conversations.data.selectedConversation.user.id) != -1);
      }
      $scope.$apply();
    };
    var connectedUserHandler = function(onlineUser) {
      setOnlineStatusForUser(onlineUser.user_id, true);
    };
    var disconnectedUserHandler = function(onlineUser) {
      setOnlineStatusForUser(onlineUser.user_id, false);
      if (Conversations.data.selectedConversation.user.id == onlineUser.user_id) {
        Conversations.data.selectedConversation.isTyping = false;
      }
      for (var i=0; i<Conversations.data.conversations.length; i++) {
        if (Conversations.data.conversations[i].user.id == onlineUser.user_id) {
          Conversations.data.conversations[i].isTyping = false;
          break;
        }
      }
      $scope.$apply();
    };
    var setOnlineStatusForUser = function(userId, online) {
      if (Conversations.data.selectedConversation && Conversations.data.selectedConversation.user.id == userId) {
        Conversations.data.selectedConversation.user.online = online;
      }
      for (var i=0; i<Conversations.data.conversations.length; i++) {
        if (Conversations.data.conversations[i].user.id == userId) {
          Conversations.data.conversations[i].user.online = online;
          break;
        }
      }
      $scope.$apply();
    };
    var userTypingHandler = function(data) {
      var conversationToUpdate = $filter('filter')(Conversations.data.conversations, { id: parseInt(data.conversation_id) }, true)[0];
      if (conversationToUpdate) {
        conversationToUpdate.isTyping = data.is_typing;
      }
      if (Conversations.data.selectedConversation && Conversations.data.selectedConversation.id == data.conversation_id) {
        Conversations.data.selectedConversation.isTyping = data.is_typing;
      }
      $scope.$apply();
    };
    var isWatchingConversation = function(conversationId, refIds) {
      return ((($state.current.name == 'ad-details' && refIds.clad_id && refIds.clad_id == $stateParams.adid) || ($state.current.name == 'qr-details' && refIds.qr_id && refIds.qr_id == $stateParams.qrid) || (($state.current.name == 'home.pros-dashboard' || $state.current.name == 'home.users-dashboard') && $state.params.conversationId) ) && (($state.params.conversationId && $state.params.conversationId == conversationId) || !$state.params.conversationId))
    };
    var isWatchingPost = function(postId) {
      return ($state.current.name == 'posts.show' && postId == $stateParams.poid);
    }
    var showPostNotification = function(title, messageContent, postId) {
      if (isWatchingPost(postId)) {
        $rootScope.$broadcast('load-comments');
      }
      if (Visibility.hidden() || !isWatchingPost(postId)) {
        var myNotification = new Notify(title, {
          body: messageContent,
          notifyClick: function(event) {
            window.focus();
            if (!isWatchingPost(postId)) {
              $state.go('posts.show', {poid: postId});
            }
          },
          icon: "/favicon.png",
          timeout: 5,
          tag: 'postUpdate',
          notifyError: function(err) { console.log("Error"); },
          permissionDenied: function() { console.log("Denied"); },
          permissionGranted: function() { console.log("Granted"); }
        });
        if (!Notify.needsPermission) {
          myNotification.show();
        } else if (Notify.isSupported()) {
          Notify.requestPermission(function() { myNotification.show(); }, function() { console.log("Denied");});
        }
      }
    };
    var showNotification = function(title, messageContent, conversationId, refIds) {
      var watchingThisConversation = false;
      if (Visibility.hidden() || !isWatchingConversation(conversationId, refIds)) {
        var myNotification = new Notify(title, {
          body: messageContent,
          notifyClick: function(event) {
            window.focus();
            if (($state.current.name == 'ad-details' && refIds.clad_id && refIds.clad_id == $stateParams.adid)|| ($state.current.name == 'qr-details' && refIds.qr_id && refIds.qr_id == $stateParams.qrid)) {
              $rootScope.getConversation(conversationId);
            } else if (refIds.qr_id) {
              $state.go('qr-details', {qrid: refIds.qr_id, conversationId: conversationId});
            } else if (refIds.clad_id) {
              $state.go('ad-details', {adid: refIds.clad_id, conversationId: conversationId});
            }
            // if ($state.current.name == 'home.dashboard') {
            //   $rootScope.getConversation(conversationId);
            // } else {
            //   $state.go('home.dashboard', {conversationId: conversationId});
            // }
          },
          icon: "/favicon.png",
          timeout: 5,
          tag: 'messageUpdate',
          notifyError: function(err) { console.log("Error"); },
          permissionDenied: function() { console.log("Denied"); },
          permissionGranted: function() { console.log("Granted"); }
        });
        if (!Notify.needsPermission) {
          myNotification.show();
        } else if (Notify.isSupported()) {
          Notify.requestPermission(function() { myNotification.show(); }, function() { console.log("Denied");});
        }
      }
    };
    var translateSystemMessage = function( content, isSystem ) {
      var translatedMessage = content;
      if (isSystem) {
        var messageContent = JSON.parse(content);
        switch ( messageContent.type ) {
          case 'new_quotation_request':
            translatedMessage = I18n.t("conversations.new_quotation_request");
            break;
          case 'new_quotation':
            translatedMessage = I18n.t("conversations.new_quotation");
            break;
          case 'offer_rejected':
            translatedMessage = I18n.t("conversations.offer_rejected");
            break;
          case 'offer_accepted':
            translatedMessage = I18n.t("conversations.offer_accepted");
            break;
        }
      }
      return translatedMessage;
    };
    var newConversationHandler = function(conversation) {
      if ( isWatchingConversation(conversation.conversation_id, conversation.owner) ) {
        $rootScope.$broadcast('reloadConversations');
      }
      $rootScope.$broadcast('notificationsCountUpdated');
      if (!conversation.from_self) {
        $scope.session.user.unread_conversations_count = conversation.unread_conversations_count;
        $scope.$apply();
        showNotification(I18n.t("conversations.new_message_from", { user_name: conversation.from_user}), translateSystemMessage(conversation.content, conversation.system_generated), conversation.conversation_id, conversation.owner);
      }
    };
    var newConversationReadCountHandler = function(update) {
      $scope.session.user.unread_conversations_count = update.count;
      $scope.$apply();
      $rootScope.$broadcast('notificationsCountUpdated');
    };
    var newPostCommentHandler = function(update) {
      showPostNotification(I18n.t("post.comments.new_comment_from", { user_name: update.from_user}), update.post_title, update.post_id);
      $rootScope.$broadcast('notificationsCountUpdated');
    };
    var newPostCommentMentionHandler = function(update) {
      showPostNotification(I18n.t("post.comments.new_comment_mention_from", { user_name: update.from_user}), update.post_title, update.post_id);
      $rootScope.$broadcast('notificationsCountUpdated');
    };
    var newPostHandler = function(update) {
      showPostNotification(I18n.t("post.new_post_from", { user_name: update.from_user}), update.post_title, update.post_id);
      $rootScope.$broadcast('notificationsCountUpdated');
    };
    var newPostMentionHandler = function(update) {
      showPostNotification(I18n.t("post.new_post_mention_from", { user_name: update.from_user}), update.post_title, update.post_id);
      $rootScope.$broadcast('notificationsCountUpdated');
    };
    var newMessageHandler = function(update) {
      if (!update.from_self) {
        showNotification(I18n.t("conversations.new_message_from", { user_name: update.from_user}), translateSystemMessage(update.message.content, update.message.system_generated), update.conversation_id, update.owner);
        if (Conversations.data.selectedConversation) {
          Conversations.data.selectedConversation.isTyping = false;
        }
      }
      $rootScope.$broadcast('notificationsCountUpdated');
      if (isWatchingConversation(update.message.conversation_id, update.owner)) {
      // if ($location.search().conversationId == update.message.conversation_id && Conversations.data.selectedConversation != null && update.message.conversation_id == Conversations.data.selectedConversation.id) {
          // if (message.system_generated && message.user_id != $scope.session.user.id) {
          //   $scope.getConversation(Conversation.selectedConversation.id);
          // } else {
            Conversations.data.selectedConversation.updated_at = update.message.created_at;
            Conversations.data.selectedConversation.messages.push(update.message);
            if (Visibility.hidden()) {
              $scope.session.user.unread_conversations_count = update.unread_conversations_count;
            } else {
              SocketMessages.notifyConversationRead( $scope.session.user.id, Conversations.data.selectedConversation.id, function(newCount) { $scope.session.user.unread_conversations_count = newCount; $scope.$apply(); } );
            }
          // }
      } else {
        $scope.session.user.unread_conversations_count = update.unread_conversations_count;
      }
      for (var i=0; i<Conversations.data.conversations.length; i++) {
        if (Conversations.data.conversations[i].id == update.message.conversation_id) {
          if (!update.from_self && !update.message.system_generated) {
            Conversations.data.conversations[i].isTyping = false;
          }
          Conversations.data.conversations[i].updated_at = update.message.created_at;
          if (Conversations.data.selectedConversation == null || update.message.conversation_id != Conversations.data.selectedConversation.id) {
            Conversations.data.conversations[i].unread = true;
            Conversations.data.conversations.unshift(Conversations.data.conversations.splice(i, 1)[0]);
          }
          break;
        }
      }
      $scope.$apply();
    };
    var handleMessageSocketReconnect = function() {
      if ($state.current.name == 'ad-details' || $state.current.name == 'qr-details' || $state.current.name == 'home.pros-dashboard' || $state.current.name == 'home.users-dashboard') {
        $rootScope.$broadcast('reloadConversations');
      }
    };
    var handleUserLoaded = function(userData) {
      var goHome = $state.current.name == 'sign_in';
      if (!userData.complete) {
        $state.go('home.users-edit');
      } else if (goHome) {
        if ( userData.user_type == 'pro' ) {
          $state.go('home.pros-dashboard');
        } else {
          $state.go( 'home.users-dashboard' );
        }
      } 
      $scope.session.user = userData;
      $scope.session.connected = true;
      hasToGetUserData = false;
      $scope.isRetrievingProfile = false;
      $rootScope.$broadcast('user-loaded');
      $scope.connectToWebSocket();
      if (Notify.needsPermission && Notify.permissionLevel == 'default') {
        // Ask for permission
        Notify.requestPermission( function() {
          $scope.$apply();
        }, function() { });
      }
    };
    var wsInitialTime = 5;
    var wsCurrentTime = wsInitialTime;
    $scope.remainingSeconds = wsInitialTime;
    $scope.wsIsReconnecting = false;
    // var messageTemplate = '<div><span ng-hide="wsIsReconnecting">Reconnexion dans {{remainingSeconds}} secondes... <a href ng-click="connectToWebSocket()">Réessayer maintenant</a></span><span ng-show="wsIsReconnecting">Tentative de connexion...</span></div>';

    $rootScope.$on('professionSelected', function(event, profession) {
      $scope.selectedProfession = profession;
    });
        
    $rootScope.$on('socket-connexion', function(event, args) {
      $rootScope.isMessagingAvailable = args.connected;
      $scope.wsIsReconnecting = false;
      if (angular.isDefined(wsReconnectPromise)) {
        $interval.cancel(wsReconnectPromise);
      }
      if (args.connected) {
        toastr.clear();
        wsCurrentTime = wsInitialTime;
        handleMessageSocketReconnect();
      } else {
        if (args.mustReconnect) {
          if (wsCurrentTime >= wsInitialTime*2) {
            toastr.warning(I18n.t('general.websocket_reconnect', {time: wsCurrentTime}), I18n.t('general.websocket_lost'));
          }
          
          $scope.remainingSeconds = wsCurrentTime;
          console.info("WebSocket: reconnecting in " + wsCurrentTime + "s");
          wsReconnectPromise = $interval(checkConnectWebSocketInterval, 1000, wsCurrentTime);
          if (wsCurrentTime < 300) {
            wsCurrentTime = wsCurrentTime*2;
          }
        }
      }
    });
    var checkConnectWebSocketInterval = function() {
      $scope.remainingSeconds--;
      if ($scope.remainingSeconds == 0) {
        $scope.connectToWebSocket();
      }
    };
    $scope.connectToWebSocket = function() {
      if (angular.isDefined(wsReconnectPromise)) {
        $interval.cancel(wsReconnectPromise);
        $scope.wsIsReconnecting = true;
      }
      if ($scope.session.connected) {
        SocketMessages.connect($scope.session.user.id, handleUsersOnlineStatus, connectedUserHandler, disconnectedUserHandler, newPostHandler, newPostMentionHandler, newPostCommentHandler, newPostCommentMentionHandler, newMessageHandler, newConversationHandler, userTypingHandler, newConversationReadCountHandler);
      }
    };
    GeoLocation.getLocation()
      .then( function(userData) {
        $scope.session.location = { latitude: userData.latitude, longitude: userData.longitude };
        $rootScope.$broadcast('location-found');
      }, function(message) {
        alertsService.add('danger', message);
      });
    User.getData()
      .then( function(userData) {
        handleUserLoaded(userData);
      }, function(message) {
        hasToGetUserData = true;
        $scope.isRetrievingProfile = false;
      });
    $rootScope.$on('connexion-change', function(event, args) {
      if (args.signedIn) {
        $scope.session.connected = true;
        if (hasToGetUserData && !$scope.isRetrievingProfile) {
          $scope.isRetrievingProfile = true;
          User.getData()
            .then( function(userData) {
              handleUserLoaded(userData);
            }, function(message) {
              $scope.session.connected = false;
              alertsService.add('danger', message);
              $scope.signOut();
              $scope.isRetrievingProfile = false;
            })
        }
      } else {
        $scope.session.connected = false;
        User.resetData();
        $scope.session.user = User.data;
      }
      hasToGetUserData = true;
    });
    $rootScope.signUp = function( email, password, password_confirmation, token ) {
      $rootScope.isSigningIn = true;
      hasToGetUserData = true;
      User.create(email, password, password_confirmation, token)
        .then(function(created) {
          $rootScope.isSigningIn = false;
          if (created) {
            $rootScope.$broadcast('connexion-change', { signedIn: true });
          } else {
            alertsService.add('danger', I18n.t("user.signin.email_used"));
          }
        }, function(message) {
          $rootScope.isSigningIn = false;
          alertsService.add('danger', message);
        });
    };
    $rootScope.signIn = function( email, password ) {
      $rootScope.isSigningIn = true;
      hasToGetUserData = true;
      authService.signIn(email, password)
        .then(function() {
          $rootScope.isSigningIn = false;
        }, function(message) {
          $rootScope.isSigningIn = false;
          alertsService.add('danger', message);
        });
    };
    $scope.signOut = function(toggleMenu) {
      if (angular.isDefined(wsReconnectPromise)) {
        $timeout.cancel(wsReconnectPromise);
      }
      toastr.clear();
      wsCurrentTime = wsInitialTime;
      authService.signOut().then(function(){
        SocketMessages.disconnect();
        $state.go('posts.index');
      });
      if (toggleMenu)
        $mdSidenav('menuSidenav').toggle();
    };
    $scope.$watch('session.user.unread_conversations_count', function(newValue, oldValue) {
      if ($rootScope.title != null) {
        var exprToFind = /^\([0-9]{1,4}\)\s/;
        if ( exprToFind.test($rootScope.title) ) {
          var replacement;
          if ($scope.session.connected) {
            replacement = ($scope.session.user.unread_conversations_count == 0 ? '' : '(' + $scope.session.user.unread_conversations_count + ') ');
          } else {
            replacement = '';
          }
          $document[0].title = $rootScope.title.replace(exprToFind, replacement);
        } else if ($scope.session.user.unread_conversations_count != null && $scope.session.user.unread_conversations_count > 0) {
          $document[0].title = $rootScope.title = '(' + $scope.session.user.unread_conversations_count + ') ' + $rootScope.title;
        }
      }
    });
    $rootScope.replaceNewLinesInText = function(textToReplace) {
      if (textToReplace) {
        return textToReplace.replace(/(?:\r\n|\r|\n)/g, '<br />');
      } else {
        return textToReplace;
      }
    };
  }])

  .controller('HomepageController', ['$scope', '$rootScope', '$interval' , '$state', '$uibModal', 'Alerts', 'Profession', 'Tags', 'Deal', function($scope, $rootScope, $interval, $state, $uibModal, Alerts, Profession, Tags, Deal) {

    $rootScope.setTitle("MyUnéo");

    $scope.invitationPromotionIsCollapsed = true;
    $scope.topDeals = null;
    // $scope.isShowingWhat = 'root';
    var userInfoReady = false;
    
    var respMobileBgList = [$('#resp-mobile-bg0'), $('#resp-mobile-bg1'), $('#resp-mobile-bg2') ];
//    
    var respGetMobileActiveBg = function() {
      $interval(function() {
      var currentBg;
      var nextBg;
      //get currentBg and nextBg, and put currentBg at the end of the array
      currentBg = respMobileBgList.shift();
      respMobileBgList.push(currentBg);
      nextBg = respMobileBgList[0];
      
//      //Toggle class of currentBg and nextBg, to make them disapear/appear respectfully
      currentBg.toggleClass('resp-active');
      nextBg.toggleClass('resp-active');  
      }, 3000);
    };
//
    respGetMobileActiveBg();

    var showReferralPromotion = function() {
      if ($scope.session.connected) {
        $scope.invitationPromotionIsCollapsed = false;
      }
    };

    var initUserData = function() {
      var latitude;
      var longitude
      if ($scope.session.user.place != null) {
        latitude = $scope.session.user.place.latitude;
        longitude = $scope.session.user.place.longitude;
      } else if ($scope.session.user.addresses != null && $scope.session.user.addresses.length > 0) {
        latitude = $scope.session.user.addresses[0].latitude;
        longitude = $scope.session.user.addresses[0].longitude;
      } else if ($scope.session.location) {
        latitude = $scope.session.location.latitude;
        longitude: $scope.session.location.longitude;
      } else {
        return;
      }
      userInfoReady = true;
      Deal.getHomepagePromotions(latitude, longitude)
        .then(function(deals) {
          $scope.topDeals = deals;
          showReferralPromotion();
        }, function(message) {
          Alerts.add('danger', message);
          showReferralPromotion();
        });
    };

    initUserData();

    $rootScope.$on('location-found', function(event, args) {
      if (!$scope.session.connected && !userInfoReady) {
        initUserData();
      }
    });
    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });

  }])

  .controller('ChangeEmailModalController', ['$scope', '$uibModalInstance', '$filter', 'Alerts', 'Authentication', 'oldEmail', function($scope, $uibModalInstance, $filter, Alerts, Authentication, oldEmail){
    $scope.title = I18n.t("home.change_email_modal.title");
    $scope.introText = I18n.t("home.change_email_modal.content");
    $scope.cancelLabel = I18n.t("home.change_email_modal.cancel_label");
    $scope.confirmLabel = I18n.t("home.change_email_modal.confirm_label");
    $scope.newEmail = "";
    $scope.emailIsFree = true;
    $scope.isUpdating = false;

    $scope.confirm = function () {
      if ($scope.newEmail != '') {
        $scope.isUpdating = true;
        Authentication.changeEmail(oldEmail, $scope.newEmail)
          .then(function(emailIsFree) {
            $scope.emailIsFree = emailIsFree;
            if (emailIsFree) {
              $uibModalInstance.close($scope.newEmail);
            } else {
              $scope.isUpdating = false;
            }
          }, function(message) {
            $scope.isUpdating = false;
            Alerts.add('danger', message);
          });
        }
    };

    $scope.cancel = function () {
      $uibModalInstance.dismiss('cancel');
    };
  }])

  .controller('DashboardController', ['$scope', '$rootScope', '$filter', '$state', '$uibModal', 'Alerts', 'Profession', 'Analytics' , function($scope, $rootScope, $filter, $state, $uibModal, Alerts, Profession, Analytics){
    $rootScope.setTitle(I18n.t('user_dashboard.title'));

    var setButtonsStatus = function(stateName) {
      $scope.showEditProfileButton = stateName != 'home.users-edit';
      $scope.showMyFavoritesButton = (stateName != 'home.fav-pros' && $scope.session.user.user_type != 'pro');
      $scope.showVisibilityButton = (stateName != 'home.pro-visibility' && $scope.session.user.user_type == 'pro');
      $scope.showPostClassifiedAdButton = (stateName != 'home.post' && $scope.session.user.user_type == 'particulier');
      $scope.showMyDealsButton = (stateName != 'home.deal-mgt' && $scope.session.user.user_type == 'pro');
      $scope.showReferralButton = (stateName != 'home.referrals');
    };

    if ($scope.session.connected && $scope.session.user) {
      setButtonsStatus($state.current.name);
    }

    $rootScope.$on('$stateChangeSuccess', function(event, toState, toStateParams) {
      setButtonsStatus(toState.name);
    });

    var setActivities = function() {
      if ($scope.professions != null && $scope.session.connected) {
        $scope.activities = getActivitiesForPro($scope.session.user, $scope.professions, $filter);
      }
    }

    $scope.changeEmail = function() {
      var modalInstance = $uibModal.open({
        templateUrl: 'modals/change-email-modal.html',
        controller: 'ChangeEmailModalController',
        resolve: {
          oldEmail: function() {
            return $scope.session.user.email;
          }
        }
      });
      modalInstance.result.then(function (email) {
        $scope.session.user.email = email;
        // Deal.deleteDeal(dealId)
        //   .then(function(deal) {
        //     Alerts.add('success', I18n.t("deals.deal_deleted"));
        //     loadDeals();
        //   }, function(messages) {
        //     for (var i=0; i<messages.length; i++) {
        //       Alerts.add('danger', messages[i]);
        //     }
        //   });
      }, function () {
        // Cancelled
      });
    };
    
    $rootScope.$on('user-loaded', function(event, args) {
      setActivities();
      setButtonsStatus($state.current.name);
    });

    Profession.getData()
      .then(function(professions) {
        $scope.professions = professions;
        setActivities();
      }, function(message) {
        Alerts.add('danger', message);
      });
  }])

  .controller('SubItemModalController', ['$scope', '$uibModalInstance', 'Alerts', 'items', 'selectedItem', function($scope, $uibModalInstance, Alerts, items, selectedItem){
    $scope.pageSize = 15;
    $scope.itemsFilter = { searchTerms: "" };

    $scope.selectProfession = function (profession) {
      if (profession.children && profession.children.length > 0) {
        $scope.professions = profession.children;
        $scope.title = profession.name;
        $scope.isShowingRoot = false;
      } else {
        $uibModalInstance.close(profession.id);
      }
    };

    $scope.showRoot = function() {
      $scope.professions = items;
      $scope.title = "Choisissez une catégorie";
      $scope.isShowingRoot = true;
    }

    $scope.cancel = function () {
      $uibModalInstance.dismiss('cancel');
    };
    
    $scope.isShowingRoot = selectedItem == null;
    if ($scope.isShowingRoot) {
      $scope.showRoot();
    } else {
      $scope.professions = selectedItem.children;
      $scope.title = selectedItem.name;
    }
  }])

  .controller('BuyProfileImpressionsModalController', ['$scope', '$uibModalInstance', '$filter', 'Alerts', 'Pricings', 'target', 'userBalance', function($scope, $uibModalInstance, $filter, Alerts, Pricings, target, userBalance){
    $scope.confirmTitle = I18n.t("visibility.profile_modal.loading_title");
    $scope.confirmText = I18n.t("visibility.profile_modal.loading_text");
    $scope.cancelLabel = I18n.t("visibility.profile_modal.cancel_label");
    $scope.isLoading = true;
    var userIsPaying;

    Pricings.getProfilePricings()
      .then(function(pricings) {
        var pricing = $filter('filter')(pricings, {target: target}, true)[0];
        if (pricing.credit_amount > userBalance) {
          // Can't pay
          userIsPaying = false;
          $scope.confirmLabel = I18n.t("visibility.profile_modal.reload_label");
          $scope.confirmTitle = I18n.t("visibility.profile_modal.reload_title");
          $scope.confirmText = I18n.t("visibility.profile_modal.reload_text", { amount: pricing.credit_amount - userBalance});
        } else {
          // Can pay
          userIsPaying = true;
          $scope.confirmLabel = I18n.t("visibility.profile_modal.buy_label");
          $scope.confirmTitle = target == 'sponsored_profile' ? I18n.t("visibility.profile_modal.buy_profile_title") : I18n.t("visibility.profile_modal.buy_map_profile_title");
          $scope.confirmText = I18n.t("visibility.profile_modal.buy_profile_title", { amount: pricing.credit_amount });
        }
        $scope.isLoading = false;
      }, function(message) {
        Alerts.add('danger', message);
        $uibModalInstance.dismiss('cancel');
      });

    $scope.confirm = function () {
      $uibModalInstance.close(userIsPaying);
    };

    $scope.cancel = function () {
      $uibModalInstance.dismiss('cancel');
    };
  }])

  .controller('UnlockClassifiedAdModalController', ['$scope', '$uibModalInstance', 'Alerts', 'Pricings', 'authorizationType', 'title', 'userBalance', function($scope, $uibModalInstance, Alerts, Pricings, authorizationType, title, userBalance){
    $scope.confirmTitle = I18n.t("classified_ad.unlock_modal.loading_title");
    $scope.confirmText = I18n.t("classified_ad.unlock_modal.loading_text");
    $scope.cancelLabel = I18n.t("classified_ad.unlock_modal.cancel_label");
    $scope.isLoading = true;
    var userIsPaying;

    Pricings.getPricingForClassifiedAdUnlock()
      .then(function(pricing) {
        if (pricing.credit_amount == 0) {
          userIsPaying = true;
          $scope.confirmLabel = I18n.t("classified_ad.unlock_modal.free_offer_label");
          $scope.confirmTitle = I18n.t("classified_ad.unlock_modal.classified_ad_free_offer_title");
          $scope.confirmText = authorizationType == 'classifiedAd' ? I18n.t("classified_ad.unlock_modal.classified_ad_free_offer_text", { name: title }) : I18n.t("classified_ad.unlock_modal.quotation_request_free_offer_text");
        } else if (pricing.credit_amount > userBalance) {
          // Can't pay
          userIsPaying = false;
          $scope.confirmLabel = I18n.t("classified_ad.unlock_modal.reload_label");
          $scope.confirmTitle = I18n.t("classified_ad.unlock_modal.reload_title");
          $scope.confirmText = I18n.t("classified_ad.unlock_modal.reload_text", { amount: pricing.credit_amount - userBalance});
        } else {
          // Can pay
          userIsPaying = true;
          $scope.confirmLabel = I18n.t("classified_ad.unlock_modal.buy_label");
          $scope.confirmTitle = authorizationType == 'classifiedAd' ? I18n.t("classified_ad.unlock_modal.classified_ad_not_authorized_title") : I18n.t("classified_ad.unlock_modal.quotation_request_not_authorized_title");
          $scope.confirmText = authorizationType == 'classifiedAd' ? I18n.t("classified_ad.unlock_modal.classified_ad_buy_text", { name: title, amount: pricing.credit_amount}) : I18n.t("classified_ad.unlock_modal.quotation_request_buy_text", { name: title, amount: pricing.credit_amount});
        }
        $scope.isLoading = false;
      }, function(message) {
        Alerts.add('danger', message);
        $uibModalInstance.dismiss('cancel');
      });

    $scope.confirm = function () {
      $uibModalInstance.close(userIsPaying);
    };

    $scope.cancel = function () {
      $uibModalInstance.dismiss('cancel');
    };
  }])

  .controller('ConfirmModalController', ['$scope', '$uibModalInstance', 'Alerts', 'confirmTitle', 'confirmText', 'confirmLabel', 'cancelLabel', function($scope, $uibModalInstance, Alerts, confirmTitle, confirmText, confirmLabel, cancelLabel){
    $scope.confirmTitle = confirmTitle;
    $scope.confirmText = confirmText;
    $scope.confirmLabel = confirmLabel;
    $scope.cancelLabel = cancelLabel;
    $scope.confirm = function () {
      $uibModalInstance.close();
    };

    $scope.cancel = function () {
      $uibModalInstance.dismiss('cancel');
    };
  }])

  .controller('ReportClassifiedAdModalController', ['$scope', '$uibModalInstance', 'Alerts', 'confirmTitle', 'confirmText', 'confirmLabel', 'cancelLabel', function($scope, $uibModalInstance, Alerts, confirmTitle, confirmText, confirmLabel, cancelLabel){
    $scope.title = confirmTitle;
    $scope.introText = confirmText;
    $scope.confirmLabel = confirmLabel;
    $scope.cancelLabel = cancelLabel;
    $scope.reportReason = { type: 'spam', reason: '' };
    $scope.confirm = function () {
      if ($scope.reportReason.type != 'other') {
        $scope.reportReason.reason = $scope.reportReason.type;
      }
      $uibModalInstance.close($scope.reportReason.reason);
    };

    $scope.cancel = function () {
      $uibModalInstance.dismiss('cancel');
    };
  }])

  .controller('UserResponseModalController', ['$scope', '$uibModalInstance', 'Alerts', 'type', 'conversationId', function($scope, $uibModalInstance, Alerts, type, conversationId){
    $scope.userResponse = { reason: "" };
    if (type == 'accept') {
      $scope.title = I18n.t("proposal_response.accept_title");
      $scope.introText = I18n.t("proposal_response.accept_text");
      $scope.confirmLabel = I18n.t("proposal_response.accept_label");
    } else {
      $scope.title = I18n.t("proposal_response.reject_title");
      $scope.introText = I18n.t("proposal_response.reject_text");
      $scope.confirmLabel = I18n.t("proposal_response.reject_label");
    }
    $scope.cancelLabel = "Annuler";
    $scope.confirm = function () {
      $uibModalInstance.close($scope.userResponse.reason);
    };

    $scope.cancel = function () {
      $uibModalInstance.dismiss('cancel');
    };
  }])

  .controller('ProDashboardController', ['$scope', '$rootScope', '$filter', '$state', '$uibModal', 'Alerts', 'ClassifiedAd', 'QuotationRequest', 'Authorizations', 'Conversations', 'User', 'Post', 'PostCategorySubscription', 'UserFavorites', 'FavoritePosts', 'PostAuthorSubscription', 'FavoriteProfessionals', 'FavoriteDeals', 'Deal', function($scope, $rootScope, $filter, $state, $uibModal, Alerts, ClassifiedAd, QuotationRequest, Authorizations, Conversations, User, Post, PostCategorySubscription, UserFavorites, FavoritePosts, PostAuthorSubscription, FavoriteProfessionals, FavoriteDeals, Deal) {
    $rootScope.setTitle(I18n.t('user_dashboard.title'));
    $scope.isLoading = true;
    $scope.isPreferencesLoading = false;
    $scope.myList = [];
    $scope.tabs = { selected: 0 };
    $scope.communicationsFilter = { searchTerms: '', selectedFilter: 'messages', myResultsFilter: 'accepted' };
    $scope.postsFilter = { searchTerms: '', selectedFilter: 'myPosts' };
    $scope.preferencesFilter = { searchTerms: '', selectedFilter: 'subscriptions' };
    $scope.dealFilter = { searchTerms: '', selectedFilter: 'current' };
    $scope.loadParams = { selectedAddressId: null };
    $scope.updatingClassified = {};
    $scope.myAds = [];
    $scope.myDeals = [];
    var modalInstance;

    var getNotifications = function() {
      if ($scope.session.connected) {
        User.getNotifications()
          .then(function(notifications) {
            $scope.session.user.notifications = notifications;
          }, function(message) {
            Alerts.add('danger', message);
          });
      }
    };

    $scope.toggleFavorite = function(favorite) {
      favorite.isSaving = true;
      if (favorite.favorite_type == 'pro') {
        if (favorite.favorited) {
          FavoriteProfessionals.removeFromFavorites(favorite.pro_id)
            .then(function() {
              favorite.favorited = false;
              favorite.isSaving = false;
            }, function(message) {
              favorite.isSaving = false;
              Alerts.add('danger', message);
            });
        } else {
          FavoriteProfessionals.addToFavorites(favorite.pro_id)
            .then(function() {
              favorite.favorited = true;
              favorite.isSaving = false;
            }, function(message) {
              favorite.isSaving = false;
              Alerts.add('danger', message);
            });
        }
      } else if (favorite.favorite_type == 'post') {
        if (favorite.favorited) {
          FavoritePosts.removeFromFavorites(favorite.id)
            .then(function() {
              favorite.isSaving = false;
              favorite.favorited = false;
              Alerts.add('success', I18n.t("post.unfavorited"));
            }, function(message) {
              Alerts.add('danger', message);
              favorite.isSaving = false;
            });
        } else {
          FavoritePosts.addToFavorites(favorite.post_id)
            .then(function(favorite_post_id) {
              favorite.isSaving = false;
              favorite.favorited = true;
              favorite.id = favorite_post_id;
              Alerts.add('success', I18n.t("post.favorited"));
            }, function(message) {
              Alerts.add('danger', message);
              favorite.isSaving = false;
            });
        }
      } else if (favorite.favorite_type == 'deal') {
        if (favorite.favorited) {
          FavoriteDeals.removeFromFavorites(favorite.id)
            .then(function() {
              favorite.isSaving = false;
              favorite.favorited = false;
              Alerts.add('success', I18n.t("deals.unfavorited"));
            }, function(message) {
              Alerts.add('danger', message);
              favorite.isSaving = false;
            });
        } else {
          FavoriteDeals.addToFavorites(favorite.deal_id)
            .then(function(favorite_deal_id) {
              favorite.isSaving = false;
              favorite.favorited = true;
              favorite.id = favorite_deal_id;
              Alerts.add('success', I18n.t("deals.favorited"));
            }, function(message) {
              Alerts.add('danger', message);
              favorite.isSaving = false;
            });
        }
      } else {
        favorite.isSaving = false;
      }
      
    };

    $scope.subscribeAuthor = function(currentPost) {
      currentPost.author_subscribing = true;
      PostAuthorSubscription.subscribe(currentPost.user_nickname)
        .then(function(subscription) {
          currentPost.author_subscribing = false;
          currentPost.author_subscribed = true;
          currentPost.author_subscription_id = subscription.id;
          currentPost.num_of_subscriptions++;
          Alerts.add('success', I18n.t("post.author_subscribed", {author: currentPost.user_nickname}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.author_subscribing = false;
        });
    }

    $scope.unsubscribeAuthor = function(currentPost) {
      currentPost.author_subscribing = true;
      PostAuthorSubscription.unsubscribe(currentPost.author_subscription_id)
        .then(function() {
          currentPost.author_subscribing = false;
          currentPost.author_subscribed = false;
          currentPost.num_of_subscriptions--;
          Alerts.add('success', I18n.t("post.author_unsubscribed", {author: currentPost.user_nickname}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.author_subscribing = false;
        });
    };

    $scope.addToFavorites = function(currentPost) {
      currentPost.adding_to_favorites = true;
      FavoritePosts.addToFavorites(currentPost.id)
        .then(function(favorite_post_id) {
          currentPost.adding_to_favorites = false;
          currentPost.favorited = true;
          currentPost.favorite_post_id = favorite_post_id;
          currentPost.num_of_favorited++;
          Alerts.add('success', I18n.t("post.favorited"));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.adding_to_favorites = false;
        });
    }

    $scope.removeFromFavorites = function(currentPost) {
      currentPost.adding_to_favorites = true;
      FavoritePosts.removeFromFavorites(currentPost.favorite_post_id)
        .then(function() {
          currentPost.adding_to_favorites = false;
          currentPost.favorited = false;
          currentPost.num_of_favorited--;
          Alerts.add('success', I18n.t("post.unfavorited"));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.adding_to_favorites = false;
        });
    };

    $scope.updatePremiumSubscription = function() {
      $scope.isSavingProfile = true;
      User.saveData({ id: $scope.session.user.id, premium_posts: $scope.session.user.premium_posts })
        .then(function( userData ) {
          $scope.session.user = userData;
          $scope.isSavingProfile = false;
          Alerts.add('success', I18n.t("pro_profile.changes_saved"));
          getPostSubscriptions();
        }, function(messages) {
          $scope.isSavingProfile = false;
          for (var i=0; i<messages.length; i++) {
            Alerts.add('danger', messages[i]);
          }
        });
    };

    $scope.categorySubscribe = function(currentPost) {
      currentPost.subscribing = true;
      PostCategorySubscription.subscribe(currentPost.category_id)
        .then(function(subscription) {
          currentPost.subscribing = false;
          currentPost.category_subscribed = true;
          currentPost.category_subscription_id = subscription.id;
          Alerts.add('success', I18n.t("post.subscribed", {category: currentPost.category_name}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.subscribing = false;
        });
    };

    $scope.categoryUnsubscribe = function(currentPost) {
      currentPost.subscribing = true;
      PostCategorySubscription.unsubscribe(currentPost.category_subscription_id)
        .then(function() {
          currentPost.subscribing = false;
          currentPost.category_subscribed = false;
          currentPost.category_subscription_id = -1
          Alerts.add('success', I18n.t("post.unsubscribed", {category: currentPost.category_name}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.subscribing = false;
        });
    };

    $scope.getPreferences = function() {
      if ($scope.preferencesFilter.selectedFilter == "subscriptions") {
        getPostSubscriptions();
      } else if ($scope.preferencesFilter.selectedFilter == "favorites") {
        getFavorites();
      }
    };

    var getFavorites = function() {
      $scope.isPreferencesLoading = true;
      UserFavorites.getMine()
        .then(function(favorites) {
          $scope.favorites = favorites;
          $scope.isPreferencesLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPreferencesLoading = false;
        });
    };

    var getPostSubscriptions = function() {
      $scope.isPreferencesLoading = true;
      Post.getAll({ subscriptions: true })
        .then(function(posts) {
          $scope.posts = posts;
          $scope.isPreferencesLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPreferencesLoading = false;
        });
    };

    var getMyPosts = function() {
      $scope.isPostsLoading = true;
      Post.getMine()
        .then(function(posts) {
          $scope.posts = posts;
          $scope.isPostsLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPostsLoading = false;
        });
    }

    var getMentions = function() {
      $scope.isPostsLoading = true;
      Post.getMentions()
        .then(function(posts) {
          $scope.mentions = posts;
          $scope.isPostsLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPostsLoading = false;
        });
    };

    $scope.getPosts = function() {
      if ($scope.postsFilter.selectedFilter == "myPosts") {
        getMyPosts();
      } else if ($scope.postsFilter.selectedFilter == "mentions") {
        getMentions();
      }
    }

    $scope.getCommunications = function() {
      switch($scope.communicationsFilter.selectedFilter) {
        case 'messages':
          $scope.getConversations();
          break;
        case 'leads':
          $scope.getClassifiedAds();
          break;
        case 'results':
          $scope.getQuotationRequests();
          break;
      }
    };

    $scope.buyClassifiedAd = function(classifiedAd) {
      buyClassifiedAd(classifiedAd, $scope, $uibModal, $state, Authorizations, Alerts);
    };

    $scope.openOrBuyQuotationRequest = function(quotationRequest) {
      if (quotationRequest.authorized) {
        $state.go('qr-details', {qrid: quotationRequest.id});
      } else {
        buyQuotationRequest(quotationRequest, $scope, $uibModal, $state, Authorizations, Alerts, $rootScope, QuotationRequest);
      }
    };

    $scope.setClassifiedStatus = function(adId, status) {
      $scope.updatingClassified[adId] = true;
      ClassifiedAd.update({ id: adId, status: status} )
        .then(function(ad) {
          $scope.updatingClassified[adId] = false;
          var selectedClassified = $filter('filter')(myAds, {id: adId}, true)[0];
          selectedClassified.status = ad.status;
        }, function(message) {
          $scope.updatingClassified[adId] = false;
          Alerts.add('danger', message);
        });
    };

    $scope.getClassifiedAdsAroundMe = function() {
      if ($scope.loadParams.selectedAddressId) {
        $scope.isLoading = true;
        ClassifiedAd.getAroundMe($scope.loadParams.selectedAddressId)
          .then(function(ads) {
            $scope.isLoading = false;
            $scope.myAds = ads;
          }, function(message) {
            $scope.isLoading = false;
            Alerts.add('danger', message);
          });
        }
    };

    $scope.getClassifiedAds = function() {
      $scope.myList = [];
      $scope.isLoading = true;
      ClassifiedAd.getMine()
        .then(function(ads) {
          $scope.isLoading = false;
          $scope.myList = ads;
        }, function(message) {
          $scope.isLoading = false;
          Alerts.add('danger', message);
        });
    };

    $scope.getMyResults = function() {
      $scope.myList = [];
      $scope.isLoading = true;
      ClassifiedAd.getMine($scope.filter.myResultsFilter)
        .then(function(ads) {
          $scope.isLoading = false;
          $scope.myList = ads;
        }, function(message) {
          $scope.isLoading = false;
          Alerts.add('danger', message);
        });
    };

    $scope.getQuotationRequests = function() {
      $scope.isLoading = true;
      // QuotationRequest.getMine($scope.filter.selectedFilter)
      QuotationRequest.getMine()
        .then(function(quotationRequests) {
          $scope.isLoading = false;
          $scope.myList = quotationRequests;
        }, function(message) {
          $scope.isLoading = false;
          Alerts.add('danger', message);
        });
    };

    $scope.getConversations = function() {
      $scope.isLoading = true;
      Conversations.getByOrphan()
        .then(function(conversations) {
          $scope.isLoading = false;
          $scope.myConversations = conversations;
        }, function(message) {
          $scope.isLoading = false;
          Alerts.add('danger', message);
        });
    };

    $scope.getDeals = function() {
      Deal.getMine()
        .then(function(deals) {
          $scope.myDeals = deals;
          $scope.isLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoading = false;
        });
    };

    $scope.deleteDeal = function(dealId) {
      modalInstance = $uibModal.open({
        templateUrl: 'modals/confirm-modal.html',
        controller: 'ConfirmModalController',
        resolve: {
          confirmTitle: function () {
            return I18n.t("deals.manager.delete_title");
          },
          confirmText: function () {
            return I18n.t("deals.manager.delete_text");
          },
          confirmLabel: function () {
            return I18n.t("deals.manager.delete_label");
          },
          cancelLabel: function () {
            return I18n.t("deals.manager.cancel_label");
          }
        }
      });
      modalInstance.result.then(function () {
        Deal.deleteDeal(dealId)
          .then(function(deal) {
            Alerts.add('success', I18n.t("deals.deal_deleted"));
            loadDeals();
          }, function(messages) {
            for (var i=0; i<messages.length; i++) {
              Alerts.add('danger', messages[i]);
            }
          });
      }, function () {
        // Cancelled
      });


    };

    var initUserData = function() {
      if ($scope.session.user.addresses.length > 0) {
        $scope.loadParams.selectedAddressId = $scope.session.user.addresses[0].id;
        $scope.getClassifiedAdsAroundMe();
        getNotifications();
      }
    }

    if ($scope.session.connected) {
      initUserData();
    }

    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });

    $rootScope.$on('reloadConversations', function(event, args) {
      if ($scope.tabs.selected == 1 && $scope.communicationsFilter.selectedFilter == 'messages') {
        $scope.getConversations();
      }
    });

    $rootScope.$on('notificationsCountUpdated', function(event, args) {
      if ($scope.tabs.selected == 1) {
        $scope.getCommunications();
      } else if ($scope.tabs.selected == 4) {
        $scope.getPosts();
      }
      getNotifications();
    });

  }])

  .controller('UserDashboardController', ['$scope', '$rootScope', '$filter', '$state', '$sce', 'Alerts', 'ClassifiedAd', 'QuotationRequest', 'Conversations', 'User', 'Post', 'FavoritePosts', 'PostAuthorSubscription', 'PostCategorySubscription', 'UserFavorites', 'FavoriteProfessionals', 'FavoriteDeals', function($scope, $rootScope, $filter, $state, $sce, Alerts, ClassifiedAd, QuotationRequest, Conversations, User, Post, FavoritePosts, PostAuthorSubscription, PostCategorySubscription, UserFavorites, FavoriteProfessionals, FavoriteDeals) {
    $rootScope.setTitle(I18n.t('user_dashboard.title'));
    $scope.isLoading = true;
    $scope.myAds = [];
    $scope.tabs = { selected: 0 };
    $scope.filter = { searchTerms: '', selectedFilter: 'messages', selectedTab: 0 };
    $scope.preferencesFilter = { searchTerms: '', selectedFilter: 'subscriptions' };
    $scope.postsFilter = { searchTerms: '', selectedFilter: 'myPosts' };
    $scope.updatingClassified = {};
    $scope.myQuotationRequests = [];

    var getNotifications = function() {
      if ($scope.session.connected) {
        User.getNotifications()
          .then(function(notifications) {
            $scope.session.user.notifications = notifications;
          }, function(message) {
            Alerts.add('danger', message);
          });
      }
    };

    var initUserData = function() {
      if ($state.current.name == 'home.users-dashboard' && $scope.session.user.user_type == 'pro') {
        $state.go('home.pros-dashboard');
      } else {
        $scope.getCommunications();
        getNotifications();
      }
    };

    $scope.convertDescription = function(desc) {
      return $sce.trustAsHtml( desc );
    };

    $scope.updatePremiumSubscription = function() {
      $scope.isSavingProfile = true;
      User.saveData({ id: $scope.session.user.id, premium_posts: $scope.session.user.premium_posts })
        .then(function( userData ) {
          $scope.session.user = userData;
          $scope.isSavingProfile = false;
          Alerts.add('success', I18n.t("pro_profile.changes_saved"));
          getPostSubscriptions();
        }, function(messages) {
          $scope.isSavingProfile = false;
          for (var i=0; i<messages.length; i++) {
            Alerts.add('danger', messages[i]);
          }
        });
    };

    var getMyPosts = function() {
      $scope.isPostsLoading = true;
      Post.getMine()
        .then(function(posts) {
          $scope.posts = posts;
          $scope.isPostsLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPostsLoading = false;
        });
    }

    var getMentions = function() {
      $scope.isPostsLoading = true;
      Post.getMentions()
        .then(function(posts) {
          $scope.mentions = posts;
          $scope.isPostsLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPostsLoading = false;
        });
    };

    $scope.getPosts = function() {
      if ($scope.postsFilter.selectedFilter == "myPosts") {
        getMyPosts();
      } else if ($scope.postsFilter.selectedFilter == "mentions") {
        getMentions();
      }
    }

    $scope.toggleFavorite = function(favorite) {
      favorite.isSaving = true;
      if (favorite.favorite_type == 'pro') {
        if (favorite.favorited) {
          FavoriteProfessionals.removeFromFavorites(favorite.pro_id)
            .then(function() {
              favorite.favorited = false;
              favorite.isSaving = false;
            }, function(message) {
              favorite.isSaving = false;
              Alerts.add('danger', message);
            });
        } else {
          FavoriteProfessionals.addToFavorites(favorite.pro_id)
            .then(function() {
              favorite.favorited = true;
              favorite.isSaving = false;
            }, function(message) {
              favorite.isSaving = false;
              Alerts.add('danger', message);
            });
        }
      } else if (favorite.favorite_type == 'post') {
        if (favorite.favorited) {
          FavoritePosts.removeFromFavorites(favorite.id)
            .then(function() {
              favorite.isSaving = false;
              favorite.favorited = false;
              Alerts.add('success', I18n.t("post.unfavorited"));
            }, function(message) {
              Alerts.add('danger', message);
              favorite.isSaving = false;
            });
        } else {
          FavoritePosts.addToFavorites(favorite.post_id)
            .then(function(favorite_post_id) {
              favorite.isSaving = false;
              favorite.favorited = true;
              favorite.id = favorite_post_id;
              Alerts.add('success', I18n.t("post.favorited"));
            }, function(message) {
              Alerts.add('danger', message);
              favorite.isSaving = false;
            });
        }
      } else if (favorite.favorite_type == 'deal') {
        if (favorite.favorited) {
          FavoriteDeals.removeFromFavorites(favorite.id)
            .then(function() {
              favorite.isSaving = false;
              favorite.favorited = false;
              Alerts.add('success', I18n.t("deals.unfavorited"));
            }, function(message) {
              Alerts.add('danger', message);
              favorite.isSaving = false;
            });
        } else {
          FavoriteDeals.addToFavorites(favorite.deal_id)
            .then(function(favorite_deal_id) {
              favorite.isSaving = false;
              favorite.favorited = true;
              favorite.id = favorite_deal_id;
              Alerts.add('success', I18n.t("deals.favorited"));
            }, function(message) {
              Alerts.add('danger', message);
              favorite.isSaving = false;
            });
        }
      } else {
        favorite.isSaving = false;
      }
      
    };

    $scope.getPreferences = function() {
      if ($scope.preferencesFilter.selectedFilter == "subscriptions") {
        getPostSubscriptions();
      } else if ($scope.preferencesFilter.selectedFilter == "favorites") {
        getFavorites();
      }
    };

    var getFavorites = function() {
      $scope.isPreferencesLoading = true;
      UserFavorites.getMine()
        .then(function(favorites) {
          $scope.favorites = favorites;
          $scope.isPreferencesLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPreferencesLoading = false;
        });
    };

    var getPostSubscriptions = function() {
      $scope.isPreferencesLoading = true;
      Post.getAll({ subscriptions: true })
        .then(function(posts) {
          $scope.subscribedPosts = posts;
          $scope.isPreferencesLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPreferencesLoading = false;
        });
    };

    $scope.getClassifiedAds = function() {
      if ($scope.session.connected && $scope.isLoadingWhat != $scope.filter.selectedFilter) {
        $scope.myAds = [];
        $scope.isLoading = true;
        $scope.isLoadingWhat = $scope.filter.selectedFilter;
        ClassifiedAd.getMine($scope.filter.selectedFilter)
          .then(function(ads) {
            $scope.isLoading = false;
            $scope.isLoadingWhat = "";
            $scope.myAds = ads;
          }, function(message) {
            $scope.isLoading = false;
            $scope.isLoadingWhat = "";
            Alerts.add('danger', message);
          });
      }
    };
    
    $scope.getQuotationRequests = function() {
      if ($scope.session.connected) {
        $scope.isLoading = true;
        QuotationRequest.getMine()
          .then(function(quotationRequests) {
            $scope.isLoading = false;
            $scope.myQuotationRequests = quotationRequests;
          }, function(message) {
            $scope.isLoading = false;
            Alerts.add('danger', message);
          });
      }
    };

    $scope.getConversations = function() {
      if ($scope.session.connected) {
        $scope.isLoading = true;
        Conversations.getByOrphan()
          .then(function(conversations) {
            $scope.isLoading = false;
            $scope.conversations = conversations;
          }, function(message) {
            $scope.isLoading = false;
            Alerts.add('danger', message);
          });
      }
    };

    $scope.getCommunications = function() {
      if ($scope.filter.selectedFilter == 'classified_ads') {
        $scope.getClassifiedAds();
      } else if ($scope.filter.selectedFilter == 'quotation') {
        $scope.getQuotationRequests();
      } else if ($scope.filter.selectedFilter == 'messages') {
        $scope.getConversations();
      }
    };

    $scope.categorySubscribe = function(currentPost) {
      currentPost.subscribing = true;
      PostCategorySubscription.subscribe(currentPost.category_id)
        .then(function(subscription) {
          currentPost.subscribing = false;
          currentPost.category_subscribed = true;
          currentPost.category_subscription_id = subscription.id;
          Alerts.add('success', I18n.t("post.subscribed", {category: currentPost.category_name}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.subscribing = false;
        });
    };

    $scope.categoryUnsubscribe = function(currentPost) {
      currentPost.subscribing = true;
      PostCategorySubscription.unsubscribe(currentPost.category_subscription_id)
        .then(function() {
          currentPost.subscribing = false;
          currentPost.category_subscribed = false;
          currentPost.category_subscription_id = -1
          Alerts.add('success', I18n.t("post.unsubscribed", {category: currentPost.category_name}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.subscribing = false;
        });
    };

    $scope.subscribeAuthor = function(currentPost) {
      currentPost.author_subscribing = true;
      PostAuthorSubscription.subscribe(currentPost.user_nickname)
        .then(function(subscription) {
          currentPost.author_subscribing = false;
          currentPost.author_subscribed = true;
          currentPost.author_subscription_id = subscription.id;
          currentPost.num_of_subscriptions++;
          Alerts.add('success', I18n.t("post.author_subscribed", {author: currentPost.user_nickname}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.author_subscribing = false;
        });
    }

    $scope.unsubscribeAuthor = function(currentPost) {
      currentPost.author_subscribing = true;
      PostAuthorSubscription.unsubscribe(currentPost.author_subscription_id)
        .then(function() {
          currentPost.author_subscribing = false;
          currentPost.author_subscribed = false;
          currentPost.num_of_subscriptions--;
          Alerts.add('success', I18n.t("post.author_unsubscribed", {author: currentPost.user_nickname}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.author_subscribing = false;
        });
    };

    $scope.addToFavorites = function(currentPost) {
      currentPost.adding_to_favorites = true;
      FavoritePosts.addToFavorites(currentPost.id)
        .then(function(favorite_post_id) {
          currentPost.adding_to_favorites = false;
          currentPost.favorited = true;
          currentPost.favorite_post_id = favorite_post_id;
          currentPost.num_of_favorited++;
          Alerts.add('success', I18n.t("post.favorited"));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.adding_to_favorites = false;
        });
    }

    $scope.removeFromFavorites = function(currentPost) {
      currentPost.adding_to_favorites = true;
      FavoritePosts.removeFromFavorites(currentPost.favorite_post_id)
        .then(function() {
          currentPost.adding_to_favorites = false;
          currentPost.favorited = false;
          currentPost.num_of_favorited--;
          Alerts.add('success', I18n.t("post.unfavorited"));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.adding_to_favorites = false;
        });
    };

    if ($scope.session.connected) {
      initUserData();
    }
    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });

    $rootScope.$on('reloadConversations', function(event, args) {
      if ($scope.tabs.selected == 0 && $scope.filter.selectedFilter == "messages") {
        $scope.getConversations();
      }
    });

    $rootScope.$on('notificationsCountUpdated', function(event, args) {
      if ($scope.tabs.selected == 0) {
        if ($scope.filter.selectedFilter == "classified_ads") {
          $scope.getClassifiedAds();
        } else if ($scope.filter.selectedTab == "quotation") {
          $scope.getQuotationRequests();
        }
      } else if ($scope.tabs.selected == 1) {
        if ($scope.preferencesFilter.selectedFilter == "subscriptions") {
          $scope.getPostSubscriptions();
        }
      } else if ($scope.tabs.selected == 2) {
        $scope.getPosts();
      }
      getNotifications();
    });

  }])

  .controller('PublicClassifiedController', ['$scope', '$rootScope', '$state', '$cookies', '$mdDialog', 'Alerts', 'ClassifiedAd', function($scope, $rootScope, $state, $cookies, $mdDialog, Alerts, ClassifiedAd) {
    $rootScope.setTitle(I18n.t('classified_ad.title'));
    $scope.isLoading = true;
    $scope.singleAd;
    var adId = $state.params.adid;

    ClassifiedAd.getPublicById(adId)
      .then(function(ad) {
        $scope.isLoading = false;
        $scope.singleAd = ad;
        setTitle($rootScope, $scope.singleAd.title, $scope.session.user.unread_conversations_count, Analytics);
      }, function(message) {
        $scope.isLoading = false;
        Alerts.add('danger', message);
      });
    
  }])

  .controller('SingleClassifiedController', ['$scope', '$rootScope', '$state', '$cookies', '$mdDialog', 'FileUploader', 'Alerts', 'ClassifiedAd', 'Conversations', function($scope, $rootScope, $state, $cookies, $mdDialog, FileUploader, Alerts, ClassifiedAd, Conversations) {
    $rootScope.setTitle(I18n.t('classified_ad.title'));
    $scope.isLoading = true;
    $scope.singleAd;
    $scope.updatingClassified = {};
    $scope.conversations = [];
    $scope.uploader = new FileUploader({ queueLimit: 1, alias: 'quotation', method: 'PATCH', removeAfterUpload: true});
    var adId = $state.params.adid;

    $scope.uploader.onAfterAddingFile = function(itemFile) {
      itemFile.url = $scope.uploader.url = '/api/v1/classified_ads/' + adId;
      itemFile.headers = $scope.uploader.headers = { 'X-XSRF-TOKEN': $cookies['XSRF-TOKEN'], 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') }
      itemFile.upload();
    };
    $scope.uploader.onSuccessItem = function(item, response) {
      $scope.singleAd = response.classified_ad;
      loadConversations();
    };
    $scope.uploader.onErrorItem = function(item, response) {
      Alerts.add('danger', I18n.t("classified_ad.quotation_file_sent_error"));
      console.log(response);
    };

    ClassifiedAd.getById(adId)
      .then(function(ad) {
        $scope.isLoading = false;
        $scope.singleAd = ad;
        $rootScope.setTitle($scope.singleAd.title);
      }, function(message) {
        $scope.isLoading = false;
        Alerts.add('danger', message);
      });

    var loadConversations = function() {
      Conversations.getByClassifiedId(adId)
        .then(function(conversations) {
          $scope.conversations = conversations;
        }, function(message) {
          Alerts.add('danger', message);
        });
    }

    $rootScope.$on('reloadConversations', function(event, args) {
      loadConversations();
    });

    loadConversations();
    
  }])

  .controller('SingleQuotationRequestController', ['$scope', '$rootScope', '$state', '$cookies', 'FileUploader', 'Alerts', 'QuotationRequest', 'Conversations', 'QuotationRequestTemplates', 'Professionals', function($scope, $rootScope, $state, $cookies, FileUploader, Alerts, QuotationRequest, Conversations, QuotationRequestTemplates, Professionals) {
    $rootScope.setTitle(I18n.t('quotation_request.title'));
    $scope.isLoading = true;
    $scope.singleQR;
    $scope.conversations = [];
    $scope.specificFields;
    $scope.uploader = new FileUploader({ queueLimit: 1, alias: 'quotation', method: 'PATCH', removeAfterUpload: true});
    var qrId = $state.params.qrid;

    $scope.uploader.onAfterAddingFile = function(itemFile) {
      itemFile.url = $scope.uploader.url = '/api/v1/quotation_requests/' + qrId;
      itemFile.headers = $scope.uploader.headers = { 'X-XSRF-TOKEN': $cookies['XSRF-TOKEN'], 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') }
      itemFile.upload();
    };
    $scope.uploader.onSuccessItem = function(item, response) {
      $scope.singleQR = response.outgoing_quotation_request;
      loadConversations($scope.singleQR.classified_ad_id);
    };
    $scope.uploader.onErrorItem = function(item, response) {
      Alerts.add('danger', I18n.t("classified_ad.quotation_file_sent_error"));
      console.log(response);
    };

    $scope.searchPros = function(query) {
      return Professionals.freeSearch(query, true, $scope.singleQR.template_id);
    };

    $scope.addProsToQuotationRequest = function() {
      if (!$scope.isSending) {
        $scope.isSending = true;
        var proIdsList = [];
        for (var i=0; i<$scope.addedPros.length; i++) {
          proIdsList.push($scope.addedPros[i].id);
        }
        QuotationRequest.addPros(qrId, proIdsList)
          .then(function() {
            $scope.isSending = false;
            $scope.addedPros = [];
            Alerts.add('success', I18n.t("quotation_request.quotation_request_sent"));
            loadConversations($scope.singleQR.classified_ad_id);
          }, function(message) {
            $scope.isSending = false;
            Alerts.add('danger', message);
          });
      }
      
    };

    var prepareFields = function() {
      $scope.specificFields = [];
      QuotationRequestTemplates.getTemplatebyId($scope.singleQR.template_id)
        .then(function(template) {
          var rawFields = angular.fromJson($scope.singleQR.specific_fields);
          angular.forEach( rawFields, function(value, key) {
            if (angular.isNumber(value) || value != "") {
              for (var i=0; i<template.fields.length; i++) {
                var el = template.fields[i];
                if (el.key == key) {
                  var displayData = value;
                  if (el.type == 'horizontalRadio') {
                    for (var j=0; j<el.templateOptions.options.length; j++) {
                      if (el.templateOptions.options[j].value == value) {
                        if (el.templateOptions.options[j].linkTo) {
                          var labelField = el.templateOptions.options[j].linkTo;
                          displayData = rawFields[labelField];
                        } else {
                          displayData = el.templateOptions.options[j].name;
                        }
                        break;
                      }
                    }
                  }
                  if (el.templateOptions.label != '') {
                    this.push({ label: el.templateOptions.label, data: displayData});
                  }
                  break;
                }
              }
            }
          }, $scope.specificFields);
          $scope.isLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoading = false;
        });
      
    };

    QuotationRequest.getById(qrId)
      .then(function(qr) {
        $scope.singleQR = qr;
        $rootScope.setTitle($scope.singleQR.title);
        prepareFields();
        loadConversations(qr.classified_ad_id);
      }, function(message) {
        $scope.isLoading = false;
        Alerts.add('danger', message);
      });

    var loadConversations = function(adId) {
      Conversations.getByClassifiedId(adId)
        .then(function(conversations) {
          $scope.conversations = conversations;
        }, function(message) {
          Alerts.add('danger', message);
        });
    };

    $rootScope.$on('reloadConversations', function(event, args) {
      if ($scope.singleQR) {
        loadConversations($scope.singleQR.classified_ad_id);
      }
    });

    // $scope.getPrestationLabel = function(prestationValue) {
    //   switch(prestationValue) {
    //     case 0:
    //       return I18n.t("quotation_request.prestation_label_0");
    //     case 1:
    //       return I18n.t("quotation_request.prestation_label_1");
    //     case 2:
    //       return I18n.t("quotation_request.prestation_label_2");
    //     default:
    //       return '';
    //   }
    // };

    // $scope.getBuildingTypeLabel = function(buildingType) {
    //   switch(buildingType) {
    //     case 'factory':
    //       return I18n.t("quotation_request.building_type.factory");
    //     case 'flat':
    //       return I18n.t("quotation_request.building_type.flat");
    //     case 'house':
    //       return I18n.t("quotation_request.building_type.house");
    //     case 'office':
    //       return I18n.t("quotation_request.building_type.office");
    //     default:
    //       return '';
    //   }
    // };
  }])

  .controller('DealManagerController', ['$scope', '$rootScope', '$uibModal', 'Alerts', 'Deal', function($scope, $rootScope, $uibModal, Alerts, Deal) {
    $rootScope.setTitle(I18n.t('favorites.title'));
    $scope.isLoading = true;
    $scope.myDeals = [];
    $scope.filter = { searchTerms: "", selectedFilter: "current" };

    var modalInstance;

    var loadDeals = function() {
      Deal.getMine()
        .then(function(deals) {
          $scope.myDeals = deals;
          $scope.isLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoading = false;
        });
    };

    $scope.deleteDeal = function(dealId) {
      modalInstance = $uibModal.open({
        templateUrl: 'modals/confirm-modal.html',
        controller: 'ConfirmModalController',
        resolve: {
          confirmTitle: function () {
            return I18n.t("deals.manager.delete_title");
          },
          confirmText: function () {
            return I18n.t("deals.manager.delete_text");
          },
          confirmLabel: function () {
            return I18n.t("deals.manager.delete_label");
          },
          cancelLabel: function () {
            return I18n.t("deals.manager.cancel_label");
          }
        }
      });
      modalInstance.result.then(function () {
        Deal.deleteDeal(dealId)
          .then(function(deal) {
            Alerts.add('success', I18n.t("deals.deal_deleted"));
            loadDeals();
          }, function(messages) {
            for (var i=0; i<messages.length; i++) {
              Alerts.add('danger', messages[i]);
            }
          });
      }, function () {
        // Cancelled
      });


    };

    loadDeals();
  }])
    
  .controller('FavoriteProfessionalsController', ['$scope', '$rootScope', 'Alerts', 'FavoriteProfessionals', function($scope, $rootScope, Alerts, FavoriteProfessionals) {
    $rootScope.setTitle(I18n.t('favorites.title'));
    $scope.isLoading = true;
    $scope.myFavorites = [];
    $scope.filter = { searchTerms: "" };

    FavoriteProfessionals.getMine()
      .then(function(pros) {
        $scope.myFavorites = pros;
        $scope.isLoading = false;
      }, function(message) {
        Alerts.add('danger', message);
        $scope.isLoading = false;
      });
  }])

  .controller('HowItWorksController', ['$scope', '$rootScope', '$window', '$document', '$timeout', function($scope, $rootScope, $window, $document, $timeout) {
    $rootScope.setTitle(I18n.t('how_it_works.title'));
    $scope.scrollToView = function() {
      $timeout( function() { 
        var openedAccordion = $(".panel.panel-open");
        $window.scroll(0, openedAccordion[0].offsetTop);
      },
      400);
    }
  }])

  .controller('HowItWorksProsController', ['$scope', '$rootScope', '$state', function($scope, $rootScope, $state) {
    $rootScope.setTitle(I18n.t('how_it_works.pros.title'));
    var states = ['how-it-works-pros.profile', 'how-it-works-pros.space', 'how-it-works-pros.classified_ads', 'how-it-works-pros.quotations', 'how-it-works-pros.deals', 'how-it-works-pros.visibility'];
    if ($state.current.name == 'how-it-works-pros') {
      $state.go('how-it-works-pros.profile');
    } else {
      $scope.selectedIndex = states.indexOf($state.current.name);
    }
  }])

  .controller('HowItWorksUsersController', ['$scope', '$rootScope', '$state', function($scope, $rootScope, $state) {
    $rootScope.setTitle(I18n.t('how_it_works.users.title'));
    var states = ['how-it-works-users.search', 'how-it-works-users.pros', 'how-it-works-users.quotations', 'how-it-works-users.classified_ads', 'how-it-works-users.deals', 'how-it-works-users.my-account'];
    if ($state.current.name == 'how-it-works-users') {
      $state.go('how-it-works-users.search');
    } else {
      $scope.selectedIndex = states.indexOf($state.current.name);
    }
  }])

  .controller('VisibilityController', ['$scope', '$rootScope', '$state', '$uibModal', 'Alerts', 'ProfileSponsoring', function($scope, $rootScope, $state, $uibModal, Alerts, ProfileSponsoring) {
    $rootScope.setTitle(I18n.t('visibility.title'));
    $scope.isIdeasCollapsed = false;
    $scope.isDifferentCollapsed = false;
    $scope.isDealsCollapsed = false;
    $scope.isTableCollapsed = false;

    var addProfileImpressions = function(target) {
      var modalInstance;
      modalInstance = $uibModal.open({
        templateUrl: 'modals/buy-profile-impressions-modal.html',
        controller: 'BuyProfileImpressionsModalController',
        resolve: {
          target: function () {
            return target;
          },
          userBalance: function() {
            return $scope.session.user.balance;
          }
        }
      });
      modalInstance.result.then(function (userIsPaying) {
        if (userIsPaying) {
          $scope["isLoading_" + target] = true;
          ProfileSponsoring.sponsorProfile(target)
            .then(function(sponsoring) {
              if (target == "sponsored_profile")
                $scope.session.user.profile_remaining_impressions = sponsoring.remaining_impressions;
              else
                $scope.session.user.profile_map_remaining_impressions = sponsoring.remaining_impressions;
              $scope.session.user.balance = sponsoring.balance;
              $scope["isLoading_" + target] = false;
              Alerts.add('success', I18n.t("visibility.impressions_added"));
            }, function(message) {
              Alerts.add('danger', message);
            });
        } else {
          $state.go("home.pro-credits");
        }
        
      }, function () {
        // Cancelled
      });
      
    }

    $scope.addImpressionsForMapProfile = function() {
      addProfileImpressions("sponsored_map_profile");
    };

    $scope.addImpressionsForProfile = function() {
      addProfileImpressions("sponsored_profile");
    };
  }])

  .controller('CreditsController', ['$scope', '$rootScope', '$document', '$timeout', '$stateParams', '$uibModal', 'Alerts', 'Transactions', 'Pricings', function($scope, $rootScope, $document, $timeout, $stateParams, $uibModal, Alerts, Transactions, Pricings) {
    $rootScope.setTitle(I18n.t('credits.title'));
    $scope.flechesAmount = 10;
    $scope.isSaving = false;
    $scope.isLoadingTransactions = true;
    $scope.isLoadingPricings = true;
    $scope.isCollapsed = true;
    $scope.isPricingTableCollapsed = true;
    $scope.transactions = [];
    $scope.forfaits = { forfait_1: null, forfait_2: null, forfait_3: null, forfait_4: null };
    $scope.isGeneratingInvoice = {};
    
    if ($stateParams.EXECCODE != null) {
      switch ($stateParams.EXECCODE) {
        case "0000":
          Alerts.add('success', I18n.t("credits.payment_succeeded"));
          break;
        default:
          Alerts.add('danger', I18n.t("credits.payment_failed"));
          break;
      }
    }

    Pricings.getFlechesPricings()
      .then(function(pricings) {
        for (var i=0; i<pricings.length; i++) {
          if (pricings[i].target == 'change_rate') {
            $scope.changeEuro = pricings[i].amount_cents;
            $scope.flechesAmount = $scope.changeCredits = pricings[i].credit_amount;
          } else {
            $scope.forfaits[pricings[i].target] = pricings[i];
          }
        }
        $scope.isLoadingPricings = false;
      }, function(message) {
        Alerts.add('danger', message);
      });

    Transactions.getTransactions()
      .then(function(transactions) {
        $scope.transactions = transactions;
        $scope.isLoadingTransactions = false;
      }, function(message) {
        Alerts.add('danger', message);
        $scope.isLoadingTransactions = false;
      });

    $scope.addCredits = function(target) {
      $uibModal.open({
        template: I18n.t("credits.redirection_message"),
        size: 'sm'
      });
      $scope.isSaving = true;
      var flechesToAdd;
      var eurosToPay;
      if (target == 'change_rate') {
        flechesToAdd = $scope.flechesAmount;
        eurosToPay = $scope.flechesAmount/$scope.changeCredits * $scope.changeEuro;
      } else {
        flechesToAdd = $scope.forfaits[target].credit_amount;
        eurosToPay = $scope.forfaits[target].amount_cents;
      }
      Transactions.addCredits( flechesToAdd, eurosToPay, target )
        .then(function(params) {
          $scope.payment = params;
          var form = document.getElementById('paymentForm');
          $timeout( function() { form.submit(); }, 100);
        }, function(messages) {
          $scope.isSaving =  false;
          for (var i=0; i<messages.length; i++) {
            Alerts.add('danger', messages[i]);
          }
        });
    };

    $scope.generateInvoice = function(transactionId) {
      $scope.isGeneratingInvoice[transactionId] = true;
      Transactions.getInvoice( transactionId )
        .then(function(transaction) {
          $scope.isGeneratingInvoice[transactionId] = false;
          for (var i = 0; i < $scope.transactions.length; i++) {
            if ($scope.transactions[i].id == transaction.id) {
              $scope.transactions[i] = transaction;
              break;
            }
          }
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isGeneratingInvoice[transactionId] = false;
        });
    };
  }])

  .controller('DealListController', ['$scope', '$rootScope', '$state', '$location', '$filter', '$uibModal', '$mdMedia', 'Alerts', 'Profession', 'Deal', 'Place', 'Tags', 'User', function($scope, $rootScope, $state, $location, $filter, $uibModal, $mdMedia, Alerts, Profession, Deal, Place, Tags, User){
    $rootScope.setTitle(I18n.t('deals.title'));
    $scope.isLoading = true;
    $scope.searchOptions = { place: null, profession: null, company: null, tags: [] };
    var center;
    var userInfoReady = false;
    var tagList;
    var professionIds = $state.params.pids;
    var companyNames = $state.params.ps;
    // var uid = $state.params.uid;
    // var pid = $state.params.pid;
    var lid = $state.params.lid;
    var previousParameters = { professionIds: null, companyNames: null, tagList: null, coordinates: null, sorting: null, rating: null };

    var setTagsFromParams = function(type, paramList) {
      if (angular.isArray(paramList)) {
        for (var i=0; i<paramList.length; i++) {
          $scope.searchOptions.tags.push({type: type, label: paramList[i]});
        }
      } else if (angular.isDefined(paramList)) {
        $scope.searchOptions.tags.push({type: type, label: paramList});
      }
    };

    var buildTagListFromOptions = function() {
      tagList = [];
      professionIds = [];
      companyNames = [];
      for (var i=0; i<$scope.searchOptions.tags.length; i++) {
        var currentTag = $scope.searchOptions.tags[i];
        switch (currentTag.type) {
          case "tag":
            tagList.push(currentTag.label);
            break;
          case "profession":
            professionIds.push(currentTag.id);
            break;
          case "user":
            companyNames.push(currentTag.id);
            break;
        } 
      }
    };

    setTagsFromParams("tag", $state.params.ts);
    setTagsFromParams("user", $state.params.ps);

    var initUserData = function() {
      if ($scope.searchOptions.place) {
        center = { latitude: $scope.searchOptions.place.latitude, longitude: $scope.searchOptions.place.longitude };
      } else {
        if ($scope.session.user.place != null) {
          $scope.searchOptions.place = $scope.session.user.place;
          lid = $scope.searchOptions.place.id;
          // $scope.citySearch = $scope.searchOptions.place.place_name;
          //var coord = $scope.session.user.place.geo_point_2d.split(', ');
          center = { latitude: $scope.session.user.place.latitude, longitude: $scope.session.user.place.longitude };
        } else if ($scope.session.user.addresses != null && $scope.session.user.addresses.length > 0) {
          center = { latitude: $scope.session.user.addresses[0].latitude, longitude: $scope.session.user.addresses[0].longitude};
        } else if ($scope.session.location) {
          center = { latitude: $scope.session.location.latitude, longitude: $scope.session.location.longitude};
        } else {
          return;
        }
      }
      // if ($state.params.uid) {
      //   User.searchProsById($state.params.uid)
      //     .then(function(user) {
      //       $scope.searchOptions.company = user;
      //       $scope.companySelectedHandler();
      //     }, function(message) {
      //       Alerts.add('danger', message);
      //     });
      // } else if ($state.params.pid) {
      //   Profession.getById($state.params.pid)
      //     .then(function(profession) {
      //       $scope.onProfessionChanged(profession);
      //     }, function(message) {
      //       Alerts.add('danger', message);
      //     });
      // } else {
      //   $scope.loadDeals();
      // }
      $scope.loadDeals();
      userInfoReady = true;
    };

    // $scope.professionSelectedHandler = function() {
    //   $scope.searchOptions.company = null;
    //   $scope.loadDeals();
    // };

    $scope.loadDeals = function() {
      $scope.isLoading = true;
      // var tagList = transformTagsIntoArray($scope.searchOptions.tags);
      // $location.search( 'ts', tagList );
      // $location.search( 'uid', uid );
      // $location.search( 'pid', pid );
      // $location.search( 'lid', lid );
      //$location.search( 'pid', $scope.searchOptions.profession ? $scope.searchOptions.profession.id : null );
      Deal.getAll({ lat: center.latitude, lng: center.longitude, "tags[]": tagList, "pid[]": professionIds, "uid[]": companyNames })
        .then(function(deals) {
          $scope.isLoading = false;
          $scope.deals = deals;
        }, function(message) {
          $scope.isLoading = false;
          Alerts.add('danger', message);
        });
      $scope.loadPromotedDeals();
    }

    $scope.loadPromotedDeals = function() {
      var maxDeals = 4;
      if ($mdMedia('xs')) {
        maxDeals = 1;
      } else if ($mdMedia('sm')) {
        maxDeals = 2;
      } else if ($mdMedia('md')) {
        maxDeals = 3;
      } else {
        maxDeals = 4;
      }
      Deal.getDealspagePromotions(center.latitude, center.longitude, professionIds, companyNames, tagList, maxDeals)
        .then(function(deals) {
          $scope.promotedDeals = deals;
        }, function(message) {
          Alerts.add('danger', message);
        });
    };

    // $scope.companySelectedHandler = function() {
    //   pid = $scope.searchOptions.profession = null;
    //   uid = ($scope.searchOptions.company ? $scope.searchOptions.company.id : null);
    //   $scope.loadDeals();
    // };

    // $scope.removeCompany = function() {
    //   uid = $scope.searchOptions.company = null;
    //   $scope.loadDeals();
    // }

    $scope.searchCities = function(query) {
      return Place.searchCities(query);
    };

    // $scope.searchTags = function(query) {
    //   return Tags.search(query);
    // };

    // $scope.searchCompanies = function(query) {
    //   return User.searchProsByName(query);
    // };

    // $scope.selectAllProfessions = function() {
    //   pid = $scope.searchOptions.profession = null;
    //   $scope.loadDeals();
    // };

    $scope.updateCenter = function(item, model, index) {
      lid = model.id;
      center = { latitude: item.latitude, longitude: item.longitude };
      $location.search( 'lid', lid );
      $scope.loadDeals();
      // $scope.mapControl.getGMap().setCenter( new google.maps.LatLng( item.latitude, item.longitude ) );
    };

    $scope.searchDeals = function() {
      buildTagListFromOptions();
      $location.search( {ts: tagList, pids: professionIds, ps: companyNames}  );
      $scope.loadDeals();
    };

    $scope.searchAll = function(query) {
      var searchResults = Tags.extendedSearch(query);
      searchResults.then( function(res) {
        $scope.hasResults = (res && res.length>0);
      }, function(message) {
        $scope.hasResults = false;
      });
      return searchResults;
    };

    // $scope.onProfessionChanged = function(profession) {
    //   $scope.searchOptions.profession = profession;
    //   uid = $scope.searchOptions.company = null;
    //   pid = $scope.searchOptions.profession ? $scope.searchOptions.profession.id : null;
    //   $scope.loadDeals();
    // }

    initUserData();
    
    $rootScope.$on('location-found', function(event, args) {
      if (!$scope.session.connected && !userInfoReady) {
        initUserData();
      }
    });
    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });

  }])

  .controller('SingleDealController', ['$scope', '$rootScope', '$state', '$filter', '$location', '$document', 'Alerts', 'Profession', 'Deal', 'FavoriteDeals', function($scope, $rootScope, $state, $filter, $location, $document, Alerts, Profession, Deal, FavoriteDeals){
    $rootScope.setTitle(I18n.t('deals.title'));
    $scope.isLoading = true;

    var dealId = $state.params.dealid;
    var center;
    var userInfoReady = false;

    var setSharingContent = function(){
      // $scope.safeUrl = encodeURIComponent(this.urlToShare + this.urlHash);
      $scope.safeUrl = encodeURIComponent($location.absUrl());
      $scope.safeTitle = encodeURIComponent($scope.singleDeal.tagline);
    }

    var initUserData = function() {
      if ($scope.session.user.place != null) {
        center = { latitude: $scope.session.user.place.latitude, longitude: $scope.session.user.place.longitude };
      } else if ($scope.session.user.addresses != null && $scope.session.user.addresses.length > 0) {
        center = { latitude: $scope.session.user.addresses[0].latitude, longitude: $scope.session.user.addresses[0].longitude};
      } else if ($scope.session.location) {
        center = { latitude: $scope.session.location.latitude, longitude: $scope.session.location.longitude};
      } else {
        return;
      }
      userInfoReady = true;
      Deal.getSimilarPromotions(center.latitude, center.longitude, dealId)
        .then(function(deals) {
          $scope.similarDeals = deals;
        }, function(message) {
          Alerts.add('danger', message);
        });
    };

    $scope.addToFavorites = function() {
      $scope.adding_to_favorites = true;
      FavoriteDeals.addToFavorites($scope.singleDeal.id)
        .then(function(favorite_deal_id) {
          $scope.adding_to_favorites = false;
          $scope.singleDeal.favorited = true;
          $scope.singleDeal.favorite_deal_id = favorite_deal_id;
          $scope.singleDeal.num_of_favorited++;
          Alerts.add('success', I18n.t("deals.favorited"));
        }, function(message) {
          Alerts.add('danger', message);
          $scope.adding_to_favorites = false;
        });
    }

    $scope.removeFromFavorites = function() {
      $scope.adding_to_favorites = true;
      FavoriteDeals.removeFromFavorites($scope.singleDeal.favorite_deal_id)
        .then(function() {
          $scope.adding_to_favorites = false;
          $scope.singleDeal.favorited = false;
          $scope.singleDeal.num_of_favorited--;
          Alerts.add('success', I18n.t("deals.unfavorited"));
        }, function(message) {
          Alerts.add('danger', message);
          $scope.adding_to_favorites = false;
        });
    };

    Deal.getById(dealId)
      .then(function(deal) {
        $scope.isLoading = false;
        $scope.singleDeal = deal;
        $rootScope.setTitle(deal.tagline);
        setSharingContent();
        loadProDeals(deal.professional_id);
      }, function(message) {
        $scope.isLoading = false;
        Alerts.add('danger', message);
      });

    var loadProDeals = function(proId) {
      Deal.getFromPro(proId)
        .then(function(deals) {
          $scope.ownerDeals = deals;
        }, function(message) {
          Alerts.add('danger', message);
        });
    };

    initUserData();
    
    $rootScope.$on('location-found', function(event, args) {
      if (!$scope.session.connected && !userInfoReady) {
        initUserData();
      }
    });
    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });

  }])

  .controller('PostClassifiedController', ['$scope', '$rootScope', '$state', '$filter', '$cookies', 'FileUploader', 'Alerts', 'Profession', 'Place', 'ClassifiedAd', function($scope, $rootScope, $state, $filter, $cookies, FileUploader, Alerts, Profession, Place, ClassifiedAd){
    $rootScope.setTitle(I18n.t('classified_ad.post.title'));
    var photoIdsToRemove = [];
    var cladId = $state.params.adid;
    if (cladId) {
      $scope.mode = "edit";
    } else {
      $scope.mode = "create";
    }
    $scope.noProfessionAdded = false;
    $scope.photoUploader = new FileUploader( { queueLimit: 10, method: 'PATCH', alias: 'photo', removeAfterUpload: true } );
    $scope.photoUploader.filters.push({
        name: 'imageFilter',
        fn: function(item /*{File|FileLikeObject}*/, options) {
            var type = '|' + item.type.slice(item.type.lastIndexOf('/') + 1) + '|';
            return '|jpg|png|jpeg|bmp|gif|'.indexOf(type) !== -1;
        }
    });
    $scope.isPosting = false;
    $scope.citySearch = null;
    $scope.newAd = { title: "", description: "", professions: [], place: null };
    var now = new Date();
    $scope.minDate = now;

    var uploadOnSuccess = function() {
      $scope.isPosting = false;
      $state.go('home.users-dashboard');
      Alerts.add('success', I18n.t("classified_ad.classified_ad_published"));
    }

    $scope.photoUploader.onBeforeUploadItem = function(itemFile) {
      itemFile.url = $scope.photoUploader.url = '/api/v1/classified_ads/' + cladId;
      itemFile.headers = $scope.photoUploader.headers = { 'X-XSRF-TOKEN': $cookies['XSRF-TOKEN'], 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') };
    };

    $scope.photoUploader.onCompleteAll = function() {
      uploadOnSuccess();
    };

    $scope.removePhoto = function(item) {
      item.remove();
    }

    $scope.deletePhoto = function(photo) {
      photoIdsToRemove.push(photo.id);
      $scope.newAd.classified_ad_photos.splice($scope.newAd.classified_ad_photos.indexOf(photo), 1);
    }

    var initUserData = function() {
      if ($scope.mode == "edit") {
        $scope.isLoading = true;
        ClassifiedAd.getById(cladId)
          .then(function(ad) {
            $scope.isLoading = false;
            $scope.newAd = ad;
            $scope.newAd.start_date = new Date(ad.start_date);
          }, function(message) {
            $scope.isLoading = false;
            Alerts.add('danger', message);
          });
      } else if ($scope.session.user.place != null) {
        $scope.newAd.place = $scope.session.user.place;
        if ($scope.newAd.place != null)
          $scope.citySearch = $scope.newAd.place.place_name;
      }
    }
    if ($scope.session.connected) {
      initUserData();
    }
    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });

    $scope.postClassified = function() {
      if ($scope.newAd.professions.length > 0) {
        $scope.isPosting = true;
        var profession_ids = [];
        for (var i=0; i<$scope.newAd.professions.length; i++) {
          profession_ids.push($scope.newAd.professions[i].id);
        }
        if ($scope.mode == "create") {
          ClassifiedAd.postAd( { title: $scope.newAd.title, description: $scope.newAd.description, profession_ids: profession_ids, start_date: $scope.newAd.startDate ? $scope.newAd.startDate.toISOString() : null, place_id: $scope.newAd.place.id })
            .then(function(classifiedAdId) {
              cladId = classifiedAdId;
              if ($scope.photoUploader.queue.length > 0) {
                $scope.photoUploader.uploadAll();
              } else {
                uploadOnSuccess();
              }
            }, function(messages) {
              $scope.isPosting =  false;
              for (var i=0; i<messages.length; i++) {
                Alerts.add('danger', messages[i]);
              }
            });
        } else {
          ClassifiedAd.update( { id: cladId, title: $scope.newAd.title, description: $scope.newAd.description, profession_ids: profession_ids, start_date: $scope.newAd.startDate ? $scope.newAd.startDate.toISOString() : null, place_id: $scope.newAd.place.id, photo_ids_to_remove: photoIdsToRemove })
            .then(function(classifiedAdId) {
              if ($scope.photoUploader.queue.length > 0) {
                $scope.photoUploader.uploadAll();
              } else {
                uploadOnSuccess();
              }
            }, function(messages) {
              $scope.isPosting =  false;
              for (var i=0; i<messages.length; i++) {
                Alerts.add('danger', messages[i]);
              }
            });
        }
        
      } else {
        $scope.noProfessionAdded = true;
      }
      
    };

    $scope.onTagAdded = function() {
      $scope.noProfessionAdded = false;
    };

    $scope.searchCities = function(query) {
      return Place.searchCities(query);
    };

    $scope.searchProfessions = function(query) {
      var result = [];
      for (var i=0; i<$scope.professions.length; i++) {
        result = result.concat($filter('filter')($scope.professions[i].children, {name: query}));
      }
      return result;
    };

    Profession.getData()
      .then(function(professions) {
        $scope.professions = professions;
      }, function(message) {
        Alerts.add('danger', message);
      });
  }])

  .controller('PostQuotationRequestController', ['$scope', '$rootScope', '$state', '$filter', 'Alerts', 'Professionals', 'Place', 'QuotationRequest', 'QuotationRequestTemplates', function($scope, $rootScope, $state, $filter, Alerts, Professionals, Place, QuotationRequest, QuotationRequestTemplates){
    $rootScope.setTitle(I18n.t('quotation_request.title'));
    $scope.isPosting = false;
    $scope.isLoading = true;
    $scope.citySearch = null;
    $scope.addedPros = [];
    // $scope.newQuotation = { title: "", description: "", startDate: null, place: null, building_type: "flat", other_building_type: "", prestation: 0, surface_description: "", options: "", public: true };
    var now = new Date();
    var professionalId = $state.params.pid;
    // $scope.qrFields = QuotationRequestTemplates.getTemplate('t0').fields;

    var initUserData = function() {
      if ($scope.session.user.place != null) {
        $scope.newQuotation.place = $scope.session.user.place;
        if ($scope.newQuotation.place != null)
          $scope.citySearch = $scope.newQuotation.place.place_name;
      }
    }

    $rootScope.$on('user-loaded', function(event, args) {
      if ($scope.newQuotation) {
        initUserData();
      }
    });

    $scope.searchPros = function(query) {
      return Professionals.freeSearch(query, true, $scope.professional.qr_template_id);
    };

    $scope.postQuotationRequest = function() {
      $scope.isPosting = true;
      var modelToSend = {professional_id: professionalId, added_pros: $scope.addedPros };
      var specificFields = {};
      angular.forEach( $scope.newQuotation, function(value, key) {
        switch(key) {
          case 'title':
            this.title = value;
            break;
          case 'description':
            this.description = value;
            break;
          case 'startDate':
            this.start_date = value;
            break;
          case 'place':
            this.place_id = value.id;
            break;
          case 'public':
            this.public = value;
            break;
          default:
            specificFields[key] = value;
            break;
        }
      }, modelToSend);
      modelToSend.specific_fields = angular.toJson(specificFields);
      QuotationRequest.postQuotationRequest( modelToSend )
        .then(function() {
          $scope.isPosting = false;
          $state.go('home.users-dashboard');
          Alerts.add('success', I18n.t("quotation_request.quotation_request_sent"));
        }, function(messages) {
          $scope.isPosting =  false;
          for (var i=0; i<messages.length; i++) {
            Alerts.add('danger', messages[i]);
          }
        });
    };

    var loadTemplate = function() {
      QuotationRequestTemplates.getTemplatebyId($scope.professional.qr_template_id)
        .then(function(template) {
          $scope.qrFields = template.fields;
          $scope.newQuotation = template.model;
          if ($scope.session.connected) {
            initUserData();
          }
          $scope.isLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoading = false;
        });
    };

    Professionals.getById(professionalId)
      .then(function(professional) {
        $scope.professional = professional;
        loadTemplate();
      }, function(message) {
        Alerts.add('danger', message);
          $scope.isLoading = false;
      });

    // $scope.searchProfessions = function(query) {
    //   var result = [];
    //   for (var i=0; i<$scope.professions.length; i++) {
    //     result = result.concat($filter('filter')($scope.professions[i].children, {name: query}));
    //   }
    //   return result;
    // };

    // Profession.getData()
    //   .then(function(professions) {
    //     $scope.professions = professions;
    //   }, function(message) {
    //     Alerts.add('danger', message);
    //   });
  }])


  .controller('ProfessionalsController', ['$scope', '$rootScope', '$state', '$location', '$filter', '$timeout', '$mdMedia', 'Alerts', 'Profession', 'Place', 'Professionals', 'Tags', 'uiGmapIsReady', 'Deal', 'ProfileSponsoring', 'Analytics', function($scope, $rootScope, $state, $location, $filter, $timeout, $mdMedia, Alerts, Profession, Place, Professionals, Tags, uiGmapIsReady, Deal, ProfileSponsoring, Analytics){
    $rootScope.setTitle(I18n.t('pro_listing.title'));
    $scope.searchOptions = { place: null, sorting: 'distance', tags: [], updateWithMap: true, selectedProfessionalId: null, rating: 0 };
    // $scope.mapWindowOptions = { visible: false };
    $scope.isLoading = false;
    $scope.isInitializing = true;
    $scope.mapControl = {};
    $scope.highlightedMarker = { id: 'fshdkjewu382798675f6sdtfg3ev3wiqyd', options: {icon: "marker-hover.png", visible: false, zIndex: 10000}};
    $scope.professionals = [];
    $scope.enabledMarkers = [];
    $scope.stars = [1,2,3,4,5];
    var bounds;
    var tagList;
    var professionIds = $state.params.pids;
    var companyNames = $state.params.ps;
    var center;
    var userInfoReady = false;
    var mapReady = false;
    var previousParameters = { professionIds: null, companyNames: null, tagList: null, coordinates: null, sorting: null, rating: null };
    

    var setTagsFromParams = function(type, paramList) {
      if (angular.isArray(paramList)) {
        for (var i=0; i<paramList.length; i++) {
          $scope.searchOptions.tags.push({type: type, label: paramList[i]});
        }
      } else if (angular.isDefined(paramList)) {
        $scope.searchOptions.tags.push({type: type, label: paramList});
      }
    };

    var buildTagListFromOptions = function() {
      tagList = [];
      professionIds = [];
      companyNames = [];
      for (var i=0; i<$scope.searchOptions.tags.length; i++) {
        var currentTag = $scope.searchOptions.tags[i];
        switch (currentTag.type) {
          case "tag":
            tagList.push(currentTag.label);
            break;
          case "profession":
            professionIds.push(currentTag.id);
            break;
          case "user":
            companyNames.push(currentTag.label);
            break;
        } 
      }
    };

    setTagsFromParams("tag", $state.params.ts);
    setTagsFromParams("user", $state.params.ps);

    Profession.getData()
      .then(function(professions) {
        $scope.professions = professions;
        var result;
        if (angular.isArray(professionIds)) {
          for (var i=0; i<professionIds.length; i++) {
            for (var j=0; j<professions.length; j++) {
              result = $filter('filter')(professions[j].children, function(value, index, array) { return (value.id == professionIds[i]); }, true);
              if (result.length > 0) {
                $scope.searchOptions.tags.push({id: professionIds[i], type: "profession", label: result[0].name });
              }
            }
          }
        } else if (angular.isDefined(professionIds)) {
          for (var j=0; j<professions.length; j++) {
            result = $filter('filter')(professions[j].children, function(value, index, array) { return (value.id == professionIds); }, true);
            if (result.length > 0) {
              $scope.searchOptions.tags.push({id: professionIds, type: "profession", label: result[0].name });
            }
          }
        }
        buildTagListFromOptions();
      }, function(message) {
        Alerts.add('danger', message);
      });

    var setActivities = function(pro) {
      if ($scope.professions != null && pro) {
        pro.activities = getActivitiesForPro(pro, $scope.professions, $filter);
      }
    };

    var loadMapSponsoredProfiles = function(ids) {
      ProfileSponsoring.getMapSponsoredProfiles(ids)
        .then(function(profiles) {
          $scope.enabledMarkers = [];
          for (var i=0; i<$scope.professionals.length; i++) {
            var isSponsored = profiles.indexOf($scope.professionals[i].id) >= 0;
            $scope.professionals[i].windowOptions.disableAutoPan = isSponsored;
            if (isSponsored) {
              $scope.enabledMarkers.push($scope.professionals[i]);
            }
          }
        }, function(message) {
          Alerts.add('danger', message);
        });
    };

    var loadProfessionals = function() {
      $scope.isLoading = true;
      bounds = $scope.mapControl.getGMap().getBounds();
      var ne = bounds.getNorthEast();
      var sw = bounds.getSouthWest();
      $scope.searchOptions.selectedProfessionalId = null;
      if (previousParameters.professionIds != professionIds || previousParameters.companyNames != companyNames ||previousParameters.tagList != tagList || previousParameters.coordinates != { lat: center.latitude, lng: center.longitude } || previousParameters.sorting != $scope.searchOptions.sorting || previousParameters.rating != $scope.searchOptions.rating) {
        Professionals.search(professionIds, companyNames, tagList, { lat: center.latitude, lng: center.longitude }, $scope.searchOptions.sorting, $scope.searchOptions.rating)
          .then(function(professionals) {
            previousParameters = { professionIds: professionIds, companyNames: companyNames, tagList: tagList, coordinates: { lat: center.latitude, lng: center.longitude }, sorting: $scope.searchOptions.sorting, rating: $scope.searchOptions.rating }
            var professionalIds = [];
            $scope.enabledMarkers = [];
            for (var i=0; i<professionals.length; i++) {
              var shortestDistance = 10000000;
              var shortestAddress;
              professionalIds.push(professionals[i].id);
              professionals[i].stars = [];
              for (var j=0; j<5; j++) {
                professionals[i].stars.push(professionals[i].rating > j ? 'on' : 'off');
              }
              professionals[i].mapOptions = {icon: 'marker.png', optimized: true};
              professionals[i].windowOptions = {visible: true};
              setActivities(professionals[i]);
              // professionals[i].formattedDescription = $rootScope.replaceNewLinesInText(professionals[i].short_description);
              for (var j=0; j<professionals[i].addresses.length; j++) {
                // if (bounds.contains(new google.maps.LatLng(professionals[i].addresses[j].latitude, professionals[i].addresses[j].longitude))) {
                  var currentDistance = google.maps.geometry.spherical.computeDistanceBetween($scope.mapControl.getGMap().getCenter(), new google.maps.LatLng(professionals[i].addresses[j].latitude, professionals[i].addresses[j].longitude));
                  if (currentDistance < shortestDistance) {
                    shortestDistance = currentDistance;
                    shortestAddress = professionals[i].addresses[j];
                  }
                // }
              }
              if (shortestAddress) {
                professionals[i].latitude = shortestAddress.latitude;
                professionals[i].longitude = shortestAddress.longitude;
              }
            }
            $scope.isLoading = false;
            $scope.isInitializing = false;
            $scope.professionals = professionals;
            if (professionalIds.length > 0)
              loadMapSponsoredProfiles(professionalIds);
          }, function(message) {
            $scope.isLoading = false;
            Alerts.add('danger', message);
          });
        $scope.loadPromotedDeals();
      }
      
    };

    $scope.loadPromotedDeals = function() {
      if ($mdMedia('gt-md')) {
        Deal.getMapPromotions(center.latitude, center.longitude, professionIds, companyNames, tagList)
          .then(function(deals) {
            $scope.promotedDeals = deals;
          }, function(message) {
            Alerts.add('danger', message);
          });
      }
    };

    var initUserData = function() {
      if ($scope.session.user.place != null) {
        $scope.searchOptions.place = $scope.session.user.place;
        $scope.citySearch = $scope.searchOptions.place.place_name;
        //var coord = $scope.session.user.place.geo_point_2d.split(', ');
        center = { latitude: $scope.session.user.place.latitude, longitude: $scope.session.user.place.longitude };
      } else if ($scope.session.user.addresses != null && $scope.session.user.addresses.length > 0) {
        center = { latitude: $scope.session.user.addresses[0].latitude, longitude: $scope.session.user.addresses[0].longitude};
      } else if ($scope.session.location) {
        center = { latitude: $scope.session.location.latitude, longitude: $scope.session.location.longitude};
      } else {
        return;
      }
      userInfoReady = true;
      $scope.mapOptions = { center: center, zoom: 12, dragging: false };
      if (mapReady && !$scope.isLoading) {
        loadProfessionals();
      }
    };

    var refreshMap = function() {
      mapReady = true;
      $scope.mapControl.refresh({latitude: center.latitude, longitude: center.longitude});
      if (userInfoReady && !$scope.isLoading) {
        loadProfessionals();
      }
    }

    uiGmapIsReady.promise(1).then(function(instances) {
      $scope.gmapOptions = { panControl: false, streetViewControl: false, zoomControlOptions: { position: google.maps.ControlPosition.LEFT_BOTTOM}, mapTypeControlOptions: { position: google.maps.ControlPosition.RIGHT_BOTTOM } };
      $timeout( refreshMap, 100);
      // if (userInfoReady && !$scope.isLoading) {
      //   console.log("Load in map reqdy");
      //   loadProfessionals();
      // }

      // instances.forEach(function(inst) {
      //     var map = inst.map;
      //     var uuid = map.uiGmap_id;
      //     var mapInstanceNumber = inst.instance; // Starts at 1.
      // });
    });

    // $scope.$root.showPro = function(pro) {
    //   console.log(pro);
    //   $state.go('pro', {pid: pro.prettyName});
    // };

    $scope.resetRating = function() {
      $scope.searchOptions.rating = 0;
      loadProfessionals();
    }

    $scope.highlightMarker = function(professional) {
      $scope.highlightedMarker.coords = {latitude: professional.latitude, longitude: professional.longitude };
      $scope.highlightedMarker.options.visible = true;
    };

    $scope.unlightMarker = function(professional) {
      $scope.highlightedMarker.options.visible = false;
    };

    $scope.updateCenter = function(item, model, index) {
      $scope.mapControl.getGMap().setCenter( new google.maps.LatLng( item.latitude, item.longitude ) );
    };

    $scope.markerClickHandler = function(marker, name, model, args) {
      var originalUpdateWithMap = $scope.searchOptions.updateWithMap;
      $scope.searchOptions.updateWithMap = false;
      $scope.enabledMarkers.push(model);
      $scope.searchOptions.selectedProfessionalId = model.id;
      $scope.mapControl.getGMap().setCenter(marker.getPosition());
      $scope.mapControl.getGMap().panBy(0, -30);
      // $scope.mapWindowOptions.visible = true;
      $scope.$apply();
      $timeout( function() {$scope.searchOptions.updateWithMap = originalUpdateWithMap;}, 1000);
    };

    $scope.windowCloseHandler = function(marker, eventName, model) {
      $scope.enabledMarkers.splice($scope.enabledMarkers.indexOf(marker.templateParameter), 1);
      if ($scope.searchOptions.selectedProfessionalId == marker.templateParameter.id) {
        $scope.searchOptions.selectedProfessionalId = null;
      }
    }

    $scope.boundsChangedHandler = function() {
      if (mapReady && !$scope.mapOptions.dragging && $scope.searchOptions.updateWithMap) {
        var newCenter = $scope.mapControl.getGMap().getCenter();
        center.latitude = newCenter.lat();
        center.longitude = newCenter.lng();
        $scope.searchPros();
      }
    };

    $scope.draggingStoppedHandler = function() {
      if (mapReady && $scope.searchOptions.updateWithMap) {
        $scope.searchOptions.place = null;
        $scope.searchPros();
      }
    };

    $scope.updateWithMapChanged = function() {
      if (mapReady && $scope.searchOptions.updateWithMap) {
        $scope.searchPros();
      }
    }

    $scope.searchPros = function() {
      buildTagListFromOptions();
      $location.search( {ts: tagList, pids: professionIds, ps: companyNames}  );
      loadProfessionals();
    };

    $scope.searchCities = function(query) {
      return Place.searchCities(query);
    };

    // $scope.searchTags = function(query) {
    //   return Tags.search(query);
    // };

    $scope.searchAll = function(query) {
      var searchResults = Tags.extendedSearch(query);
      searchResults.then( function(res) {
        $scope.hasResults = (res && res.length>0);
      }, function(message) {
        $scope.hasResults = false;
      });
      return searchResults;
    };

    $scope.toggleMapMenu = function() {
      $rootScope.menuClass = 'menu-for-map opened';
    };

    initUserData();
    // if ($scope.session.connected && $scope.session.user) {
    //   initUserData();
    // }
    $rootScope.$on('location-found', function(event, args) {
      if (!$scope.session.connected && !userInfoReady) {
        initUserData();
      }
    });
    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });

  }])
  ;
