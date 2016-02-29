angoolar.addDirective class Slider extends angoolar.BaseTemplatedDirective
	$_name: 'Slider'

	transclude: yes

	scope:
		currentIndex         : '=?'
		autoIncrementDelay   : '=?'
		paused               : '=?'
		hideControls         : '=?'
		hideCircleControllers: '=?'
		simpleStyle          : '=?'
		editing              : '=?'
		mode                 : '@' # 'whole-size'
		largeArrows          : '=?'

	controller: class SliderController extends angoolar.BaseDirectiveController
		$_name: 'SliderController'

		$_dependencies: [ angoolar.DialogState ]

		$defaultAutoIncrementDelay: 4000

		constructor: ->
			super

			@$slideControllers = new Array()

			@$scope.currentIndex = 0

			@$scope.$watch 'currentIndex', ( @$currentIndex, @$lastIndex ) =>

			@$scope.$watchGroup [ 'paused', => @DialogState.shownDialogs ], ( args ) =>
				[ paused, shownDialogs ] = args
				@paused = paused or shownDialogs
				@autoIncrement() unless @paused

			@$scope.$watch ( => @$arrowBottom ), ( arrowBottom, oldArrowBottom ) =>
				unless arrowBottom is oldArrowBottom
					setTimeout => @$scope.$apply ->

		autoIncrement: ->
			clearTimeout @$lastTimeout
			@$lastTimeout = setTimeout(
				=>
					
					return if @paused or @$scope.editing

					@$scope.$apply =>
						@nextSlide yes
						@autoIncrement()

				@$scope.autoIncrementDelay or @$defaultAutoIncrementDelay
			)

		registerSlideController: ( slideController ) ->
			@$slideControllers.push slideController

		deregisterSliderController: ( slideController ) ->
			index = _.indexOf @$slideControllers, slideController
			if index > -1
				@$slideControllers.splice index, 1
				@goToSlide @$scope.currentIndex

		previousSlide: ->
			@$scope.paused = yes
			@$scope.currentIndex = ( @$scope.currentIndex - 1 + @$slideControllers.length ) % @$slideControllers.length
		nextSlide: ( autoIncrementing ) ->
			@$scope.paused = yes unless autoIncrementing
			@$scope.currentIndex = ( @$scope.currentIndex + 1 ) % @$slideControllers.length
		goToSlide: ( index ) ->
			@$scope.paused = yes
			@$scope.currentIndex = index % @$slideControllers.length

		getNextLabel: ( index ) =>
			@$slideControllers[ ( @$scope.currentIndex + 1 ) % @$slideControllers.length ].$attrs.label

		getPreviousLabel: ( index ) =>
			@$slideControllers[ ( @$scope.currentIndex - 1 + @$slideControllers.length ) % @$slideControllers.length ].$attrs.label

angoolar.addDirective class Slide extends angoolar.BaseDirective
	$_name: 'Slide'

	$_requireParents: [ Slider ]

	transclude: 'element'

	controller: class SlideController extends angoolar.BaseDirectiveController
		$_name: 'SlideController'

		$_link: ->
			super
			@SliderController.registerSlideController @
			@$scope.$on '$destroy', =>
				@SliderController.deregisterSliderController @
