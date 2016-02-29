$window = null

angoolar.addDirective class WhenAtViewCenter extends angoolar.BaseDirective
	$_name: 'WhenAtViewCenter'

	scope:
		whenAtViewCenter: '&' + @::$_makeName()
		centered        : '=?'
		offset          : '=?'

	$_dependencies: [ '$window' ]

	constructor: ->
		super

		$window = angular.element @$window

	controller: class WhenAtViewCenterController extends angoolar.BaseDirectiveController
		$_name: 'WhenAtViewCenterController'

		$_dependencies: [
			angoolar.FastScroll
			angoolar.State
		]

		constructor: ->
			super

			debouncedDigest = _.throttle @updateCentered, 250

			@FastScroll.bindScrollTop debouncedDigest
			@$scope.$on '$destroy', =>
				@FastScroll.unbindScrollTop debouncedDigest

			setTimeout debouncedDigest, 250

			@$scope.$watch 'centered', ( centered ) =>
				@$scope.whenAtViewCenter() if centered

		updateCentered: =>
			elementDimensions = @$element[ 0 ].getBoundingClientRect()

			state =
				top   : elementDimensions.top - @State.stickyAreasHeight
				right : elementDimensions.right
				bottom: elementDimensions.bottom
				left  : elementDimensions.left
				width : $window[ 0 ].innerWidth
				height: $window[ 0 ].innerHeight

			@$scope.$evalAsync => @$scope.centered = state.top < ( ( state.height / 2 ) - ( @$scope.offset || 0 ) ) && state.right > ( @$scope.offset || 0 ) && state.bottom > ( @$scope.offset || 0 ) && state.left < ( state.width - ( @$scope.offset || 0 ) )
