'use strict';

/**
 * Converts data uri to Blob. Necessary for uploading.
 * @see
 *   http://stackoverflow.com/questions/4998908/convert-data-uri-to-file-then-append-to-formdata
 * @param  {String} dataURI
 * @return {Blob}
 */
var dataURItoBlob = function(dataURI) {
  var binary = atob(dataURI.split(',')[1]);
  var mimeString = dataURI.split(',')[0].split(':')[1].split(';')[0];
  var array = [];
  for(var i = 0; i < binary.length; i++) {
    array.push(binary.charCodeAt(i));
  }
  return new Blob([new Uint8Array(array)], {type: mimeString});
};

angular.module('uneo.directives', [])
  .directive('stickyBar', ['$window', function($window) {
    return {
      restrict: 'C',
      link: function (scope, element, attrs) {
        scope.stickyReduced = false;
        angular.element($window).bind("scroll", function() {
          scope.stickyReduced = this.pageYOffset >= 50;
        });
      }
    }
  }])

  .directive('avatar', [function() {
    return {
      restrict: 'EA',
      scope: {
        avatarUrl: '='
      },
      replace: true,
      templateUrl: 'directives/avatar.html'
    }
  }])

  .directive('notConnectedInfo', [function() {
    return {
      restrict: 'EA',
      replace: true,
      templateUrl: 'directives/not-connected-info.html'
    }
  }])

  .directive('profileNotCompleteInfo', [function() {
    return {
      restrict: 'EA',
      replace: true,
      templateUrl: 'directives/profile-not-complete-info.html'
    }
  }])

  .directive('searchBox', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        ngModel: '='
      },
      templateUrl: 'directives/search-box.html'
    }
  }])

  .directive('professionVerticalList', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        selectedCategory: '='
      },
      templateUrl: 'directives/profession-vertical-list.html',
      controller: [ '$scope', '$uibModal', '$state', '$mdSidenav', function($scope, $uibModal, $state, $mdSidenav) {
        $scope.professionPage = 1;
        $scope.returnToRoot = function() {
          $scope.selectedCategory = null;
          $scope.professionPage = 1;
        };

        $scope.professionSelectHandler = function(profession) {
          $scope.selectedCategory = null;
          $mdSidenav('professionSidenav').close();
          $state.go('pros-list', {pids: profession.id}, { reload: true });
          $scope.professionPage = 1;
        };

      }]
    }
  }])

  .directive('professionSearchBox', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        appendTypeAheadToBody: '=',
        direction: '=',
        selectedCategory: '=?',
        showModal: '='
      },
      templateUrl: 'directives/profession-search-box.html',
      controller: [ '$scope', '$uibModal', '$filter', '$state', '$mdSidenav', 'Profession', 'Tags', 'Alerts', function($scope, $uibModal, $filter, $state, $mdSidenav, Profession, Tags, Alerts) {
        var searchResults;
        $scope.hasResults = true;
        $scope.searchOptions = { tags: null };
        var cleanBeforeGoingOut = function() {
          $scope.searchOptions.tags = null;
          searchResults = null;
          angular.element('.search-button').focus();
          $mdSidenav('professionSidenav').close();
        }
        $scope.professionSelectHandler = function(profession) {
          if ($scope.showModal) {
            showProfessionSelectModal(profession, $scope.professions, $uibModal, $state);
          } else {
            $scope.selectedCategory = profession;
          }
          
        };
        $scope.searchTags = function(query) {
          searchResults = Tags.extendedSearch(query);
          searchResults.then( function(res) {
            $scope.hasResults = (res && res.length>0);
          }, function(message) {
            $scope.hasResults = false;
          });
          return searchResults;
        };
        $scope.searchPros = function(item, model, label) {
          cleanBeforeGoingOut();
          switch(item.type) {
            case 'profession':
              $state.go('pros-list', {pids: [item.id], ps: null, ts: null}, {reload: true});
              break;
            case 'user':
              $state.go('pros-list', {ps: [label], ts: null, pids: null}, {reload: true});
              break;
            case 'tag':
              $state.go('pros-list', {ts: [label], ps: null, pids: null}, {reload: true});
              break;
          }
        };
        Profession.getData()
          .then(function(professions) {
            $scope.professions = professions;
          }, function(message) {
            Alerts.add('danger', message);
          });

        $scope.searchPressed = function(event) {
          if (event == null || event.keyCode == 13) {
            searchResults.then( function(res) {
              if (res && res.length>0) {
                var pros = [];
                var cnames= [];
                var tags= [];
                for (var i=0; i<res.length; i++) {
                  switch(res[i].type) {
                    case 'profession':
                      pros.push(res[i].id);
                      break;
                    case 'user':
                      cnames.push(res[i].label);
                      break;
                    case 'tag':
                      tags.push(res[i].label);
                      break;
                  }
                }
                cleanBeforeGoingOut();
                $state.go('pros-list', {pids: pros, ps: cnames, ts: tags}, {reload: true});
              }
            }, function(message) {
              console.log(message);
            });
          }
        };
      }]
    }
  }])

  .directive('professionSearchBoxHome', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        appendTypeAheadToBody: '=',
        direction: '=',
        selectedCategory: '='
      },
      templateUrl: 'directives/profession-search-box-home.html',
      controller: [ '$rootScope', '$scope', '$uibModal', '$filter', '$state', '$anchorScroll', '$mdSidenav', '$mdMedia', 'Profession', 'Tags', 'Alerts', function($rootScope, $scope, $uibModal, $filter, $state, $anchorScroll, $mdSidenav, $mdMedia, Profession, Tags, Alerts) {
        var searchResults;
        $scope.hasResults = true;
        $scope.searchOptions = { tags: null };
        var cleanBeforeGoingOut = function() {
          $scope.searchOptions.tags = null;
          searchResults = null;
          angular.element('.search-button').focus();
          $mdSidenav('professionSidenav').close();
        }
        $scope.professionSelectHandler = function(profession) {
          if ($mdMedia('gt-md')) {
            showProfessionSelectModal(profession, $scope.professions, $uibModal, $state);
          } else {
            $anchorScroll(0);
            $mdSidenav('professionSidenav').toggle();
            $rootScope.$broadcast('professionSelected', profession);
          }
          
        };
        $scope.searchTags = function(query) {
          searchResults = Tags.extendedSearch(query);
          searchResults.then( function(res) {
            $scope.hasResults = (res && res.length>0);
          }, function(message) {
            $scope.hasResults = false;
          });
          return searchResults;
        };
        $scope.searchPros = function(item, model, label) {
          cleanBeforeGoingOut();
          switch(item.type) {
            case 'profession':
              $state.go('pros-list', {pids: [item.id], ps: null, ts: null}, {reload: true});
              break;
            case 'user':
              $state.go('pros-list', {ps: [label], ts: null, pids: null}, {reload: true});
              break;
            case 'tag':
              $state.go('pros-list', {ts: [label], ps: null, pids: null}, {reload: true});
              break;
          }
        };
        Profession.getData()
          .then(function(professions) {
            $scope.professions = professions;
          }, function(message) {
            Alerts.add('danger', message);
          });

        $scope.searchPressed = function(event) {
          if (event == null || event.keyCode == 13) {
            searchResults.then( function(res) {
              if (res && res.length>0) {
                var pros = [];
                var cnames= [];
                var tags= [];
                for (var i=0; i<res.length; i++) {
                  switch(res[i].type) {
                    case 'profession':
                      pros.push(res[i].id);
                      break;
                    case 'user':
                      cnames.push(res[i].label);
                      break;
                    case 'tag':
                      tags.push(res[i].label);
                      break;
                  }
                }
                cleanBeforeGoingOut();
                $state.go('pros-list', {pids: pros, ps: cnames, ts: tags}, {reload: true});
              }
            }, function(message) {
              console.log(message);
            });
          }
        };
      }]
    }
  }])

  .directive('postCategorySelectionButton', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        categoryId: '=',
        selectionCallback: '=',
        buttonClasses: '=',
        defaultLabel: '='
      },
      templateUrl: 'directives/post-category-selection-button.html',
      controller: [ '$scope', '$uibModal', '$filter', 'PostCategory', 'Alerts', function($scope, $uibModal, $filter, PostCategory, Alerts) {
        var setCategoryFromId = function(pid, triggerCallback) {
          if ($scope.categories) {
            for (var i=0; i<$scope.categories.length; i++) {
              var selected = $filter('filter')($scope.categories[i].children, {id: parseInt(pid)}, true);
              if (selected.length > 0) {
                $scope.category = selected[0];
                if (triggerCallback)
                  $scope.selectionCallback($scope.category);
                break;
              }
            }
          }
        }
        $scope.$watch('categoryId', function(newValue, oldValue) {
          if (!newValue) {
            $scope.category = null;
          } else {
            setCategoryFromId(parseInt(newValue), false);
          }
        });
        $scope.showCategorySelectModal = function() {
          var modalInstance;
          modalInstance = $uibModal.open({
            templateUrl: 'modals/sub-profession-modal.html',
            controller: 'SubItemModalController',
            size: 'lg',
            resolve: {
              items: function () {
                return $scope.categories;
              },
              selectedItem: function () {
                return null;
              }
            }
          });
          modalInstance.result.then(function (pid) {
            setCategoryFromId(pid, true);
          }, function () {
            
          });
        };

        PostCategory.getData()
          .then(function(categories) {
            $scope.categories = categories;
            if ($scope.categoryId) {
              setCategoryFromId(parseInt($scope.categoryId), false);
            }
          }, function(message) {
            Alerts.add('danger', message);
          });
      }]
    }
  }])

  .directive('postCategorySelectionLink', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        categoryId: '=',
        selectionCallback: '=',
        buttonClasses: '=',
        defaultLabel: '='
      },
      templateUrl: 'directives/post-category-selection-link.html',
      controller: [ '$scope', '$uibModal', '$filter', 'PostCategory', 'Alerts', function($scope, $uibModal, $filter, PostCategory, Alerts) {
        var setCategoryFromId = function(pid, triggerCallback) {
          if ($scope.categories) {
            for (var i=0; i<$scope.categories.length; i++) {
              var selected = $filter('filter')($scope.categories[i].children, {id: parseInt(pid)}, true);
              if (selected.length > 0) {
                $scope.category = selected[0];
                if (triggerCallback)
                  $scope.selectionCallback($scope.category);
                break;
              }
            }
          }
        }
        $scope.$watch('categoryId', function(newValue, oldValue) {
          if (!newValue) {
            $scope.category = null;
          } else {
            setCategoryFromId(parseInt(newValue), false);
          }
        });
        $scope.showCategorySelectModal = function() {
          var modalInstance;
          modalInstance = $uibModal.open({
            templateUrl: 'modals/sub-profession-modal.html',
            controller: 'SubItemModalController',
            size: 'lg',
            resolve: {
              items: function () {
                return $scope.categories;
              },
              selectedItem: function () {
                return null;
              }
            }
          });
          modalInstance.result.then(function (pid) {
            setCategoryFromId(pid, true);
          }, function () {
            
          });
        };

        PostCategory.getData()
          .then(function(categories) {
            $scope.categories = categories;
            if ($scope.categoryId) {
              setCategoryFromId(parseInt($scope.categoryId), false);
            }
          }, function(message) {
            Alerts.add('danger', message);
          });
      }]
    }
  }])

  .directive('professionSelectionButton', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        professionId: '=',
        selectionCallback: '=',
        buttonClasses: '=',
        defaultLabel: '='
      },
      templateUrl: 'directives/profession-selection-button.html',
      controller: [ '$scope', '$uibModal', '$filter', 'Profession', 'Alerts', function($scope, $uibModal, $filter, Profession, Alerts) {
        var setProfessionFromId = function(pid, triggerCallback) {
          if ($scope.professions) {
            for (var i=0; i<$scope.professions.length; i++) {
              var selected = $filter('filter')($scope.professions[i].children, {id: parseInt(pid)}, true);
              if (selected.length > 0) {
                $scope.profession = selected[0];
                if (triggerCallback)
                  $scope.selectionCallback($scope.profession);
                break;
              }
            }
          }
        }
        $scope.$watch('professionId', function(newValue, oldValue) {
          if (!newValue) {
            $scope.profession = null;
          } else {
            setProfessionFromId(parseInt(newValue), false);
          }
        });
        $scope.showProfessionSelectModal = function() {
          var modalInstance;
          modalInstance = $uibModal.open({
            templateUrl: 'modals/sub-profession-modal.html',
            controller: 'SubItemModalController',
            size: 'lg',
            resolve: {
              items: function () {
                return $scope.professions;
              },
              selectedItem: function () {
                return null;
              }
            }
          });
          modalInstance.result.then(function (pid) {
            setProfessionFromId(pid, true);
          }, function () {
            
          });
        };

        Profession.getData()
          .then(function(professions) {
            $scope.professions = professions;
            if ($scope.professionId) {
              setProfessionFromId(parseInt($scope.professionId), false);
              // for (var i=0; i<$scope.professions.length; i++) {
              //   var selected = $filter('filter')($scope.professions[i].children, {id: parseInt($scope.professionId)}, true);
              //   if (selected.length > 0) {
              //     $scope.profession = selected[0];
              //     break;
              //   }
              // }
            }
          }, function(message) {
            Alerts.add('danger', message);
          });
      }]
    }
  }])

  .directive('priceTable', [function() {
    return {
      restrict: 'EA',
      replace: true,
      templateUrl: 'directives/price-table.html',
      controller: [ '$scope', '$filter', 'Pricings', 'Alerts', function($scope, $filter, Pricings, Alerts) {

        Pricings.getAllPricings()
          .then(function(pricings) {
            for (var i=0; i<pricings.length; i++) {
              switch(pricings[i].target) {
                case 'change_rate':
                  $scope.changeCredits = pricings[i].credit_amount;
                  break;
                case 'classified_ad_unlock':
                  $scope.classifiedAdUnlockCredits = pricings[i].credit_amount;
                  break;
                case "sponsored_profile":
                  $scope.sponsoredProfileCredits = pricings[i].credit_amount;
                  break;
                case "sponsored_map_profile":
                  $scope.sponsoredMapProfileCredits = pricings[i].credit_amount;
                  break;
                case "deal_deals":
                  $scope.sponsoredDealCredits = pricings[i].credit_amount;
                  break;
                case "deal_map":
                  $scope.sponsoredDealMapCredits = pricings[i].credit_amount;
                  break;
                case "deal_homepage":
                  $scope.sponsoredDealHomepageCredits = pricings[i].credit_amount;
                  break;
                case "bonus_signup":
                  $scope.bonusSignupCredits = pricings[i].credit_amount;
                  break;
              }
            }
          }, function(message) {
            Alerts.add('danger', message);
          });
      }]
    }
  }])

  .directive('heartBox', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        isFavorite: '=',
        proId: '=',
        clickable: '='
      },
      templateUrl: 'directives/heart-box.html',
      controller: [ '$scope', 'FavoriteProfessionals', 'Alerts', function($scope, FavoriteProfessionals, Alerts) {
        $scope.isSaving = false;
        $scope.toggleFavorite = function() {
          if ($scope.clickable) {
            $scope.isSaving = true;
            if ($scope.isFavorite) {
              FavoriteProfessionals.removeFromFavorites($scope.proId)
                .then(function() {
                  $scope.isFavorite = false;
                  $scope.isSaving = false;
                }, function(message) {
                  $scope.isSaving = false;
                  Alerts.add('danger', message);
                });
            } else {
              FavoriteProfessionals.addToFavorites($scope.proId)
                .then(function() {
                  $scope.isFavorite = true;
                  $scope.isSaving = false;
                }, function(message) {
                  $scope.isSaving = false;
                  Alerts.add('danger', message);
                });
            }
          }
          
        };
      }]
    }
  }])

  .directive('formattedMessage', [function() {
    return {
      restrict: 'EA',
      replace: true,
      scope: {
        text: '='
      },
      template: '<div ng-bind-html="formatText(text)"></div>',
      controller: [ '$scope', function($scope) {
        $scope.formatText = function( text ) {
          if (text) {
            text = urlize(text,{target: "_blank", trim: "http"});
            text = text.replace(/(?:\r\n|\r|\n)/g, '<br />');
          }
          return text;
        }
      }]
    }
  }])

  .directive('conversationList', [function() {
    return {
      restrict: 'EA',
      scope: {
        conversations: '=',
        sessionUser: '=',
        classifiedAdId: '=',
        showUserCard: '='
      },
      replace: true,
      templateUrl: 'directives/conversation-list.html',
      controller: [ '$scope', '$rootScope', '$location', '$timeout', '$state', '$window', '$filter', '$uibModal', 'Alerts', 'Conversations', 'SocketMessages', function($scope, $rootScope, $location, $timeout, $state, $window, $filter, $uibModal, Alerts, Conversations, SocketMessages) {
        $scope.isLoadingConversation = false;
        $scope.isPosting = false;
        $scope.canPost = $rootScope.isMessagingAvailable;
        $scope.typingMessageSent = {};
        $scope.messageReply = {newConversation: ''};

        var isTypingPromise;
        var TYPING_TIMEOUT = 20000;

        $rootScope.$on('socket-connexion', function(event, args) {
          $scope.canPost = args.connected;
        });

        $scope.acceptRequest = function(conversationId) {
          askForReasons('accept', conversationId);
        };

        $scope.rejectRequest = function(conversationId) {
          askForReasons('reject', conversationId);
        };

        var askForReasons = function(type, conversationId) {
          var modalInstance;
          modalInstance = $uibModal.open({
            templateUrl: 'modals/user-response-modal.html',
            controller: 'UserResponseModalController',
            resolve: {
              type: function () {
                return type;
              },
              conversationId: function () {
                return conversationId;
              }
            }
          });
          modalInstance.result.then(function (reason) {
            // scope.isPayingCredits = true;
            Conversations.updateStatus(conversationId, {status: type, reason: $filter('htmlToPlaintext')(reason)})
            .then(function(conversation) {
              // scope.isPayingCredits = false;
              $scope.selectedConversation = conversation;
            }, function(message) {
              // scope.isPayingCredits = false;
              alerts.add('danger', message);
            });
          }, function () {
            // Cancelled
          });
        };
        

        $scope.showQuotation = function(quotationURL) {
          $window.open(quotationURL, '_blank');
        };

        $scope.translateSystemMessage = function( systemMessage ) {
          var translatedMessage = '';
          if (systemMessage.system_generated) {
            var messageContent = JSON.parse(systemMessage.content);
            switch ( messageContent.type ) {
              case 'new_quotation_request':
                translatedMessage = ' a envoyé <a class=\"orange\" href=\"/demande-de-devis/' + messageContent.quotation_request_id + '\">une demande de devis</a>';
                break;
              case 'new_quotation':
                translatedMessage = ' a envoyé <a class=\"orange\" target=\"_blank\" href=\"' + messageContent.quotation_url + '\">un devis</a>';
                break;
              case 'offer_rejected':
                translatedMessage = " a rejeté l'offre pour la raison suivante : " + messageContent.reason;
                break;
              case 'offer_accepted':
                translatedMessage = " a accepté l'offre pour la raison suivante : " + messageContent.reason;
                break;
            }
          }
          return translatedMessage;
        };

        $scope.replyToClassified = function(){
          $scope.isPosting = true;
          var conversationData = { message: {content: $filter('htmlToPlaintext')($scope.messageReply.newConversation)}, clad_id: $scope.classifiedAdId };

          SocketMessages.postMessage(conversationData,
            function() {
              $scope.messageReply.newConversation = '';
              $scope.isPosting = false;
            }, function() {
              Alerts.add('danger', I18n.t("conversations.message_failed"));
              $scope.isPosting = false;
            });
        };

        $scope.addMessage = function (conversationId, messageContent) {
          if ($scope.isPosting){
            return;
          }
          $scope.isPosting = true;
          var conversationData = { message: {content: $filter('htmlToPlaintext')(messageContent), conversation_id: conversationId} };
          SocketMessages.postMessage(conversationData,
            function() {
              $scope.messageReply[conversationId] = '';
              $scope.typingMessageSent[$scope.selectedConversation.id] = false;
              $scope.isPosting = false;
              $timeout(function () {
                $('#messageReply').focus();
              },100);
            }, function() {
              Alerts.add('danger', I18n.t("conversations.message_failed"));
              $scope.isPosting = false;
              $timeout(function () {
                $('#messageReply').focus();
              },100);
            });
        };

        $scope.replyChangedHandler = function() {
          if (angular.isDefined(isTypingPromise)) {
            $timeout.cancel(isTypingPromise);
          }
          if (typeof $scope.messageReply !== "undefined" && $scope.messageReply[$scope.selectedConversation.id] && $scope.messageReply[$scope.selectedConversation.id].length > 0) {
            isTypingPromise = $timeout(setNotTypingForSelectedConversation, TYPING_TIMEOUT);
            if (!$scope.typingMessageSent[$scope.selectedConversation.id]) {
              sendIsTypingMessage($scope.selectedConversation.id, true);  
            }
          } else if ($scope.typingMessageSent[$scope.selectedConversation.id] && ($scope.messageReply[$scope.selectedConversation.id] == null || $scope.messageReply[$scope.selectedConversation.id] == '')) {
            sendIsTypingMessage($scope.selectedConversation.id, false);
          }
        };

        var setNotTypingForSelectedConversation = function() {
          if (angular.isDefined(isTypingPromise)) {
            $timeout.cancel(isTypingPromise);
          }
          if ($scope.selectedConversation != null) {
            sendIsTypingMessage($scope.selectedConversation.id, false);
          }
        };

        var sendIsTypingMessage = function(conversationId, isTyping) {
          SocketMessages.sendIsTypingMessage(conversationId, isTyping,
            function() {
              $scope.typingMessageSent[$scope.selectedConversation.id] = isTyping;
            }, function() {
              Alerts.add('danger', I18n.t("general.connection_error"));
            });
        };

        $scope.sendMessage = function() {
          if (typeof $scope.messageReply !== "undefined" && $scope.messageReply[$scope.selectedConversation.id].length > 0){
            $scope.addMessage($scope.selectedConversation.id, $scope.messageReply[$scope.selectedConversation.id]);
          }
        };

        $rootScope.getConversation = $scope.getConversation = function(conversationId) {
          $scope.isLoadingConversation = true;
          $location.replace();
          $location.search('conversationId', conversationId);
          $state.params = { conversationId: conversationId };
          Conversations.getById(conversationId)
            .then( function(conversation) {
              setNotTypingForSelectedConversation();
              Conversations.data.selectedConversation = $scope.selectedConversation = conversation;
              var conversationToUpdate = $filter('filter')($scope.conversations, { id: parseInt(conversationId) }, true)[0];
              Conversations.data.selectedConversation.isTyping = conversationToUpdate.isTyping;
              conversationToUpdate.unread = false;
              SocketMessages.notifyConversationRead( $scope.sessionUser.id, Conversations.data.selectedConversation.id, function(newCount) { $scope.sessionUser.unread_conversations_count = newCount; $scope.$apply(); } );
              
              $scope.isLoadingConversation = false;
            }, function(message) {
              Alerts.add('danger', message);
              $scope.isLoadingConversation = false;
            });
        };

        var loadConversationById = function() {
          $scope.getConversation($location.search().conversationId || $scope.conversations[0].id);
        };

        if (angular.isDefined($scope.conversations) && $scope.conversations.length > 0) {
          loadConversationById();
        } else {
          $scope.$watch( 'conversations', function() {
            if (angular.isDefined($scope.conversations) && $scope.conversations.length > 0) {
              loadConversationById();
            }
          });
        }

        $scope.$on("$destroy", function() {
          Conversations.data.selectedConversation = $scope.selectedConversation = null;
        });
      }]
    }
  }])

  .directive('quotationRequestStatusDropdown', [function() {
    return {
      restrict: 'EA',
      scope: {
        adId: '=',
        adStatus: '=',
        updatingClassified: '='
      },
      replace: true,
      templateUrl: 'directives/quotation-request-status-dropdown.html',
      controller: [ '$scope', '$rootScope', '$filter', '$uibModal', 'Alerts', 'ClassifiedAd', function($scope, $rootScope, $filter, $uibModal, Alerts, ClassifiedAd) {
        var modalInstance;
        var newStatus;
        var updateStatus = function(status, reason) {
          ClassifiedAd.update({ id: $scope.adId, status: status, reject_reason: reason} )
            .then(function(updatedAd) {
              $scope.updatingClassified[$scope.adId] = false;
              $scope.adStatus = updatedAd.status;
            }, function(message) {
              $scope.updatingClassified[$scope.adId] = false;
              Alerts.add('danger', message);
            });
        };
        $scope.setClassifiedStatus = function(status) {
          $scope.updatingClassified[$scope.adId] = true;
          newStatus = status;
          if (status == 'close') {
            modalInstance = $uibModal.open({
              templateUrl: 'modals/confirm-modal.html',
              controller: 'ConfirmModalController',
              resolve: {
                confirmTitle: function () {
                  return I18n.t("quotation_request.close_title"); 
                },
                confirmText: function () {
                  return I18n.t("quotation_request.close_text");
                },
                confirmLabel: function () {
                  return I18n.t("quotation_request.close");
                },
                cancelLabel: function () {
                  return I18n.t("quotation_request.cancel_label");
                }
              }
            });
            modalInstance.result.then(function () {
              updateStatus(newStatus);
            }, function () {
              $scope.updatingClassified[$scope.adId] = false;
            });
          } else {
            updateStatus(status);
          }
        };
      }]
    }
  }])

  .directive('annonceStatusDropdown', [function() {
    return {
      restrict: 'EA',
      scope: {
        ad: '=',
        updatingClassified: '=',
        ads: '=',
        type: '='
      },
      replace: true,
      templateUrl: 'directives/annonce-status-dropdown.html',
      controller: [ '$scope', '$rootScope', '$filter', '$uibModal', 'Alerts', 'ClassifiedAd', function($scope, $rootScope, $filter, $uibModal, Alerts, ClassifiedAd) {
        var modalInstance;
        var classifiedAdId;
        var newStatus;
        var updateStatus = function(adId, status, reason) {
          ClassifiedAd.update({ id: adId, status: status, reject_reason: reason} )
            .then(function(updatedAd) {
              $scope.updatingClassified[adId] = false;
              $scope.ad.status = updatedAd.status;
              // if ($scope.ads) {
              //   var selectedClassified = $filter('filter')($scope.ads, {id: adId}, true)[0];
              //   if (selectedClassified) {
              //     selectedClassified.status = ad.status;
              //   }
              // }
            }, function(message) {
              $scope.updatingClassified[adId] = false;
              Alerts.add('danger', message);
            });
        };
        $scope.setClassifiedStatus = function(adId, status) {
          $scope.updatingClassified[adId] = true;
          classifiedAdId = adId;
          newStatus = status;
          if (status == 'close') {
            modalInstance = $uibModal.open({
              templateUrl: 'modals/confirm-modal.html',
              controller: 'ConfirmModalController',
              resolve: {
                confirmTitle: function () {
                  return I18n.t("classified_ad.close_title"); 
                },
                confirmText: function () {
                  return I18n.t("classified_ad.close_text");
                },
                confirmLabel: function () {
                  return I18n.t("classified_ad.close");
                },
                cancelLabel: function () {
                  return I18n.t("classified_ad.cancel_label");
                }
              }
            });
            modalInstance.result.then(function () {
              updateStatus(classifiedAdId, newStatus);
            }, function () {
              $scope.updatingClassified[adId] = false;
            });
          } else if (status == 'report') {
            modalInstance = $uibModal.open({
              templateUrl: 'modals/report-classified-ad-modal.html',
              controller: 'ReportClassifiedAdModalController',
              resolve: {
                confirmTitle: function () {
                  return I18n.t("classified_ad.report_title"); 
                },
                confirmText: function () {
                  return I18n.t("classified_ad.report_text");
                },
                confirmLabel: function () {
                  return I18n.t("classified_ad.report");
                },
                cancelLabel: function () {
                  return I18n.t("classified_ad.cancel_label");
                }
              }
            });
            modalInstance.result.then(function (reason) {
              updateStatus(classifiedAdId, newStatus, reason);
            }, function () {
              $scope.updatingClassified[adId] = false;
            });
          } else {
            updateStatus(adId, status);
          }
        };
      }]
    }
  }])

  .directive('classifiedAdStatus', [function() {
    return {
      restrict: 'EA',
      scope: {
        status: '=',
        isUpdating: '='
      },
      replace: true,
      templateUrl: 'directives/classified-ad-status.html',
      controller: [ '$scope', '$rootScope', function($scope, $rootScope) {
        $scope.getIconClass = function() {
          var iconClass;
          if ($scope.isUpdating) {
            iconClass = 'fa-circle-o-notch fa-spin pending';
          } else {
            switch ($scope.status) {
              case 'pending':
                iconClass = 'fa-spinner fa-spin';
                break;
              case 'published':
                iconClass = 'fa-check';
                break;
              case 'rejected':
                iconClass = 'fa-ban';
                break;
              case 'inactive':
                iconClass = 'fa-pause';
                break;
              case 'reported':
                iconClass = 'fa-exclamation';
                break;
              case 'private':
                iconClass = 'fa-eye-slash';
                break;
              default:
                iconClass = 'fa-times';
                break;
            }
            iconClass += ' ' + $scope.status;
          }
          return iconClass;
        };
        $scope.getTooltip = function() {
          var statusTooltip;
          switch ($scope.status) {
            case 'pending':
              statusTooltip = 'Votre annonce est actuellement revue par notre équipe.';
              break;
            case 'published':
              statusTooltip = 'Votre annonce est publiée.';
              break;
            case 'rejected':
              statusTooltip = "Votre annonce a été rejetée. Affichez les détails de l'annonce pour connaître la raison.";
              break;
            case 'closed':
              statusTooltip = 'Votre annonce est close.';
              break;
            case 'inactive':
              statusTooltip = "Votre annonce est en mode pause.";
              break;
            case 'reported':
              statusTooltip = 'Votre annonce a été signalée par un autre utilisateur.';
              break;
            case 'private':
              statusTooltip = 'Annonce privée.';
              break;
          }
          return statusTooltip;
        };
      }]
    }
  }])

  .directive('professionalGrid', ['$timeout', '$window', '$mdMedia', function($timeout, $window, $mdMedia) {
    return {
      restrict: 'EA',
      scope: {
        professionals: '=',
        selectedProfessionalId: '=',
        canAddToFavorites: '=',
        highlightCallback: '=',
        unlightCallback: '=',
        isParticulier: '='
      },
      replace: true,
      templateUrl: 'directives/professional-grid.html',
      link: function (scope, element, attrs) {
        var resizing = false;
        scope.resizeBoxes = function() {
          if (!resizing) {
            resizing = true;
            $timeout(function() {
              var totalWidth = element[0].clientWidth - parseFloat(element.css('padding-right')) - parseFloat(element.css('padding-left'));
              var numOfPros;
              var ratio = 5/9;
              if (totalWidth < 480) {
                numOfPros = 1;
                ratio = 0.52;
              } else if (totalWidth < 540) {
                numOfPros = 2;
                ratio = 0.65;
              } else if (totalWidth < 670) {
                numOfPros = 2;
                ratio = 0.78;
              } else {
                numOfPros = 3;
                ratio = 0.87;
              }
              var proBoxElement = element.find('.pro-box').first();
              var marginSum = (parseFloat(proBoxElement.css('margin-right')) + parseFloat(proBoxElement.css('margin-left')) + 2)*(numOfPros);
              var boxWidth = (totalWidth - marginSum)/numOfPros;
              // boxWidth = Math.min(300, Math.max(160, boxWidth));
              var boxHeight = Math.max(boxWidth * ratio, 170);
              
              element.find('.pro-box').css('width', boxWidth + 'px');
              element.find('.pro-box').css('height', boxHeight + 'px');
              resizing = false;
            }, 300);
          }
        }
        angular.element($window).bind('resize', function() {
          scope.resizeBoxes();
        });

        scope.$on("$destroy", function() {
          angular.element($window).unbind('resize');
        });

        scope.$watch('professionals', function(newValue, oldValue) {
          if (newValue && newValue.length > 0) {
            scope.resizeBoxes();
          }
        });
      }
    }
  }])

  .directive('dealGrid', ['$timeout', '$window', '$mdMedia', function($timeout, $window, $mdMedia) {
    return {
      restrict: 'EA',
      scope: {
        deals: '=',
        wide: '=',
        numOfDeals: '=',
        forceNumOfDeals: '='
      },
      replace: true,
      templateUrl: 'directives/deal-grid.html',
      link: function (scope, element, attrs) {
        var ratio = scope.wide ? 9/16 : 3/4;
        var resizing = false;
        scope.resizeBoxes = function() {
          if (!resizing) {
            resizing = true;
            $timeout(function() {
              var totalWidth = element[0].clientWidth;
              var numOfDeals;
              if (scope.forceNumOfDeals) {
                numOfDeals = scope.numOfDeals;
              } else {
                if ($mdMedia('xs')) {
                  numOfDeals = 1;
                } else if ($mdMedia('sm')) {
                  numOfDeals = 2;
                } else if (scope.numOfDeals) {
                  numOfDeals = scope.numOfDeals;
                } else {
                  numOfDeals = scope.deals.length;
                  if ($mdMedia('md')) {
                    numOfDeals = 3;
                  }
                }
              }
              var marginSum = parseFloat(element.find('.deal-box').first().css('margin-right'))*(numOfDeals) + 1;
               // + parseFloat(element.find('.deal-box').last().css('margin-right'));
              var boxWidth = (totalWidth - marginSum)/numOfDeals;
              boxWidth = Math.min(300, Math.max(160, boxWidth));
              var boxHeight = boxWidth * ratio;
              var logo = { size: '30px', right: '-50%', top: '-12%', display: true };
              if (boxWidth > 300) {
                logo.size = '46px';
                logo.right = '-48%';
                logo.top = '-40%';
              } else if (boxWidth > 230) {
                logo.size = '40px';
                logo.right = '-90%';
                logo.top = '12px';
              } else if (boxWidth > 180) {
                logo.size = '34px';
                logo.right = '-87%';
                logo.top = '15px';
              } else {
                logo.display = false;
                logo.size = '36px';
                logo.right = scope.wide ? '-86%' : '-89%';
                logo.top = scope.wide ? '8px' : '12px';
              }
              if (logo.display) {
                element.find('.face').css('width', logo.size);
                element.find('.face').css('height', logo.size);
                element.find('.face').css('right', logo.right);
                element.find('.face').css('top', logo.top);
                element.find('.face').css('display', 'initial');
              }
              else {
                element.find('.face').css('display', 'none');
              }
              element.find('.deal-box').css('width', boxWidth + 'px');
              element.find('.deal-box').css('height', boxHeight + 'px');
              resizing = false;
            }, 300);
          }
        }
        scope.$watch('deals', function(newValue, oldValue) {
          if (newValue && newValue != oldValue) {
            scope.resizeBoxes();
          }
        });
        angular.element($window).bind('resize', function() {
          scope.resizeBoxes();
        });

        scope.$on("$destroy", function() {
          angular.element($window).unbind('resize');
        });
      }
    }
  }])

  .directive('dealRow', ['$timeout', '$window', '$mdMedia', function($timeout, $window, $mdMedia) {
    return {
      restrict: 'EA',
      scope: {
        deals: '=',
        wide: '=',
        reloadCallback: '=',
        numOfDeals: '='
      },
      replace: true,
      templateUrl: 'directives/deal-row.html',
      link: function (scope, element, attrs) {
        var ratio = scope.wide ? 9/16 : 3/4;
        var previousWidth = 0;
        var resizeBoxes = function() {
          var totalWidth = element[0].clientWidth;
          var numOfDeals;
          if ($mdMedia('xs')) {
            numOfDeals = 1;
          } else if ($mdMedia('sm')) {
            numOfDeals = 2;
          } else if (scope.numOfDeals) {
            numOfDeals = scope.numOfDeals;
          } else {
            numOfDeals = scope.deals.length;
            if ($mdMedia('md')) {
              numOfDeals = 3;
            }
          }
          var marginSum = parseFloat(element.find('.deal-box').first().css('margin-right'))*(numOfDeals-1) + parseFloat(element.find('.deal-box').last().css('margin-right'));
          var boxWidth = (totalWidth - marginSum)/numOfDeals;
          boxWidth = Math.min(300, Math.max(160, boxWidth));
          if (scope.deals && scope.deals.length > 0 && previousWidth != 0 && boxWidth != previousWidth) {
            scope.reloadCallback();
          }
          var boxHeight = boxWidth * ratio;
          var logo = { size: '30px', right: '-50%', top: '-12%', display: true };
          if (boxWidth > 300) {
            logo.size = '46px';
            logo.right = '-48%';
            logo.top = '-40%';
          } else if (boxWidth > 230) {
            logo.size = '40px';
            logo.right = '-90%';
            logo.top = '12px';
          } else if (boxWidth > 180) {
            logo.size = '34px';
            logo.right = '-87%';
            logo.top = '15px';
          } else {
            logo.size = '30px';
            logo.right = scope.wide ? '-86%' : '-89%';
            logo.top = scope.wide ? '8px' : '12px';
          }
          if (logo.display) {
            element.find('.face').css('width', logo.size);
            element.find('.face').css('height', logo.size);
            element.find('.face').css('right', logo.right);
            element.find('.face').css('top', logo.top);
            element.find('.face').css('display', 'initial');
          }
          else {
            element.find('.face').css('display', 'none');
          }
          element.find('.deal-box').css('width', boxWidth + 'px');
          element.find('.deal-box').css('height', boxHeight + 'px');
          previousWidth = boxWidth;
        }
        scope.$watch('deals', function(newValue, oldValue) {
          if (newValue && newValue != oldValue) {
            $timeout(function() {
              resizeBoxes();
            });
          }
        });
        angular.element($window).bind('resize', function() {
          resizeBoxes();
        });

        scope.$on("$destroy", function() {
          angular.element($window).unbind('resize');
        });
      }
    }
  }])

  .directive('dealWideFlatBox', [function() {
    return {
      restrict: 'EA',
      scope: {
        deal: '=',
        wide: '='
      },
      replace: true,
      templateUrl: 'directives/deal-wide-flat-box.html'
    }
  }])

  .directive('dealSquareFlatBox', [function() {
    return {
      restrict: 'EA',
      scope: {
        deal: '='
      },
      replace: true,
      templateUrl: 'directives/deal-square-flat-box.html'
    }
  }])

  .directive('dealCompanyBox', [function() {
    return {
      restrict: 'EA',
      scope: {
        deal: '='
      },
      replace: true,
      templateUrl: 'directives/deal-company-box.html'
    }
  }])

  .directive('dealListBox', [function() {
    return {
      restrict: 'EA',
      scope: {
        deal: '='
      },
      replace: true,
      templateUrl: 'directives/deal-list-box.html'
    }
  }])

  .directive('dealFeaturedBox', [function() {
    return {
      restrict: 'EA',
      scope: {
        deal: '='
      },
      replace: true,
      templateUrl: 'directives/deal-featured-box.html'
    }
  }])

  .directive('dealSmallBox', [function() {
    return {
      restrict: 'EA',
      scope: {
        deal: '='
      },
      replace: true,
      templateUrl: 'directives/deal-small-box.html'
    }
  }])

  .directive('dealProBox', [function() {
    return {
      restrict: 'EA',
      scope: {
        deal: '='
      },
      replace: true,
      templateUrl: 'directives/deal-pro-box.html'
    }
  }])

  .directive('listProBox', [function() {
    return {
      restrict: 'EA',
      scope: {
        professional: '=',
        selected: '=',
        canAddToFavorites: '=',
        isParticulier: '='
      },
      replace: true,
      templateUrl: 'directives/list-pro-box.html'
    }
  }])

  .directive('singleImageUpload', [function() {
    return {
      restrict: 'EA',
      scope: {
        image_url: '=',
        imageBlob: '=',
        imageWidth: '=',
        imageHeight: '=',
        minWidth: '=',
        minHeight: '=',
        maxWidth: '=',
        maxHeight: '='
      },
      replace: true,
      templateUrl: 'directives/single-image-upload.html',
      controller: [ '$scope', '$rootScope', 'FileUploader', 'Alerts', function($scope, $rootScope, FileUploader, Alerts) {
        $scope.uploader = new FileUploader({ queueLimit: 1, alias: 'image', method: 'PATCH', removeAfterUpload: true});
        $scope.hasWrongSize = false;
        $scope.uploader.onAfterAddingFile = function(itemFile) {
          $scope.hasWrongSize = false;
          $scope.imageBlob = null;
          var reader = new FileReader();
          var img = new Image();
          img.onload = onLoadImage;
          function onLoadImage() {
            if (this.width < $scope.minWidth || this.height < $scope.minHeight || ($scope.maxWidth && this.width > $scope.maxWidth) || ($scope.maxHeight && this.height > $scope.maxHeight)) {
              $scope.imageBlob = null;
              $scope.uploader.clearQueue();
              $scope.hasWrongSize = true;
              $scope.$apply();
            }
          }
          reader.onload = function(event) {
            $scope.$apply(function(){
              img.src = event.target.result;
              $scope.imageBlob = event.target.result;
            });
          };
          reader.readAsDataURL(itemFile._file);
        };

        $scope.cancel = function() {
          $scope.uploader.clearQueue();
          $scope.imageBlob = null;
        };

        $scope.deleteImage = function() {
          $scope.imageBlob = null;
        };
      }]
    }
  }])

  .directive('avatarUpload', [function() {
    return {
      restrict: 'EA',
      scope: {
        user: '=',
        title: '@',
        hasImage: '='
      },
      replace: true,
      templateUrl: 'directives/avatar-upload.html',
      controller: [ '$scope', '$rootScope', '$cookies', 'FileUploader', 'User', 'Alerts', function($scope, $rootScope, $cookies, FileUploader, User, Alerts) {
        $scope.imageEdit = { input: null, cropped: null };
        $scope.hasImage = false;
        $scope.uploader = new FileUploader({ queueLimit: 1, alias: 'avatar', method: 'PATCH', removeAfterUpload: true});
        $scope.uploader.onSuccessItem = function(item, response) {
          $scope.user.avatar_url = response.user.avatar_url;
          $scope.user.hasAvatar = true;
          $scope.imageEdit = { input: null, cropped: null };
          $scope.hasImage = false;
        };
        $scope.uploader.onErrorItem = function(item, response) {
          Alerts.add('danger', "L'envoi du fichier a échoué");
          console.log(response);
        };
        $scope.uploader.onAfterAddingFile = function(itemFile) {
          $scope.imageEdit.cropped = '';
          var reader = new FileReader();
          reader.onload = function(event) {
            $scope.$apply(function(){
              $scope.imageEdit.input = event.target.result;
              $scope.hasImage = true;
            });
          };
          reader.readAsDataURL(itemFile._file);
          // itemFile.url = $scope.uploader.url = '/api/v1/users/' + $scope.user.id;
          // itemFile.headers = $scope.uploader.headers = { 'X-XSRF-TOKEN': $cookies['XSRF-TOKEN'], 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') }
          // itemFile.upload();
        };

        $scope.uploadCroppedImage = function() {
          $scope.uploader.uploadAll();
        }

        $scope.cancel = function() {
          $scope.uploader.clearQueue();
          $scope.imageEdit = { input: null, cropped: null };
          $scope.hasImage = false;
        }

        /**
         * Upload Blob (cropped image) instead of file.
         * @see
         *   https://developer.mozilla.org/en-US/docs/Web/API/FormData
         *   https://github.com/nervgh/angular-file-upload/issues/208
         */
        $scope.uploader.onBeforeUploadItem = function(itemFile) {
          itemFile.url = $scope.uploader.url = '/api/v1/users/' + $scope.user.id;
          itemFile.headers = $scope.uploader.headers = { 'X-XSRF-TOKEN': $cookies['XSRF-TOKEN'], 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') };
          var blob = dataURItoBlob($scope.imageEdit.cropped);
          itemFile._file = blob;
        };

        $scope.deleteAvatar = function() {
          $scope.isSavingProfile = true;
          User.deleteAvatar()
            .then(function() {
              $scope.isSavingProfile = false;
            }, function(messages) {
              $scope.isSavingProfile = false;
              for (var i=0; i<messages.length; i++) {
                Alerts.add('danger', messages[i]);
              }
            });
        };
      }]
    }
  }])

  .directive('scrollToTopButton', [function() {
    return {
      restrict: 'A',
      replace: true,
      scope: {},
      templateUrl: 'directives/scroll-to-top-button.html',
      controller: [ '$scope', '$window', '$document', '$uiViewScroll', function($scope, $window, $document, $uiViewScroll) {
        $scope.showMe = $window.pageYOffset > 100;
        $document.on( 'scroll', function() {
          $scope.showMe = $window.pageYOffset > 100;
          $scope.$apply();
        });
        $scope.goToTop = function() {
          $uiViewScroll($('.main-view-container'));
          $("html, body").animate({ scrollTop: 0 }, 200);
        };
      }]
    }
  }])
  /**
  * The ng-thumb directive
  * @author: nerv
  * @version: 0.1.2, 2014-01-09
  */
  .directive('ngThumb', ['$window', function($window) {
    var helper = {
      support: !!($window.FileReader && $window.CanvasRenderingContext2D),
      isFile: function(item) {
        return angular.isObject(item) && item instanceof $window.File;
      },
      isImage: function(file) {
        var type =  '|' + file.type.slice(file.type.lastIndexOf('/') + 1) + '|';
        return '|jpg|png|jpeg|bmp|gif|'.indexOf(type) !== -1;
      }
    };

    return {
      restrict: 'A',
      template: '<canvas/>',
      link: function(scope, element, attributes) {
        if (!helper.support) return;

        var params = scope.$eval(attributes.ngThumb);

        if (!helper.isFile(params.file)) return;
        if (!helper.isImage(params.file)) return;

        var canvas = element.find('canvas');
        var reader = new FileReader();

        reader.onload = onLoadFile;
        reader.readAsDataURL(params.file);

        function onLoadFile(event) {
          var img = new Image();
          img.onload = onLoadImage;
          img.src = event.target.result;
        }

        function onLoadImage() {
          var width = params.width || this.width / this.height * params.height;
          var height = params.height || this.height / this.width * params.width;
          canvas.attr({ width: width, height: height });
          canvas[0].getContext('2d').drawImage(this, 0, 0, width, height);
        }
      }
    };
  }])

  .directive('ngGallery', ['$document', '$timeout', '$q', '$templateCache', function($document, $timeout, $q, $templateCache) {

    var defaults = { 
      baseClass   : 'ng-gallery',
      thumbClass  : 'ng-thumb',
      templateUrl : 'ng-gallery.html'
    };

    var keys_codes = {
      enter : 13,
      esc   : 27,
      left  : 37,
      right : 39
    };

    function setScopeValues(scope, attrs) {
      scope.baseClass = scope.class || defaults.baseClass;
      scope.thumbClass = scope.thumbClass || defaults.thumbClass;
      scope.thumbsNum = scope.thumbsNum || 3; // should be odd
    }

    var template_url = defaults.templateUrl;
    // Set the default template
      $templateCache.put(template_url,
    '<div class="{{ baseClass }}">' +
    '  <div ng-repeat="i in images">' +
    '    <img ng-src="{{ i.attachment_url }}" class="{{ thumbClass }}" ng-click="openGallery($index)" alt="Image {{ $index + 1 }}" />' +
    '  </div>' +
    '</div>' +
    '<div class="ng-overlay" ng-show="opened">' +
    '</div>' +
    '<div class="ng-gallery-content" ng-show="opened">' + 
    '  <a class="close-popup" ng-click="closeGallery()"><i class="fa fa-close"></i></a>' +
    '  <a class="nav-left" ng-click="prevImage()" ng-hide="images.length==1"><i class="fa fa-angle-left"></i></a>' +
    '  <img ng-src="{{ img }}" ng-click="nextImage()" class="effect" />' +
    '  <a class="nav-right" ng-click="nextImage()" ng-hide="images.length==1"><i class="fa fa-angle-right"></i></a>' +
    '  <span class="info-text">{{ index + 1 }}/{{ images.length }}</span>' +
    '</div>'
    );

    return {
      restrict: 'EA',
      scope: {
        images: '=',
        thumbsNum: '@'
      },
      templateUrl: function(element, attrs) {
              return attrs.templateUrl || defaults.templateUrl;
          },
      link: function (scope, element, attrs) {
        setScopeValues(scope, attrs);

        if (scope.thumbsNum >= 11) {
          scope.thumbsNum = 11;
        }

        var $body = $document.find('body');
        var $thumbwrapper = angular.element(document.querySelectorAll('.ng-thumbnails-wrapper'));
        var $thumbnails = angular.element(document.querySelectorAll('.ng-thumbnails'));

        scope.index = 0;
        scope.opened = false;

        scope.thumb_wrapper_width = 0;
        scope.thumbs_width = 0;

        // var loadImage = function (i) {
        //   var deferred = $q.defer();
        //   var image = new Image();

        //   image.onload = function () {
        //     scope.loading = false;
        //           if (typeof this.complete === false || this.naturalWidth === 0) {
        //             deferred.reject();
        //           }
        //           deferred.resolve(image);
        //   };
      
        //   image.onerror = function () {
        //     deferred.reject();
        //   };
          
        //   image.src = scope.images[i].attachment_url;
        //   scope.loading = true;

        //   return deferred.promise;
        // };

        var loadImage = function (i) {
          var image = new Image();
          
          image.src = scope.images[i].attachment_url;

          return image;
        };

        var showImage = function (i) {
          scope.img = loadImage(scope.index).src;
        };

        scope.changeImage = function (i) {
          scope.index = i;
          scope.img = loadImage(scope.index).src;
        };

        scope.nextImage = function () {
          scope.index += 1;
          if (scope.index === scope.images.length) {
            scope.index = 0;
          }
          showImage(scope.index);
        };

        scope.prevImage = function () {
          scope.index -= 1;
          if (scope.index < 0) {
            scope.index = scope.images.length - 1;
          }
          showImage(scope.index);
        };

        scope.openGallery = function (i) {
          if (typeof i !== undefined) {
            scope.index = i;
            showImage(scope.index);
          }
          scope.opened = true;

          $timeout(function() {
            var calculatedWidth = calculateThumbsWidth();
            scope.thumbs_width = calculatedWidth.width;
            $thumbnails.css({ width: calculatedWidth.width + 'px' });
            $thumbwrapper.css({ width: calculatedWidth.visible_width + 'px' });
          });
        };

        scope.closeGallery = function () {
          scope.opened = false;
        };

        $body.bind('keydown', function(event) {
          if (!scope.opened) {
            return;
          }
          var which = event.which;
          if (which === keys_codes.esc) {
            scope.closeGallery();
          } else if (which === keys_codes.right || which === keys_codes.enter) {
            scope.nextImage();
          } else if (which === keys_codes.left) {
            scope.prevImage();
          }

          scope.$apply();
        });

        var calculateThumbsWidth = function () {
          var width = 0,
            visible_width = 0;
          angular.forEach($thumbnails.find('img'), function(thumb) {
            width += thumb.clientWidth;
            width += 10; // margin-right
            visible_width = thumb.clientWidth + 10;
          });
          return {
            width: width,
            visible_width: visible_width * scope.thumbsNum
          };
        };

      }
    };

  }]);