angoolar.addDirective class FormErrors extends angoolar.BaseTemplatedDirective
	$_name: 'FormErrors'

	scope:
		form                   : '=' + @::$_makeName()
		getFieldLabel          : '&'
		excludeIf              : '&'
		errorLabelByToken      : '=?'
		pluralErrorLabelByToken: '=?'

	controller: class FormErrorsController extends angoolar.BaseDirectiveController
		$_name: 'FormErrorsController'

		errorLabelByToken:
			# custom error tokens
			maxEncodedHtmlLength: 'Text too long'
			minAge              : 'Not old enough'
			matching            : "Field doesn't match"
			# built-in error tokens
			email        : 'Invalid email'
			max          : 'Number too large'
			maxlength    : 'Text too long'
			min          : 'Number too small'
			minlength    : 'Text too short'
			number       : 'Invalid number'
			pattern      : 'Invalid pattern'
			required     : 'Remaining item'
			url          : 'Invalid URL'
			date         : 'Invalid date'
			datetimelocal: 'Invalid local date/time'
			time         : 'Invalid time'
			week         : 'Invalid week'
			month        : 'Invalid month'

		pluralErrorLabelByToken:
			# custom error tokens
			maxEncodedHtmlLength: 'Text fields too long'
			minAge              : 'Not old enough'
			matching            : "Fields don't match"
			# built-in error tokens
			email        : 'Invalid emails'
			max          : 'Numbers too large'
			maxlength    : 'Text fields too long'
			min          : 'Numbers too small'
			minlength    : 'Text fields too short'
			number       : 'Invalid numbers'
			pattern      : 'Invalid patterns'
			required     : 'Remaining items'
			url          : 'Invalid URLs'
			date         : 'Invalid dates'
			datetimelocal: 'Invalid local dates/times'
			time         : 'Invalid times'
			week         : 'Invalid weeks'
			month        : 'Invalid months'

		constructor: ->
			super

			@class = @$attrs.class
			@$element.attr 'class', ''

			@errorLabelByToken = angular.extend {}, @errorLabelByToken, @$scope.errorLabelByToken
			@pluralErrorLabelByToken = angular.extend {}, @pluralErrorLabelByToken, @$scope.pluralErrorLabelByToken

		filterField: ( field ) => not @$scope.excludeIf field: field
