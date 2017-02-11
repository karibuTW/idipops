angular
  .module('uneo.controllers')
  .controller(
    'PostPostController',
    ['$rootScope', '$scope', '$state', '$filter', '$cookies', 'FileUploader', 'Alerts', 'Post', 'Pricings', PostPostController]
  );

  function PostPostController($scope, $rootScope, $state, $filter, $cookies, FileUploader, Alerts, Post, Pricings) {
    $rootScope.setTitle(I18n.t('post.post.title'));
  	var photoIdsToRemove = [];
    var postId = $state.params.poid;
    var postSlug;
    if (postId) {
      $scope.mode = "edit";
    } else {
      $scope.mode = "create";
    }
    $scope.photoUploader = new FileUploader( { queueLimit: 10, method: 'PATCH', alias: 'photo', removeAfterUpload: true } );
    $scope.featuredImageUploader = new FileUploader( { queueLimit: 1, method: 'PATCH', alias: 'featured_image', removeAfterUpload: true } );
    var imageFilter = {
      name: 'imageFilter',
      fn: function(item /*{File|FileLikeObject}*/, options) {
          var type = '|' + item.type.slice(item.type.lastIndexOf('/') + 1) + '|';
          return '|jpg|png|jpeg|bmp|gif|'.indexOf(type) !== -1;
      }
    }
    $scope.photoUploader.filters.push(imageFilter);
    $scope.featuredImageUploader.filters.push(imageFilter);
    $scope.sponsoringCost = 0;
    $scope.isPosting = false;
    $scope.newPost = { title: "", description: "", type: "", sponsoring: false, sponsored_impressions: 0 };

    $scope.photoUploader.onBeforeUploadItem = function(itemFile) {
      itemFile.url = $scope.photoUploader.url = '/api/v1/posts/' + postId;
      itemFile.headers = $scope.photoUploader.headers = { 'X-XSRF-TOKEN': $cookies['XSRF-TOKEN'], 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') };
    };

    $scope.photoUploader.onCompleteAll = function() {
      uploadOnSuccess();
    };

    $scope.removePhoto = function(item) {
      item.remove();
    };

    $scope.deletePhoto = function(photo) {
      photoIdsToRemove.push(photo.id);
      $scope.newPost.post_photos.splice($scope.newPost.post_photos.indexOf(photo), 1);
    };

    var uploadOnSuccess = function() {
      $scope.isPosting = false;
      $state.go('posts.show', { poid: postSlug});
      Alerts.add('success', I18n.t("post.post_published"));
    };

    $scope.featuredImageUploader.onBeforeUploadItem = function(itemFile) {
      itemFile.url = $scope.photoUploader.url = '/api/v1/posts/' + postId;
      itemFile.headers = $scope.photoUploader.headers = { 'X-XSRF-TOKEN': $cookies['XSRF-TOKEN'], 'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content') };
    };

    $scope.featuredImageUploader.onCompleteAll = function() {
      if ($scope.photoUploader.queue.length > 0) {
        $scope.photoUploader.uploadAll();
      } else {
        uploadOnSuccess();
      }
    };

    $scope.onCategoryChanged = function(category) {
      $scope.newPost.category_id = category.id;
    };

    $scope.editorConfig = {
      sanitize: true,
      toolbar: [
        { name: 'basicStyling', items: ['bold', 'italic', 'underline', 'strikethrough', 'subscript', 'superscript', '-', 'leftAlign', 'centerAlign', 'rightAlign', 'blockJustify', '-'] },
        { name: 'paragraph', items: ['orderedList', 'unorderedList', 'outdent', 'indent', '-'] },
        { name: 'doers', items: ['removeFormatting', 'undo', 'redo', '-'] },
        { name: 'colors', items: ['fontColor', 'backgroundColor', '-'] },
        { name: 'links', items: ['symbols', 'link', 'unlink', '-'] },
        { name: 'styling', items: ['size', 'format'] },
      ]
    };

  	$scope.postPost = function() {
      if (!$scope.isPosting) {
        $scope.isPosting = true;
        if ($scope.mode == 'create') {
          Post.postPost( { description: $scope.newPost.description, featured_image: $scope.newPost.featuredImage, title: $scope.newPost.title, post_type: $scope.newPost.post_type, post_category_id: $scope.newPost.category_id, post_sponsoring: $scope.newPost.sponsoring })
            .then(function(post) {
              postId = post.id;
              postSlug = post.slug;
              if ($scope.featuredImageUploader.queue.length > 0) {
                $scope.featuredImageUploader.uploadAll();
              } else {
                $scope.featuredImageUploader.onCompleteAll();
              }
            }, function(messages) {
              $scope.isPosting =  false;
              for (var i=0; i<messages.length; i++) {
                Alerts.add('danger', messages[i]);
              }
            });
        } else {
          Post.updatePost( postId, { description: $scope.newPost.description, featured_image: $scope.newPost.featuredImage, title: $scope.newPost.title, post_type: $scope.newPost.post_type, post_category_id: $scope.newPost.category_id, photo_ids_to_remove: photoIdsToRemove, post_sponsoring: $scope.newPost.sponsoring })
          .then(function(post) {
            if ($scope.featuredImageUploader.queue.length > 0) {
              $scope.featuredImageUploader.uploadAll();
            } else {
              $scope.featuredImageUploader.onCompleteAll();
            }
          }, function(messages) {
            $scope.isPosting =  false;
            for (var i=0; i<messages.length; i++) {
              Alerts.add('danger', messages[i]);
            }
          });
        }
      }
    };

    var initUserData = function() {
      if ($rootScope.session.user.user_type == 'pro') {
        Pricings.getPostPricings()
          .then(function(pricings) {
            if (pricings.length > 0)
              $scope.sponsoringCost = pricings[0].credit_amount;
          }, function(message) {
            Alerts.add('danger', message);
          });
      }
      if ($scope.mode == "edit") {
        $scope.isLoading = true;
        Post.getPost(postId)
          .then(function(post) {
            $scope.isLoading = false;
            $scope.newPost = post;
            postSlug = post.slug;
            // setTitle($rootScope, $scope.singleAd.title, $scope.session.user.unread_conversations_count, Analytics);
          }, function(message) {
            $scope.isLoading = false;
            Alerts.add('danger', message);
          });
      }
    }

    if ($rootScope.session.connected) {
      initUserData();
    }
    $rootScope.$on('user-loaded', function(event, args) {
      initUserData();
    });
};