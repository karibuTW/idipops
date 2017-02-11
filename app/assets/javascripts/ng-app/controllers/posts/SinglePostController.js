angular
  .module('uneo.controllers')
  .controller(
    'SinglePostController',
    ['$rootScope', '$scope', '$state', '$sce', '$location', '$uibModal', '$timeout', 'Post', 'PostCategorySubscription', 'PostComment', 'PostAuthorSubscription', 'FavoritePosts', 'FavoritePostComments', 'GeoLocation', 'Alerts', SinglePostController]
  );

  function SinglePostController($scope, $rootScope, $state, $sce, $location, $uibModal, $timeout, Post, PostCategorySubscription, PostComment, PostAuthorSubscription, FavoritePosts, FavoritePostComments, GeoLocation, Alerts) {
  	$scope.isLoading = true;
    $scope.isLoadingComments = true;
    $scope.isPostingComment = false;
  	var postId = $state.params.poid;
    $scope.myComment = { newComment: "" };
    $scope.tooltip = { showSelfSubscribeTooltip: false };
    $scope.post = { category_id: null, category_name: "", category_subscribed: false, profession_id: null, profession_name: "", user_nickname: "", status: "", featured_image_url: null, title: "", posted: null, description: "", post_photos: [], user_avatar_url: null, num_of_subscriptions: 0, num_of_views: 0, favorited: false};
  	Post.getPost(postId, GeoLocation.data)
      .then(function(post) {
        $scope.post = post;
        $scope.post.description = $sce.trustAsHtml(post.description);
        $scope.safeUrl = encodeURIComponent($location.absUrl());
        $scope.safeTitle = encodeURIComponent($scope.post.title);
        $scope.isLoading = false;
        $rootScope.setTitle(post.title);
      }, function(message) {
        Alerts.add('danger', message);
        $scope.isLoading = false;
      });

    var loadComments = function() {
      PostComment.getComments(postId)
        .then(function(comments) {
          $scope.comments = comments;
          $scope.isLoadingComments = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoadingComments = false;
        });
    };

    loadComments();

    $scope.postComment = function() {
      $scope.isPostingComment = true;
      PostComment.addComment($scope.post.id, $scope.myComment.newComment)
        .then(function(subscription) {
          $scope.isPostingComment = false;
          $scope.myComment.newComment = "";
          loadComments();
          Alerts.add('success', I18n.t("post.comment_added"));
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isPostingComment = false;
        });
    };

    $scope.subscribe = function() {
      if ($rootScope.session.connected) {
        $scope.subscribing = true;
        PostCategorySubscription.subscribe($scope.post.category_id)
          .then(function(subscription) {
            $scope.subscribing = false;
            $scope.post.category_subscribed = true;
            $scope.post.category_subscription_id = subscription.id;
            Alerts.add('success', I18n.t("post.subscribed", {category: $scope.post.category_name}));
          }, function(message) {
            Alerts.add('danger', message);
            $scope.subscribing = false;
          });
      } else {
        askToSignin($uibModal, $rootScope);
      }
    };

    $scope.unsubscribe = function() {
      $scope.subscribing = true;
      PostCategorySubscription.unsubscribe($scope.post.category_subscription_id)
        .then(function() {
          $scope.subscribing = false;
          $scope.post.category_subscribed = false;
          $scope.post.category_subscription_id = -1
          Alerts.add('success', I18n.t("post.unsubscribed", {category: $scope.post.category_name}));
        }, function(message) {
          Alerts.add('danger', message);
          $scope.subscribing = false;
        });
    };

    $scope.subscribeAuthor = function() {
      if ($rootScope.session.connected) {
        if ($scope.post.user_nickname == $rootScope.session.user.pretty_name) {
          $scope.tooltip.showSelfSubscribeTooltip = true;
          $timeout( function() {
            $scope.tooltip.showSelfSubscribeTooltip = false;
          }, 2000);
          return;
        }
        $scope.author_subscribing = true;
        PostAuthorSubscription.subscribe($scope.post.user_nickname)
          .then(function(subscription) {
            $scope.author_subscribing = false;
            $scope.post.author_subscribed = true;
            $scope.post.author_subscription_id = subscription.id;
            $scope.post.num_of_subscriptions++;
            Alerts.add('success', I18n.t("post.author_subscribed", {author: $scope.post.user_nickname}));
          }, function(message) {
            Alerts.add('danger', message);
            $scope.author_subscribing = false;
          });
      } else {
        askToSignin($uibModal, $rootScope);
      }
    }

    $scope.unsubscribeAuthor = function() {
      $scope.author_subscribing = true;
      PostAuthorSubscription.unsubscribe($scope.post.author_subscription_id)
        .then(function() {
          $scope.author_subscribing = false;
          $scope.post.author_subscribed = false;
          $scope.post.num_of_subscriptions--;
          Alerts.add('success', I18n.t("post.author_unsubscribed", {author: $scope.post.user_nickname}));
        }, function(message) {
          Alerts.add('danger', message);
          $scope.author_subscribing = false;
        });
    };

    $scope.addToFavorites = function() {
      if ($rootScope.session.connected) {
        $scope.adding_to_favorites = true;
        FavoritePosts.addToFavorites($scope.post.id)
          .then(function(favorite_post_id) {
            $scope.adding_to_favorites = false;
            $scope.post.favorited = true;
            $scope.post.favorite_post_id = favorite_post_id;
            $scope.post.num_of_favorited++;
            Alerts.add('success', I18n.t("post.favorited"));
          }, function(message) {
            Alerts.add('danger', message);
            $scope.adding_to_favorites = false;
          });
      } else {
      askToSignin($uibModal, $rootScope);
      }
    }

    $scope.removeFromFavorites = function() {
      $scope.adding_to_favorites = true;
      FavoritePosts.removeFromFavorites($scope.post.favorite_post_id)
        .then(function() {
          $scope.adding_to_favorites = false;
          $scope.post.favorited = false;
          $scope.post.num_of_favorited--;
          Alerts.add('success', I18n.t("post.unfavorited"));
        }, function(message) {
          Alerts.add('danger', message);
          $scope.adding_to_favorites = false;
        });
    };

    $scope.likeComment = function(comment) {
      if ($rootScope.session.connected) {
        currentComment = comment;
        currentComment.liking_comment = true;
        FavoritePostComments.addToFavorites(comment.id)
          .then(function(favorite_post_comment_id) {
            currentComment.liking_comment = false;
            currentComment.liked = true;
            currentComment.num_of_likes++;
            currentComment.favorite_post_comment_id = favorite_post_comment_id;
          }, function(message) {
            Alerts.add('danger', message);
            currentComment.liking_comment = false;
          });
      } else {
      askToSignin($uibModal, $rootScope);
      }
    }

    $scope.unlikeComment = function(comment) {
      currentComment = comment;
      currentComment.liking_comment = true;
      FavoritePostComments.removeFromFavorites(currentComment.favorite_post_comment_id)
        .then(function() {
          currentComment.liking_comment = false;
          currentComment.liked = false;
          currentComment.num_of_likes--;
          currentComment.favorite_post_comment_id = -1;
        }, function(message) {
          Alerts.add('danger', message);
          currentComment.liking_comment = false;
        });
    };

    $scope.report = function() {
      var modalInstance = $uibModal.open({
        templateUrl: 'modals/report-classified-ad-modal.html',
        controller: 'ReportClassifiedAdModalController',
        resolve: {
          confirmTitle: function () {
            return I18n.t("post.report_title"); 
          },
          confirmText: function () {
            return I18n.t("post.report_text");
          },
          confirmLabel: function () {
            return I18n.t("post.report");
          },
          cancelLabel: function () {
            return I18n.t("post.cancel_label");
          }
        }
      });
      modalInstance.result.then(function (reason) {
        Post.report(postId, reason)
          .then(function() {
            Alerts.add('success', I18n.t("post.reported_success"));
          }, function(message) {
            Alerts.add('danger', message);
          });
      }, function () {
        // $scope.updatingClassified[adId] = false;
      });
    };
    
    $rootScope.$on('load-comments', function(event, args) {
      loadComments();
    });
  };