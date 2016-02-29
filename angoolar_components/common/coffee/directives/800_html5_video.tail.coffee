angoolar.addDirective class angoolar.Html5Video extends angoolar.BaseDirective
	$_name: 'video'

	$_prefix: null

	restrict: 'E'

	link: ( $scope, $element, $attrs ) =>
		super

		if $attrs.autoplay isnt undefined
			isPausedGetter = null
			$attrs.$observe 'isPaused', ( isPaused ) => isPausedGetter = @$parse isPaused
			$scope.$watch ( -> isPausedGetter? $scope ), ( isPaused ) =>
				$element[ 0 ][ if isPaused then 'pause' else 'play' ]?()

		if ( angoolar.isBrowser.IE or angoolar.isBrowser.Firefox ) and ( $attrs.muted? and $attrs.muted isnt 'false' )
			$element[ 0 ].defaultMuted = $element[ 0 ].muted  = true
			$element[ 0 ].volume = 0
