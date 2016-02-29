angoolar.addDirective class ScrollToWhen extends angoolar.BaseDirective
	$_name: 'ScrollToWhen'

	$_dependencies: [ '$parse', '$timeout', angoolar.State, angoolar.FastScroll ]

	link: ( $scope, $element, $attrs ) =>
		super

		getScrollToWhen = @$parse $attrs[ @$_makeName() ]

		shouldScrollTo = no
		unwatch = null

		$scope.$on '$destroy', -> unwatch?()

		$scope.$watch ( -> getScrollToWhen $scope ), ( scrollToWhen ) =>
			shouldScrollTo = scrollToWhen

			if shouldScrollTo
				@FastScroll.scrollTopTo $element[ 0 ]
			else
				unwatch?()
