angular
  .module('uneo.controllers')
  .controller(
    'ProfileController',
    ['$rootScope', '$scope', '$state', '$timeout', '$uibModal', '$cookies', 'FileUploader', 'User', 'Alerts',
    'Profession', 'Place', 'GoogleServices', 'Tags', ProfileController]
  );

function ProfileController($rootScope, $scope, $state, $timeout, $uibModal, $cookies, FileUploader, User, Alerts, Profession, Place, GoogleServices, Tags) {
  $rootScope.setTitle('Mettez vos informations à jour');
  $scope.isSavingProfile = false;
  $scope.userInfo = { hasHourlyRate: false, newsletter: true };
  $scope.userCopy = {};
  $scope.citySearch = null;
  $scope.birthdate = { date: null, month: null, year: null };
  $scope.days = [];
  $scope.months = [ {label: "Janvier", value: 0}, {label: "Février", value: 1}, {label: "Mars", value: 2}, {label: "Avril", value: 3}, {label: "Mai", value: 4}, {label: "Juin", value: 5}, {label: "Juillet", value: 6}, {label: "Août", value: 7}, {label: "Septembre", value: 8}, {label: "Octobre", value: 9}, {label: "Novembre", value: 10}, {label: "Décembre", value: 11}];
  $scope.addAddress = addAddress;
  var photoIdsToRemove = [];
  $scope.photoUploader = new FileUploader( { queueLimit: 10, method: 'PATCH', alias: 'photo', removeAfterUpload: true } );
  $scope.photoUploader.filters.push({
      name: 'imageFilter',
      fn: function(item /*{File|FileLikeObject}*/, options) {
          var type = '|' + item.type.slice(item.type.lastIndexOf('/') + 1) + '|';
          return '|jpg|png|jpeg|bmp|gif|'.indexOf(type) !== -1;
      }
  });

  var i;
  for (i=1; i<32; i++) {
    $scope.days.push(i);
  }
  var startYear;
  var initYears = function(accountType) {
    var now = new Date();
    $scope.years = [];
    startYear = now.getFullYear() - (accountType == 'pro' ? 16 : 13);
    for (i=startYear; i>1910; i--) {
      $scope.years.push(i);
    }
  };

  var uploadOnSuccess = function() {
    $scope.isSavingProfile = false;
    if ($scope.session.user.user_type == 'pro') {
      $state.go('home.pros-dashboard');
    } else {
      $state.go('home.users-dashboard');
    }
    Alerts.add('success', I18n.t("pro_profile.changes_saved"));
  }

  $scope.photoUploader.onBeforeUploadItem = function(itemFile) {
    itemFile.url = $scope.photoUploader.url = '/api/v1/users/' + $scope.session.user.id;
    itemFile.headers = $scope.photoUploader.headers = { 'X-XSRF-TOKEN': $cookies['XSRF-TOKEN'], 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') };
  };

  $scope.photoUploader.onCompleteAll = function() {
    uploadOnSuccess();
  };

  $scope.removePhoto = function(item) {
    item.remove();
  }

  $scope.deletePhoto = function(photo) {
    // photoIdsToRemove.push(photo.id);
    $scope.userCopy.user_photos.splice($scope.userCopy.user_photos.indexOf(photo), 1);
    $scope.userCopy.photo_ids_to_remove.push(photo.id);
  }

  var initUserData = function() {
    if (angular.isDefined($scope.session.user.id)) {
      $scope.userInfo.hasHourlyRate = $scope.session.user.hourly_rate > 0;
      if ($scope.session.user.birthdate != null) {
        var birthdateArray = $scope.session.user.birthdate.split('-');
        $scope.birthdate.date = $scope.days[Number(birthdateArray[2])-1];
        $scope.birthdate.month = Number(birthdateArray[1]-1);
        initYears($scope.session.user.user_type);
        $scope.birthdate.year = $scope.years[startYear - Number(birthdateArray[0])];
      }
      angular.copy($scope.session.user, $scope.userCopy);
      if ($scope.userCopy.place != null)
        $scope.citySearch = $scope.userCopy.place.place_name;
      if ($scope.userCopy.addresses != null && $scope.userCopy.addresses.length == 0) {
        $scope.addAddress();
      }
      $scope.userCopy.photo_ids_to_remove = [];
    }
  };
  if ($scope.session.connected) {
    initUserData();
  }
  $rootScope.$on('user-loaded', function(event, args) {
    initUserData();
  });

  $scope.removeAddress = function(index) {
    var modalInstance;
    if ($scope.userCopy.addresses != null) {
      modalInstance = $uibModal.open({
        templateUrl: 'modals/confirm-modal.html',
        controller: 'ConfirmModalController',
        resolve: {
          confirmTitle: function () {
            return I18n.t("pro_profile.remove_address_title");
          },
          confirmText: function () {
            return I18n.t("pro_profile.remove_address_text", {address: $scope.userCopy.addresses[index].formatted_address});
          },
          confirmLabel: function () {
            return I18n.t("pro_profile.confirm_delete_label");
          },
          cancelLabel: function () {
            return I18n.t("pro_profile.cancel_delete_label");
          }
        }
      });
    }
    modalInstance.result.then(function () {
      $scope.userCopy.addresses.splice(index, 1);
      Alerts.add('success', I18n.t("pro_profile.remove_address_success"));
    }, function () {

    });

  };

  function addAddress() {
    $scope.userCopy.addresses.push({
      formatted_address: "",
      action_range: 10,
      place_id: null,
      latitude: 0,
      longitude: 0,
      opening_hours: []
    });
  };

  $scope.updateAddress = function(item, model, index) {
    $scope.userCopy.addresses[index] = item;
  };

  $scope.enableActivity = function(activity) {
    $scope.userCopy[activity] = -1;
  };

  $scope.disableActivity = function(activity) {
    $scope.userCopy[activity] = null;
  };

  $scope.onPrimaryActivityChanged = function(profession) {
    $scope.userCopy.primary_activity_id = profession.id;
  };

  $scope.onSecondaryActivityChanged = function(profession) {
    $scope.userCopy.secondary_activity_id = profession.id;
  };

  $scope.onTertiaryActivityChanged = function(profession) {
    $scope.userCopy.tertiary_activity_id = profession.id;
  };

  $scope.onQuaternaryActivityChanged = function(profession) {
    $scope.userCopy.quaternary_activity_id = profession.id;
  };

  $scope.getNickname = function() {
    if (!$scope.userCopy.pretty_name || $scope.userCopy.pretty_name == "") {
      User.getPossibleNickanme($scope.userCopy.company_name)
        .then(function(pretty_name) {
          $scope.userCopy.pretty_name = pretty_name;
        }, function() {
          // Alerts.add('danger', message);
        });
      }
  };

  $scope.toggleHourlyRate = function() {
    if ($scope.userInfo.hasHourlyRate) {
      $scope.userCopy.hourly_rate = 10;
    } else {
      $scope.userCopy.hourly_rate = -1;
    }
  };
  // $scope.searchDepartements = function(query) {
  //   return Place.searchDepartements(query);
  // };
  $scope.searchCities = function(query) {
    return Place.searchCities(query);
  };
  $scope.searchAddresses = function(query) {
    return GoogleServices.searchPlaces(query);
  };
  $scope.searchTags = function(query) {
    return Tags.search(query);
  };

  $scope.checkTagLimit = function() {
    return $scope.userCopy.tag_list.length < 15;
  };

  $scope.addOpeningHour = function(address, index) {
    var last_op = address.opening_hours[address.opening_hours.length -1],last_hour = 12;
    if(last_op !== null && last_op.period !== null && last_op.period.close !== null){
      last_hour = (new Date(last_op.period.close)).getHours();
    }
    address.opening_hours.push({
        days: [{label: 1,value: true},{label: 2,value: true},{label: 3,value: true},{label: 4,value: true},{label: 5,value: true},{label: 6,value: true},{label: 0,value: true},{label: 7, value: false}],
        period: {
          open: new Date(2015,1,1,last_hour + 1,0),
          close: new Date(2015,1,1,last_hour + 5,0)
        }
      });
  };

  $scope.removeOpeningHour = function(address, index) {
    address.opening_hours.splice(index, 1);
  };

  $scope.updateOpeningDays = function(opening_hour, index, value){
    if(index == 7){
      if( value == true){
        opening_hour.days = [{label: 1,value: true},{label: 2,value: true},{label: 3,value: true},{label: 4,value: true},{label: 5,value: true},{label: 6,value: true},{label: 0,value: true},{label: 7, value: true}]
      }else{
        opening_hour.days = [{label: 1,value: false},{label: 2,value: false},{label: 3,value: false},{label: 4,value: false},{label: 5,value: false},{label: 6,value: false},{label: 0,value: false},{label: 7, value: false}]
      }
    }else{
      opening_hour.days[7] = {label: 7,value: false};
    }
	}

  $scope.applyToOtherDays = function(source_opening_hour, address) {
    angular.forEach(address.opening_hours, function(other) {
      if(other.day !== source_opening_hour.day && other.day != 0 && other.day != 6) {
        angular.copy(source_opening_hour.period, other.period);
      }
    });
  };

 $scope.initialOpeningHours = function(destAddress) {
    destAddress.opening_hours = [];
    var opening_hours = [];
    opening_hours.push({
        days: [{label: 1,value: false},{label: 2,value: false},{label: 3,value: false},{label: 4,value: false},{label: 5,value: false},{label: 6,value: false},{label: 0,value: false},{label: 7, value: false}],
        period: {
          open: new Date(2015,1,1,8,0),
          close: new Date(2015,1,1,12,0)
        }
      });
    destAddress.opening_hours = opening_hours;
  };

  $scope.makeOpeningHoursSameAs1stAddress = function(destAddress) {
    destAddress.opening_hours = [];
    var copyOpeningHours = [];
    angular.forEach($scope.userCopy.addresses[0].opening_hours, function(oh) {
      copyOpeningHours.push({
        days: oh.days,
        period: oh.period
      });
    });
    destAddress.opening_hours = copyOpeningHours;
  };

  $scope.$watch('session.user.user_type', function(newValue, oldValue) {
    $scope.accountType = $scope.session.user.user_type || 'pro';
    initYears($scope.session.user.user_type);
  });
  Profession.getData()
    .then(function(professions) {
      $scope.professions = Profession.data.professionsForSelect;
    }, function(message) {
      Alerts.add('danger', message);
    });
  // Place.getPlacesByCode('750')
  //   .then(function(places) {
  //     console.log(places);
  //   }, function(message) {
  //     Alerts.add('danger', message);
  //   });

  $scope.saveProfile = function() {
    if ($scope.accountType == 'pro') {
      if ($scope.userCopy.addresses[0] == null || $scope.userCopy.addresses[0].place_id == null) {
        Alerts.add('danger', I18n.t("pro_profile.no_address_error"));
        return;
      }
      if (!$scope.userCopy.primary_activity_id) {
        Alerts.add('danger', I18n.t("pro_profile.no_activity_error"));
        return;
      }
    }
    $scope.isSavingProfile = true;
    $scope.userCopy.birthdate = new Date(Date.UTC($scope.birthdate.year, $scope.birthdate.month, $scope.birthdate.date));
    $scope.userCopy.user_type = $scope.accountType;
    $scope.userCopy.tag_list = transformTagsIntoArray($scope.userCopy.tag_list);
    User.saveData($scope.userCopy)
      .then(function(userData) {
        $scope.session.user = userData;
        $scope.session.user.displayName = getDisplayName($scope.session.user.user_type, $scope.session.user.company_name, $scope.session.user.first_name, $scope.session.user.last_name);
        if ($scope.photoUploader.queue.length > 0) {
          $scope.photoUploader.uploadAll();
        } else {
          uploadOnSuccess();
        }
        $rootScope.$broadcast('user-loaded');
      }, function(messages) {
        $scope.isSavingProfile = false;
        for (var i=0; i<messages.length; i++) {
          Alerts.add('danger', messages[i]);
        }
      });
  }; 
}
