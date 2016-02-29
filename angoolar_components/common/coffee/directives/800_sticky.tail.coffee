lastStickyAreaId = 0
$window = null

angoolar.addDirective class StickyArea extends angoolar.BaseDirective
	$_name: 'StickyArea'

	$_requireParents: [ StickyArea ]

	$_dependencies: [ '$window' ]

	constructor: ->
		super

		$window or= angular.element @$window

	controller: class StickyAreaController extends angoolar.BaseDirectiveController
		$_name: 'StickyAreaController'

		$_dependencies: [
			'$log'
			angoolar.State
			angoolar.FastScroll
		]

		constructor: ->
			super

			@id = ++lastStickyAreaId

			@stickyHeightsById = {}

			@stickyChildrenHeight = 0

			@updateStickyChildrenHeight()

			@stickyChildZIndex = 100

			@stucks = []
			@unstucks = []

			debouncedSetBottom = => @bottom = @$element[ 0 ].getBoundingClientRect().bottom

			$window.bind 'resize', debouncedSetBottom
			@offScopeResize = @$scope.$on 'resize', debouncedSetBottom
			@FastScroll.bindScrollLeft debouncedSetBottom
			@FastScroll.bindScrollTop debouncedSetBottom

			@$scope.$on '$destroy', =>
				@State.setStickyAreaChildrenHeight @id, 0

				$window.unbind 'resize', debouncedSetBottom
				@offScopeResize()
				@FastScroll.unbindScrollLeft debouncedSetBottom
				@FastScroll.unbindScrollTop debouncedSetBottom

		updateStickyChildrenHeight: ->
			stickyChildrenHeights = ( height for id, height of @stickyHeightsById )
			@StickyAreaController?.updateStickyChildrenHeight()
			@stickyChildrenHeight = ( @StickyAreaController?.stickyChildrenHeight or 0 ) + if stickyChildrenHeights.length then Math.max stickyChildrenHeights... else 0
			@State.setStickyAreaChildrenHeight @id, @stickyChildrenHeight

		$_link: ->
			super

			@StickyAreaController?.incrementStickyChildZIndex()

		unstuck: ( stickyId ) ->
			@stickyHeightsById[ stickyId ] = 0
			@updateStickyChildrenHeight()
			@$scope.$evalAsync =>
				unstuck() for unstuck in @unstucks

		stuck: -> @$scope.$evalAsync =>
			stuck() for stuck in @stucks

		addStuckHandlers: ( stuck, unstuck ) ->
			@stucks.push stuck if angular.isFunction stuck
			@unstucks.push unstuck if angular.isFunction unstuck

		removeStuckHandlers: ( stuck, unstuck ) ->
			stuckIndex = _.indexOf @stucks, stuck
			unstuckIndex = _.indexOf @unstucks, unstuck
			@stucks.splice stuckIndex, 1 unless stuckIndex is -1
			@unstucks.splice unstuckIndex, 1 unless unstuckIndex is -1

		getTop: ( stickyId, topOffset, height, elementTop, dontStack ) ->
			@stickyHeightsById[ stickyId ] = topOffset + if dontStack then 0 else height
			@updateStickyChildrenHeight()
			nestingStickyAreaTop = @StickyAreaController?.stickyChildrenHeight or 0

			amountTallerThanWindow = Math.max 0, height - @$scope.$root.State.windowHeight
			amountToShiftUpward = if amountTallerThanWindow then Math.min amountTallerThanWindow + nestingStickyAreaTop, nestingStickyAreaTop - elementTop else 0

			Math.min @$element[ 0 ].getBoundingClientRect().bottom - ( topOffset + height ), topOffset + nestingStickyAreaTop - amountToShiftUpward

		incrementStickyChildZIndex: ->
			@stickyChildZIndex += 1
			@StickyAreaController?.incrementStickyChildZIndex()

lastStickyId = 0

