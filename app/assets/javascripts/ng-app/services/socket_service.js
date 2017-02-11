angular.module('uneo.services')
	.service('SocketMessages', ['$timeout', '$location', '$rootScope', function($timeout, $location, $rootScope) {
		var host = $location.host();
		var prefix = host == 'localhost' ? host + ':3001' : host;
		var dispatcher;
		var theService = this;
		var userId;
    var channel;
    var userIdsToWatch = [];
    var mustTryToReconnectOnDisconnect = true;

    this.disconnect = function() {
    	if (dispatcher != null) {
        console.info("WebSocket: disconnecting ...");
    		mustTryToReconnectOnDisconnect = false;
    		dispatcher.disconnect();
    	}
    };

    this.connect = function(newUserId, userIdsStatusCallback, connectedUserCallback, disconnectedUserCallback, newPostCallback, newPostMentionCallback, newPostCommentCallback, newPostCommentMentionCallback, newMessageCallback, newConversationCallback, userTypingCallback, conversationReadCallback) {
      console.info("WebSocket: connecting ...");
      userId = newUserId;
      mustTryToReconnectOnDisconnect = true;
      dispatcher = new WebSocketRails( prefix + '/websocket');
      var channelName = 'user_' + userId;
      channel = dispatcher.subscribe(channelName);
      channel.bind('post_comment_mention_new', newPostCommentMentionCallback);
      channel.bind('post_mention_new', newPostMentionCallback);
      channel.bind('post_new', newPostCallback);
      channel.bind('post_comment_new', newPostCommentCallback);
  		channel.bind('message_new', newMessageCallback);
  		channel.bind('conversation_new', newConversationCallback);
  		channel.bind('users_status_updates', userIdsStatusCallback);
  		channel.bind('user_status_connected', connectedUserCallback);
  		channel.bind('user_status_disconnected', disconnectedUserCallback);
      channel.bind('user_is_typing', userTypingCallback);
      channel.bind('conversation_read_update', conversationReadCallback);
  		dispatcher.bind('connection_closed', function() {
        console.info("WebSocket: connection closed");
  	    $rootScope.$broadcast('socket-connexion', { connected: false, mustReconnect: mustTryToReconnectOnDisconnect });
  		});
  		dispatcher.on_open = function(data) {
        console.info("WebSocket: connection opened");
        $rootScope.$broadcast('socket-connexion', { connected: true });
				dispatchGetUsersStatus();
			}
    };

    this.sendIsTypingMessage = function(conversationId, isTyping, successCallback, errorCallback) {
        dispatcher.trigger('is_typing', { conversation_id: conversationId, is_typing: isTyping},
        function(response) {
          successCallback();
        },
        function(error) {
          errorCallback();
        } );
    };

    this.notifyConversationRead = function(userId, conversationId) {
    	dispatcher.trigger('conversation_read', { user_id: userId, conversation_id: conversationId},
    		function(response) {
	    		// successCallback(response.new_count);
	    	},
	    	function(error) {
	    		
	    	} );
    };

    this.getUsersOnlineStatus = function(userIds) {
    	userIdsToWatch = userIds;
    	if (dispatcher.state == 'connected') {
    		dispatchGetUsersStatus();
    		userIdsToWatch = [];
    	}
    };

    var dispatchGetUsersStatus = function() {
    	if (userIdsToWatch.length > 0) {
        dispatcher.trigger('watch_users_status', { user_ids: userIdsToWatch} );
      }
    };

    this.postMessage = function(messageData, successCallback, errorCallback) {
    	dispatcher.trigger('post_message', messageData,
    		function(response) {
	    		if (response.status == 'created') {
	    			successCallback(response.id);
	    		} else {
	    			errorCallback();
	    		}
	    	},
	    	function(error) {
          console.log(error);
	    		errorCallback();
	    	});
    };
	}]);