angular
  .module('uneo.controllers')
  .controller(
    'PostsController',
    ['$rootScope', '$scope', '$state', '$sce', '$filter', '$location', '$mdMedia', '$timeout', '$uibModal', 'Post', 'PostAuthorSubscription', 'FavoritePosts', 'GeoLocation', 'Alerts', 'Deal', PostsController]
  );

  function PostsController($scope, $rootScope, $state, $sce, $filter, $location, $mdMedia, $timeout, $uibModal, Post, PostAuthorSubscription, FavoritePosts, GeoLocation, Alerts, Deal) {

    loadHtml5LightBox("assets");

    $rootScope.setTitle(I18n.t('posts.title'));
  	$scope.isLoading = true;
  	$scope.posts = [];
    $scope.filter = { page: 0 };
    var location = {};
    if ($state.params.sort) {
      $scope.filter.sort = $state.params.sort;
    } else {
      $scope.filter.sort = "most_recent";
    }
    if ($state.params.time && $scope.filter.sort != "most_recent") {
      $scope.filter.time = $state.params.time;
    } else {
      $scope.filter.time = "all";
    }
    // if ($state.params.type) {
    //   $scope.filter.type = $state.params.type;
    // } else {
    //   $scope.filter.type = "all";
    // }
    if ($state.params.search) {
      $scope.filter.search = $state.params.search;
    } else {
      $scope.filter.search = null;
    }
    $scope.filter.category = $state.params.category;
    $scope.filter.premium = $state.params.premium;
    $scope.filter.zone = $state.params.zone;
    $scope.hasMorePosts = true;

    var currentPost;

    $scope.isOptionsCollapsed = $mdMedia('xs');

    $scope.convertDescription = function(desc) {
      return $sce.trustAsHtml( desc );
    };

    $scope.onCategoryChanged = function(category) {
      $scope.updateFilter('category', category.id)
    };

    $scope.search = function() {
      $scope.filter.page = 0;
      $scope.posts = [];
      $scope.loadPosts();
    }

    $scope.refreshPosts = function() {
      $scope.filter.page = 0;
      $scope.posts = [];
      $scope.filter.search = "";
      $scope.loadPosts();
    }

    GeoLocation.getLocation()
      .then(function(geoData) {
        location.latitude = geoData.latitude;
        location.longitude = geoData.longitude;
        $scope.loadPosts();
      }, function(message) {
      });

    $scope.loadPosts = function() {
      $location.search( 'sort', $scope.filter.sort );
      if ($scope.filter.sort == "most_recent") {
        $scope.filter.time = 'all';
      }
      $location.search( 'time', $scope.filter.time );
      $location.search( 'category', $scope.filter.category );
      $location.search( 'premium', $scope.filter.premium );
      $location.search( 'zone', $scope.filter.zone );
      if ($scope.filter.search && $scope.filter.search != '') {
        $location.search( 'search', $scope.filter.search );
      } else {
        $location.search( 'search', null );
      }
      $scope.isLoading = true;
      $scope.filter.page++;

      Post.getAll($.extend({}, $scope.filter, location))
        .then(function(posts) {
          $scope.hasMorePosts = posts.length > 0;
          $scope.posts = $scope.posts.concat(posts);
          $scope.isLoading = false;
        }, function(message) {
          Alerts.add('danger', message);
          $scope.isLoading = false;
        });
    };

    $scope.updateFilter = function(type, option) {
      if (type == 'all') {
        $scope.filter.category = null;
        $scope.filter.premium = null;
        $scope.filter.zone = null;
      } else {
        if (option != false) {
          $scope.filter[type] = option;
        } else {
          $scope.filter[type] = null;
        }
      }
      $scope.refreshPosts();
    };

    var updateNumOfSubscriptions = function(post, subscribed, subscriptionId) {
      angular.forEach($filter('filter')($scope.posts, {user_nickname: post.user_nickname}, true), function(value) {
        value.num_of_subscriptions = value.num_of_subscriptions + (subscribed ? 1 : -1);
        value.author_subscribed = subscribed;
        value.author_subscription_id = subscriptionId;
      });
    };

    $scope.subscribeAuthor = function(post) {
      if ($rootScope.session.connected) {
        if (post.user_nickname == $rootScope.session.user.pretty_name) {
          post.showSelfSubscribeTooltip = true;
          $timeout( function() {
            post.showSelfSubscribeTooltip = false;
          }, 2000);
          return;
        }
        currentPost = post;
        currentPost.author_subscribing = true;
        PostAuthorSubscription.subscribe(currentPost.user_nickname)
          .then(function(subscription) {
            currentPost.author_subscribing = false;
            updateNumOfSubscriptions(currentPost, true, subscription.id);
            Alerts.add('success', I18n.t("post.author_subscribed", {author: currentPost.user_nickname}));
          }, function(message) {
            Alerts.add('danger', message);
            currentPost.author_subscribing = false;
          });
      } else {
        askToSignin($uibModal, $rootScope);
      }
    };

    $scope.unsubscribeAuthor = function(post) {
      currentPost = post;
      $scope.author_subscribing = true;
      PostAuthorSubscription.unsubscribe(currentPost.author_subscription_id)
        .then(function() {
          currentPost.author_subscribing = false;
          updateNumOfSubscriptions(currentPost, false, -1);
          Alerts.add('success', I18n.t("post.author_unsubscribed", {author: currentPost.user_nickname}));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.author_subscribing = false;
        });
    };

    $scope.addToFavorites = function(post) {
      if ($rootScope.session.connected) {
        currentPost = post;
        currentPost.adding_to_favorites = true;
        FavoritePosts.addToFavorites(post.id)
          .then(function(favorite_post_id) {
            currentPost.adding_to_favorites = false;
            currentPost.favorited = true;
            currentPost.num_of_favorited++;
            currentPost.favorite_post_id = favorite_post_id;
            Alerts.add('success', I18n.t("post.favorited"));
          }, function(message) {
            Alerts.add('danger', message);
            currentPost.adding_to_favorites = false;
          });
        } else {
          askToSignin($uibModal, $rootScope);
        }
    };

    $scope.removeFromFavorites = function(post) {
      currentPost = post;
      currentPost.adding_to_favorites = true;
      FavoritePosts.removeFromFavorites(currentPost.favorite_post_id)
        .then(function() {
          currentPost.adding_to_favorites = false;
          currentPost.favorited = false;
          currentPost.num_of_favorited--;
          currentPost.favorite_post_id = -1;
          Alerts.add('success', I18n.t("post.unfavorited"));
        }, function(message) {
          Alerts.add('danger', message);
          currentPost.adding_to_favorites = false;
        });
    };

    var latitude;
    var longitude
    var initUserData = function() {
      if ($rootScope.session.user.place != null) {
        latitude = $rootScope.session.user.place.latitude;
        longitude = $rootScope.session.user.place.longitude;
      } else if ($rootScope.session.user.addresses != null && $rootScope.session.user.addresses.length > 0) {
        latitude = $rootScope.session.user.addresses[0].latitude;
        longitude = $rootScope.session.user.addresses[0].longitude;
      } else if ($rootScope.session.location) {
        latitude = $rootScope.session.location.latitude;
        longitude = $rootScope.session.location.longitude;
      } else {
        return;
      }
      userInfoReady = true;
      $scope.loadPromotedDeals();
    };

    $scope.loadPromotedDeals = function() {
      var maxDeals = 5;
      if ($mdMedia('xs')) {
        maxDeals = 1;
      } else if ($mdMedia('sm')) {
        maxDeals = 2;
      } else if ($mdMedia('md')) {
        maxDeals = 3;
      } else {
        maxDeals = 5;
      }
      Deal.getHomepagePromotions(latitude, longitude, maxDeals)
        .then(function(deals) {
          $scope.topDeals = deals;
        }, function(message) {
          Alerts.add('danger', message);
        });
    };

    if ($rootScope.session.connected) {
      initUserData();
    }
    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });
  };