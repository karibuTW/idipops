angular.module('uneo.services')
	.service('QuotationRequestTemplates', ['$http', '$q', function($http, $q){
		var theService = this;
		this.defaultModelFields = { title: "", description: "", startDate: null, place: null, public: false };
		var preDefaultFields = [
										{
				              key: 'title',
				              type: 'horizontalInput',
				              templateOptions : {
				                label: 'Titre',
				                required: true,
				                type: 'text'
				              }
				            },
				            {
				              key: 'description',
				              type: 'horizontalTextArea',
				              templateOptions : {
				                label: 'Description',
				                required: true,
				                rows: 5,
				                maxlength: 255
				              }
				            },
				            {
				              key: 'place',
				              type: 'locationTypeahead',
				              templateOptions : {
				                label: 'Ville',
				                required: true
				              },
				              controller: ['$scope', 'Place', function($scope, Place) {
				                $scope.to.searchCities = function(query) {
				                  return Place.searchCities(query);
				                };
				              }]
				            }
									];
		var postDefaultFields = [
										{
				              key: 'startDate',
				              type: 'datepicker',
				              templateOptions : {
				                label: 'Date de début',
				                type: 'text'
				              },
				              controller: ['$scope', function($scope) {
				                $scope.to.minDate = new Date();
				                $scope.to.isCalendarOpened = false;
				                $scope.to.dateOptions = { startingDay: 1 };
				                $scope.to.openCalendar = function($event) {
				                  $event.preventDefault();
				                  $event.stopPropagation();
				                  $scope.to.isCalendarOpened = true;
				                };
				              }]
				            }
									];
		this.getTemplatebyId = function(id) {
			var deferred = $q.defer();
			$http.get( '/api/v1/quotation_request_templates/' + id)
				.success(function(dataReturned, status) {
					var template = { fields: preDefaultFields.concat(angular.fromJson(dataReturned.quotation_request_template.fields), postDefaultFields), model: angular.extend(angular.fromJson(dataReturned.quotation_request_template.model), theService.defaultModelFields) };
    			deferred.resolve(template);
				})
				.error(function(dataReturned, status) {
					deferred.reject('Le chargement du formulaire de devis a échoué.');
				});
			return deferred.promise;
		};
	}])
;