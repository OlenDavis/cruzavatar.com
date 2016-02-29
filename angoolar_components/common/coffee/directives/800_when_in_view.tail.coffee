$window = null

angoolar.addDirective class WhenInView extends angoolar.BaseDirective
	$_name: 'WhenInView'

	$_dependencies: [ '$window' ]

	# This has been refactored to not require an isolated scope so it can be used on elements
	# alongside other more complex directives that really do require isolate scopes.

	constructor: ->
		super

		$window = angular.element @$window

	controller: class WhenInViewController extends angoolar.BaseDirectiveController
		$_name: 'WhenInViewController'

		$_dependencies: [
			'$parse'
			angoolar.FastScroll
			angoolar.State
		]

		$_link: ->
			super

			whenInViewAttribute = WhenInView::$_makeName()
			@$scope.$watch ( => @$attrs[ whenInViewAttribute ] ), ( whenInView ) =>
				whenInViewGetter = @$parse whenInView
				@whenInView = -> whenInViewGetter? @$scope

			if @$attrs.offset
				offsetGetter = @$parse @$attrs.offset
				@$scope.$watch ( => offsetGetter @$scope ), ( @offset ) =>

			if @$attrs.percentOffset
				percentOffsetGetter = @$parse @$attrs.percentOffset
				@$scope.$watch ( => percentOffsetGetter @$scope ), ( @percentOffset ) =>

			if @$attrs.inView
				assignInView = @$parse( @$attrs.inView ).assign
				@setInView = => assignInView @$scope, @inView

			debouncedDigest = _.throttle @updateInView, 250

			@FastScroll.bindScrollTop debouncedDigest
			@$scope.$on '$destroy', =>
				@FastScroll.unbindScrollTop debouncedDigest

			setTimeout debouncedDigest, 250

			@$scope.$watch ( => @inView ), =>
				@whenInView?() if @inView
				@setInView?()

		getOffset: ( height ) ->
			( @offset or 0 ) + height * ( @percentOffset or 0 )

		updateInView: => 
			elementDimensions = @$element[0].getBoundingClientRect()

			state =
				top   : elementDimensions.top - @State.stickyAreasHeight
				right : elementDimensions.right
				bottom: elementDimensions.bottom
				left  : elementDimensions.left
				width : $window[ 0 ].innerWidth
				height: $window[ 0 ].innerHeight

			offset = @getOffset state.height

			@$scope.$evalAsync => @inView = state.top < ( state.height - offset ) && state.bottom > offset && state.right > 0 && state.left < state.width
