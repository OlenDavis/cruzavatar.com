class ScrollPositionController extends angoolar.BaseDirectiveController
	$_name: 'ScrollPositionController'

	$scrollDuration: 600

	$minDiff: 1

	constructor: ->
		super

		@$scope.$watch 'left', ( left, lastLeft ) =>
			return console.log "diff only #{ Math.abs( left - lastLeft ) }" unless Math.abs( left - lastLeft ) > @$minDiff
			# throttledScrollLeftTo()
			@scrollLeftTo()

		@$element.bind 'scroll', @updateScroll

		setTimeout @updateScroll

	updateScroll: =>
		return console.log "animating..." if @$animating
		@$scope.$apply =>
			console.log "scrolled to #{ @$element.scrollLeft() }"
			@$scope.left = @$element.scrollLeft()

	scrollLeftTo: =>
		return unless @$scope.left?

		console.log "scrolling to #{ @$scope.left }"
		@$animating = yes
		@$element.stop()
		@$element.animate(
			scrollLeft: @$scope.left

			@$scrollDuration

			=>
				@$animating = no
				@updateScroll()
		)

angoolar.addDirective class ScrollPosition extends angoolar.BaseDirective
	$_name: 'ScrollPosition'

	controller: ScrollPositionController

	scope:
		left: '='