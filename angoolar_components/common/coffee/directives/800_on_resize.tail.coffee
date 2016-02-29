angoolar.addDirective class OnResize extends angoolar.BaseDirective
	$_name: 'OnResize'

	$_dependencies: [ '$parse', '$injector', '$window' ]

	# evaluates the directive attribute with locals of 'width' and 'height' as the pixel count of the element's width and height

	link: ( $scope, $element, $attrs ) ->
		super

		onResizeGetter = @$parse $attrs[ @$_makeName() ]

		# unless angoolar.isBrowser.Mobile
		onResize = -> $scope.$evalAsync ->
			rect = $element[ 0 ].getBoundingClientRect()
			onResizeGetter $scope,
				width : rect.width
				height: rect.height
				top   : rect.top
				left  : rect.left

		$window = angular.element @$window
		$window.bind 'resize', onResize

		$scope.$on 'resize', onResize
		$scope.$on '$_imgLoaded', onResize

		$scope.$on '$destroy', -> $window.unbind 'resize', onResize

		setTimeout onResize, 100