angoolar.addDirective class Sticky extends angoolar.BaseDirective
	$_name: 'Sticky'

	$_requireParents: [ StickyArea ]

	# scope: stickyOptions: '=?' # here for documentation; this is done manually though

	transclude: 'element'

	controller: class StickyController extends angoolar.BaseDirectiveController
		$_name: 'StickyController'

		$_dependencies: [
			'$parse'
			angoolar.FastScroll
			angoolar.DialogState
		]

		$defaultOptions:
			top     : 0
			disabled: angoolar.isBrowser.Mobile

		constructor: ->
			super

			@id = ++lastStickyId

		$_link: ->
			super

			@boundingRect = {}
			@options = @$defaultOptions

			@stickySetter = @$parse( @$attrs[ Sticky::$_makeName() ] ).assign

			@$transclude ( @$stuckElement, $transcludedScope ) =>
				@$stuckElement.css
					position: 'absolute'
				@$element.after @$stuckElement
				@$element.$__clones or= new Array()
				@$element.$__clones.push @$stuckElement

				@$transclude $transcludedScope, ( @$originalElement ) =>
					@$originalElement.css
						visibility: 'hidden'
					@$originalElement.addClass 'relative below'
					@$stuckElement.after @$originalElement
					@$element.$__clones or= new Array()
					@$element.$__clones.push @$originalElement

			debouncedBeSticky = @beSticky #_.debounce @beSticky, 0
			
			enableStickiness = =>
				$window.bind 'resize', debouncedBeSticky
				@offScopeResize = @$scope.$on 'resize', debouncedBeSticky
				@FastScroll.bindScrollLeft debouncedBeSticky
				@FastScroll.bindScrollTop debouncedBeSticky

				setTimeout debouncedBeSticky

			disableStickiness = =>
				@unstickIt()
				$window.unbind 'resize', debouncedBeSticky
				@offScopeResize?()
				@FastScroll.unbindScrollLeft debouncedBeSticky
				@FastScroll.unbindScrollTop debouncedBeSticky

			@$scope.$on '$destroy', disableStickiness
			
			@$scope.$watch(
				@$attrs.stickyOptions

				( options ) =>
					@setOptions options
					@unwatchDisabled?()
					@unwatchDisabled = @$scope.$watch ( => @options.disabled or ( @DialogState.shownDialogs and not @options.ignoreDialogs ) ), ( disabled ) =>
						if disabled
							disableStickiness()
						else
							enableStickiness()

				yes
			)

		beSticky: =>
			@setBoundingRect @getBoundingRect()
			@updateState @getState()

		getBoundingRect: => @$originalElement[ 0 ].getBoundingClientRect()

		setBoundingRect: ( boundingRect ) =>
			# This is ridiculous, and purely because of IE8, there's no width or height
			@boundingRect.top    = boundingRect.top
			@boundingRect.bottom = boundingRect.bottom
			@boundingRect.left   = boundingRect.left
			@boundingRect.right  = boundingRect.right
			@boundingRect.width  = boundingRect.right - boundingRect.left
			@boundingRect.height = boundingRect.bottom - boundingRect.top

			@setStuckElementCss() if @$stuck

		setOptions: ( @options ) =>
			if      angular.isNumber @options then @options = angular.extend {}, @$defaultOptions, { top: @options }
			else if angular.isObject @options then @options = angular.extend {}, @$defaultOptions, @options
			else                                   @options = angular.extend {}, @$defaultOptions

		getState: =>
			top      : @boundingRect?.top
			stickyTop: @options.top or 0

		updateState: ( state ) =>
			if ( @boundingRect.bottom + 1 ) < @StickyAreaController.bottom and state.top <= stickyTop = state.stickyTop + ( @StickyAreaController.StickyAreaController?.stickyChildrenHeight or 0 )
				@stickIt state unless @$stuck is yes
			else
				@unstickIt() unless @$stuck is no

		unstickIt: =>
			@$stuckElement.css
				position  : 'absolute'
				visibility: ''
				width     : ''
				top       : ''
				bottom    : ''
				left      : ''
				'z-index' : ''

			@StickyAreaController?.unstuck @id

			@$stuck = no

			@setStuck()

		stickIt: =>
			@setStuckElementCss()
			# unless @totallyOutOfView
			@$stuckElement.css
				position : 'fixed'
				'z-index': @StickyAreaController.stickyChildZIndex

			@StickyAreaController?.stuck()

			@$stuck = yes

			@setStuck()

		setStuck: -> @$scope.$evalAsync => @stickySetter? @$scope, @$stuck

		setStuckElementCss: ->
			top = @StickyAreaController.getTop @id, @options.top, @boundingRect.height, @boundingRect.top, @options.dontStack
			# unless @totallyOutOfView = top < - @boundingRect.height
			@$stuckElement.css
				visibility: ''
				width     : @boundingRect.width
				top       : top
				bottom    : ''
				left      : @boundingRect.left
			# else
			# 	@$stuckElement.css visibility: 'hidden'

