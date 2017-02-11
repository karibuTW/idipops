angular
  .module('uneo.controllers')
  .controller('ProProfileController',[
    '$scope', '$rootScope', '$state', '$filter', '$timeout', '$uibModal', '$sce', 'Alerts',
    'Professionals', 'Profession', 'SocketMessages', 'uiGmapIsReady',
    'uiGmapGoogleMapApi', 'Deal', 'FavoriteProfessionals',
    'ProfessionalRatings', 'ProfessionalReviews', 'Post', ProProfileController
    ]  
  )

function ProProfileController($scope, $rootScope, $state, $filter, $timeout, $uibModal, $sce,
  Alerts, Professionals, Profession, SocketMessages, uiGmapIsReady, uiGmapGoogleMapApi,
  Deal, FavoriteProfessionals, ProfessionalRatings, ProfessionalReviews, Post) {
  $scope.isLoading = true;
  $scope.isPosting = false;
  // $scope.canPost = $rootScope.isMessagingAvailable;
  $scope.isRating = false;
  $scope.isPostingReview = false;
  $scope.minNumReviews = 3;
  $scope.messageReply = {newConversation: ''};
  $scope.mapOptions = { draggable: false, disableDoubleClickZoom: true, scrollwheel: false };
  $scope.posts = [];
  $scope.selectedTab = 0;
  $scope.postsAreLoading = true;
  $scope.deals = [];
  var professionId = $state.params.pid;
  var mapInstances = [];
  var postsPage = 0;

  var loadReviews = function() {
    ProfessionalReviews.getReviews($scope.pro.id)
      .then(function(reviews) {
        $scope.reviews = reviews;
      }, function(message) {
        Alerts.add('danger', message);
      });
  };

  var loadPosts = function() {
    $scope.postsAreLoading = true;
    postsPage++;
    Post.getAll({proid: professionId, page: postsPage})
      .then(function(posts) {
        $scope.hasMorePosts = posts.length > 0;
        $scope.posts = $scope.posts.concat(posts);
        $scope.postsAreLoading = false;
      }, function(message) {
        Alerts.add('danger', message);
        $scope.postsAreLoading = false;
      });
  };

  $scope.convertDescription = function(desc) {
    return $sce.trustAsHtml( desc );
  };

  $scope.rate = function() {
    if (!$scope.isRating) {
      $scope.isRating = true;
      ProfessionalRatings.rate($scope.pro.id, $scope.pro.user_rating)
        .then(function(newRating) {
          $scope.pro.rating = newRating;
          $scope.isRating = false;
        }, function(message) {
          $scope.isRating = false;
          Alerts.add('danger', message);
        });
    }
  };

  $scope.postReview = function() {
    if (!$scope.isPostingReview) {
      $scope.isPostingReview = true;
      ProfessionalReviews.addReview($scope.pro.id, $scope.pro.user_review)
        .then(function() {
          $scope.isPostingReview = false;
          loadReviews();
          Alerts.add('success', I18n.t("pro_profile.comment_sent"));
        }, function(message) {
          $scope.isPostingReview = false;
          Alerts.add('danger', message);
        });
    }
  }

  var setActivities = function() {
    if ($scope.professions != null && $scope.pro) {
      $scope.activities = getActivitiesForPro($scope.pro, $scope.professions, $filter);
      $rootScope.setTitle($scope.pro.display_name + ", " + $scope.activities.primaryActivity);
    }
  }

  $scope.sendMessage = function () {
    if ($scope.isPosting){
      return;
    }
    $scope.isPosting = true;
    var conversationData = { message: {content: $filter('htmlToPlaintext')($scope.messageReply.newConversation)}, user_id: professionId };
    SocketMessages.postMessage(conversationData,
      function() {
        Alerts.add('success', I18n.t("conversations.message_sent"));
        $scope.messageReply.newConversation = '';
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

  var refreshMap = function() {
    if ($scope.pro != null) {
      adjustBounds();
    }
  }

  $scope.circleStroke = { color: '#ffa727', weight: 2, opacity: 1 }
  $scope.circleFill = { color: '#ffa727', weight: 2, opacity: 0.3 }

  uiGmapGoogleMapApi.then(function(maps) {
    Professionals.getById(professionId)
      .then(function(professional) {
        var currWeekday = (new Date()).getDay();
        professional.addresses_by_line = [];
        for (var i = 0; i < professional.addresses.length; i++) {
          var address = professional.addresses[i];
          address.lines = address.formatted_address.split(", ");
          address.current_day_opening_hours = [];
          var wdays = I18n.t("date.day_names");
          var weekOpeningHours = [[wdays[1],[]],[wdays[2],[]],[wdays[3],[]],[wdays[4],[]],[wdays[5],[]],[wdays[6],[]],[wdays[0],[]]];
          for (var j = 0,_len = address.opening_hours.length; j < _len; j++) {
            var oh = address.opening_hours[j];
            if(oh.days !== null && oh.days.length > 0 & oh.period !== '') {
              var days = oh.days;
              // oh.period.open_raw = (new Date(oh.period.open)).getHours() + ":" + (new Date(oh.period.open)).getMinutes();
              oh.period.open_raw = $filter('date')(oh.period.open, "shortTime");
              oh.period.close_raw = $filter('date')(oh.period.close, "shortTime");
              if(days[currWeekday - 1] && days[currWeekday - 1].value === true) {
                  address.current_day_opening_hours.push(oh);
              }
              for(var _j = 0;_j < 7;_j++){
                if(days[_j].value === true){
                  weekOpeningHours[_j][1].push(oh.period.open_raw + "-" + oh.period.close_raw);
                }
              }
            }
          }
          address.weekOpeningHours = weekOpeningHours;
          address.currWeekday = currWeekday - 1;
          address.mapControl = {};
          var distance = address.action_range * 500;
          var center = new google.maps.LatLng(
            address.latitude,
            address.longitude
          );

          var eastLimit = google.maps.geometry.spherical.computeOffset(center, distance, 90);
          var westLimit = google.maps.geometry.spherical.computeOffset(center, distance, 270);
          var northLimit = google.maps.geometry.spherical.computeOffset(center, distance, 0);
          var southLimit = google.maps.geometry.spherical.computeOffset(center, distance, 180);

          address.bounds = new google.maps.LatLngBounds(
            new google.maps.LatLng(southLimit.lat(),
            westLimit.lng()),
            new google.maps.LatLng(northLimit.lat(),
            eastLimit.lng())
          );
        }

        uiGmapIsReady.promise(professional.addresses.length).then(function(instances) {
          instances.forEach(function(inst) {
            mapInstances.push(inst.map);
          });
          $timeout( refreshMap, 100);
        });
        $scope.pro = professional;
        loadReviews();
        loadPosts();

        setActivities();
        $scope.isLoading = false;
        if (mapInstances.length > 0) {
          adjustBounds();
        }
      }, function(message) {
        $scope.isLoading = false;
        Alerts.add('danger', message);
      });
  });

  Profession.getData()
    .then(function(professions) {
      $scope.professions = professions;
      setActivities();
    }, function(message) {
      Alerts.add('danger', message);
    });

  Deal.getFromPro(professionId)
    .then(function(deals) {
      $scope.deals = deals;
    }, function(message) {
      Alerts.add('danger', message);
    });

  var adjustBounds = function() {
    for (var i=0; i<mapInstances.length; i++) {
      if ($scope.pro.addresses[i])
        $scope.pro.addresses[i].mapControl.refresh({latitude: $scope.pro.addresses[i].latitude, longitude: $scope.pro.addresses[i].longitude});
        mapInstances[i].fitBounds($scope.pro.addresses[i].bounds);
    }
  };
};