angoolar.addDirective class ClassWhenStuck extends angoolar.BaseDirective
	$_name: 'ClassWhenStuck'

	$_requireParents: [ StickyArea ]

	$_dependencies: [ '$interpolate', '$animate' ]

	link: ( $scope, $element, $attrs, controllers ) =>
		super

		StickyAreaController = controllers[ 0 ]

		$classGetter = @$interpolate $attrs[ ClassWhenStuck::$_makeName() ]

		$addedClass = ""

		stuck = =>
			previouslyAddedClass = $addedClass or ""
			$addedClass = $classGetter( $scope ) or ""
			unless $element.$__clones
				@$animate.setClass $element, $addedClass, previouslyAddedClass
			else
				@$animate.setClass $clone, $addedClass, previouslyAddedClass for $clone in $element.$__clones

		unstuck = =>
			unless $element.$__clones
				@$animate.setClass( $element, "", $addedClass or $classGetter $scope )
			else
				@$animate.setClass( $clone, "", $addedClass or $classGetter $scope ) for $clone in $element.$__clones

			$addedClass = ""

		StickyAreaController.addStuckHandlers stuck, unstuck
		$scope.$on '$destroy', => StickyAreaController.removeStuckHandlers stuck, unstuck

angoolar.addDirective class ClassWhenUnstuck extends angoolar.BaseDirective
	$_name: 'ClassWhenUnstuck'

	$_requireParents: [ StickyArea ]

	$_dependencies: [ '$interpolate', '$animate' ]

	link: ( $scope, $element, $attrs, controllers ) =>
		super

		StickyAreaController = controllers[ 0 ]

		$classGetter = @$interpolate $attrs[ ClassWhenUnstuck::$_makeName() ]

		$addedClass = ""

		unstuck = =>
			previouslyAddedClass = $addedClass or ""
			$addedClass = $classGetter( $scope ) or ""
			unless $element.$__clones
				@$animate.setClass $element, $addedClass, previouslyAddedClass
			else
				@$animate.setClass $clone, $addedClass, previouslyAddedClass for $clone in $element.$__clones

		stuck = =>
			unless $element.$__clones
				@$animate.setClass( $element, "", $addedClass or $classGetter $scope )
			else
				@$animate.setClass( $clone, "", $addedClass or $classGetter $scope ) for $clone in $element.$__clones

			$addedClass = ""

		StickyAreaController.addStuckHandlers stuck, unstuck
		$scope.$on '$destroy', => StickyAreaController.removeStuckHandlers stuck, unstuck

angoolar.addDirective class ShowWhenStuck extends angoolar.BaseDirective
	$_name: 'ShowWhenStuck'

	$_requireParents: [ StickyArea ]

	compile: ( tElement, tAttrs, transclude ) =>
		super

		tElement.addClass 'ng-hide'

	controller: class ShowWhenStuckController extends angoolar.BaseDirectiveController
		$_name: 'ShowWhenStuckController'

		$_dependencies: [ '$animate' ]

		$_link: ->
			super
			@StickyAreaController.addStuckHandlers @stuck, @unstuck
			@$scope.$on '$destroy', => @StickyAreaController.removeStuckHandlers @stuck, @unstuck

		stuck: =>
			@$animate.removeClass @$element, 'ng-hide'

		unstuck: =>
			@$animate.addClass @$element, 'ng-hide'
