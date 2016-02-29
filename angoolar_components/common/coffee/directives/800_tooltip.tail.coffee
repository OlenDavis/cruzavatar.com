tooltipId = 0
$body = angular.element document.body

angoolar.addDirective class TooltipTarget extends angoolar.BaseDirective
	$_name: 'TooltipTarget'

	controller: class TooltipTargetController extends angoolar.BaseDirectiveController
		$_name: 'TooltipTargetController'

		getTargetPosition: ->
			position = @$element.css 'position'
			if position is 'static' or not position
				@$element.position()
			else
				top : 0
				left: 0

		getTargetHeight: -> @$element[ 0 ].offsetHeight
		getTargetWidth : -> @$element[ 0 ].offsetWidth

angoolar.addDirective class Tooltip extends angoolar.BaseTemplatedDirective
	$_name: 'Tooltip'

	$_addClass: no

	$_requireParents: [ TooltipTarget ]

	transclude: yes

	scope:
		# This can be `bottom`, `top`, `left`, `right`, or `center` and refers to what side of the
		# ancestor element with the TooltipTarget directive on it the tooltip will be displayed on.
		where      : '@' + @::$_makeName()
		shown      : '=?'
		neverShown : '=?'
		isSticky   : '=?'
		matchTarget: '@' # can be width or height (or both), and the tooltip's width and/or height will be that of the element with the c-tooltip-target directive
		sizeClass  : '@'
		noHide        : '=?'

	controller: class TooltipController extends angoolar.BaseDirectiveController
		$_name: 'TooltipController'

		$_dependencies: [ '$log' ]

		stickyTargetTagNames: [ 'INPUT', 'BUTTON', 'TEXTAREA', 'SELECT' ]

		$_link: ->
			super

			unwatchNeverShown = @$scope.$watch '!! neverShown', ( neverShown ) =>
				if neverShown
					@unbindShow()
				else
					@bindShow()
					@$scope.$on '$destroy', @unbindShow
			@$scope.$on '$destroy', unwatchNeverShown

			@$scope.$watch "isSticky || #{ @$_name }.isSticky", ( isSticky ) =>
				@unwatchNeverShown?()

				if isSticky
					@unwatchNeverShown = @$scope.$watch '!! neverShown', ( neverShown ) =>
						if neverShown
							@unbindStickyHide()
						else
							@bindStickyHide()
							@offDestroyUnbindStickyHide = @$scope.$on '$destroy', @unbindStickyHide
					@unbindUnstickyHide()
					@offDestroyUnbindUnstickyHide?()
				else
					@unwatchNeverShown = @$scope.$watch '!! neverShown', ( neverShown ) =>
						if neverShown
							@unbindUnstickyHide()
						else
							@bindUnstickyHide()
							@offDestroyUnbindUnstickyHide = @$scope.$on '$destroy', @unbindUnstickyHide
					@unbindStickyHide()
					@offDestroyUnbindStickyHide?()

			@$scope.$on '$destroy', => @unwatchRespositionArgs?()

			@$scope.$watch '!! neverShown', ( neverShown ) =>
				if neverShown
					@hide()
				else if @TooltipTargetController.$element.is ':hover'
					# The reason for this timeout is that in all likelihood, what triggers the
					# neverShown to change is a click event. And if this is a sticky tooltip, then
					# that click will propagate up to the window, where it will hide the tooltip -
					# as it here is being shown. To ensure that it is shown after that potential
					# click event propagates up to the window, the call to show is in a setTimeout.
					setTimeout @show 

			@$scope.$watch 'shown', =>
				if @$scope.shown then @trackTarget() else @untrackTarget()

			@delayedReposition  = _.debounce @reposition, 10

		bindShow: =>
			@TooltipTargetController.$element.bind 'mouseover', @show
			@TooltipTargetController.$element.bind 'mousemove', @show
			@TooltipTargetController.$element.bind 'click', @makeStickyForInputs

		unbindShow: =>
			@TooltipTargetController.$element.unbind 'mouseover', @show
			@TooltipTargetController.$element.unbind 'mousemove', @show
			@TooltipTargetController.$element.unbind 'click', @makeStickyForInputs

		bindUnstickyHide: =>
			@$element.bind                         'mouseout', @hide
			@TooltipTargetController.$element.bind 'mouseout', @hide
			@bindStickyHide()

		unbindUnstickyHide: =>
			@$element.unbind                         'mouseout', @hide
			@TooltipTargetController.$element.unbind 'mouseout', @hide
			@unbindStickyHide()

		bindStickyHide: =>
			$body.bind 'mousedown', @maybeHide
			@TooltipTargetController.$element.bind 'mousedown', @dontHide

		unbindStickyHide: =>
			$body.unbind 'mousedown', @maybeHide
			@TooltipTargetController.$element.unbind 'mousedown', @dontHide

		dontHide: ( e ) =>
			data = e.originalEvent.data = e.originalEvent.data or {}
			data.$_keepTooltip = data.$_keepTooltip or {}
			@id = @id or ++tooltipId
			e.originalEvent.data.$_keepTooltip[ @id ] = yes # this basically allows only specific tooltips to prevent the closing of themselves

		maybeHide: ( e ) =>
			@hide() unless @id and e.originalEvent.data?.$_keepTooltip?[ @id ] # this basically allows only specific tooltips to prevent the closing of themselves

		# This is called by the TooltipContainer directive's controller
		setTooltipContainer: ( $tooltipContainer ) ->
			@$tooltipContainer = $tooltipContainer unless @$tooltipContainer?

		unsetTooltipContainer: ( $tooltipContainer ) ->
			@$tooltipContainer = null if @$tooltipContainer is $tooltipContainer

		show: =>
			@$scope.shown = yes
			@$scope.$evalAsync()

		hide: =>
			@$scope.shown = @isSticky = no
			@$scope.$evalAsync()

		makeStickyForInputs: ( $event ) =>
			for tagName in @stickyTargetTagNames
				if $event.target.tagName.toUpperCase() is tagName
					@$scope.$apply => @isSticky = yes
					break

		trackTarget: =>
			@unwatchTooltipContainer?()
			@unwatchTooltipContainer = @$scope.$watch ( => @$tooltipContainer ), =>
				if @$tooltipContainer
					@unwatchMatchTarget?()
					@unwatchMatchTarget = @$scope.$watchGroup [ "matchTarget.indexOf( 'width' ) >= 0", "matchTarget.indexOf( 'height' ) >= 0" ], ( args, oldArgs ) =>
						[ @matchWidth,   @matchHeight   ] = args
						[ oldMatchWidth, oldMatchHeight ] = oldArgs
						@$tooltipContainer?.css 'width',  @TooltipTargetController.getTargetWidth()  if @matchWidth
						@$tooltipContainer?.css 'height', @TooltipTargetController.getTargetHeight() if @matchHeight
						@$tooltipContainer?.css 'width',  '' if oldMatchWidth  and not @matchWidth
						@$tooltipContainer?.css 'height', '' if oldMatchHeight and not @matchHeight

						@unwatchRespositionArgs?()
						@unwatchRespositionArgs = @$scope.$watch(
							@getRepositionArgs
							@delayedReposition
							yes
						)
				else
					@unwatchMatchTarget?()
					@unwatchRespositionArgs?()

		untrackTarget: =>
			setTimeout => @displayed = no
			@unwatchTooltipContainer?()
			@unwatchMatchTarget?()
			@unwatchRespositionArgs?()

		getRepositionArgs: =>
			targetPosition : @TooltipTargetController.getTargetPosition()
			targetHeight   : @TooltipTargetController.getTargetHeight()
			targetWidth    : @TooltipTargetController.getTargetWidth()
			toolTipPosition: @$tooltipContainer?.position()
			tooltipHeight  : @$tooltipContainer?[ 0 ].offsetHeight
			tooltipWidth   : @$tooltipContainer?[ 0 ].offsetWidth

		reposition: ( args ) =>
			@$tooltipContainer?.css switch ( @$scope.where or 'top' )
				when 'top'    then {
					top : Math.round( args.targetPosition.top                          - args.tooltipHeight     )
					left: Math.round( args.targetPosition.left + args.targetWidth  / 2 - args.tooltipWidth  / 2 )
				}
				when 'right'  then {
					top : Math.round( args.targetPosition.top  + args.targetHeight / 2 - args.tooltipHeight / 2 )
					left: Math.round( args.targetPosition.left + args.targetWidth                               )
				}
				when 'bottom' then {
					top : Math.round( args.targetPosition.top  + args.targetHeight                              )
					left: Math.round( args.targetPosition.left + args.targetWidth  / 2 - args.tooltipWidth  / 2 )
				}
				when 'left'   then {
					top : Math.round( args.targetPosition.top  + args.targetHeight / 2 - args.tooltipHeight / 2 )
					left: Math.round( args.targetPosition.left                         - args.tooltipWidth      )
				}
				when 'bottom-right' then {
					top : Math.round( args.targetPosition.top  + args.targetHeight                              )
					left: Math.round( args.targetPosition.left                                                  )
				}
				else { # 'center'
					top : Math.round( args.targetPosition.top  + args.targetHeight / 2 - args.tooltipHeight / 2 )
					left: Math.round( args.targetPosition.left + args.targetWidth  / 2 - args.tooltipWidth  / 2 )
				}
			@$scope.$evalAsync => @displayed = yes

angoolar.addDirective class NavigationTooltip extends Tooltip
	$_name: 'NavigationTooltip'

	scope: where: '@' + @::$_makeName()

	controller: class NavigationTooltipController extends Tooltip::controller
		$_name: 'NavigationTooltipController'

angoolar.addDirective class TypicalTooltip extends Tooltip
	$_name: 'TypicalTooltip'

	scope:
		where : '@' + @::$_makeName()
		opaque: '=?'

	controller: class TypicalTooltipController extends Tooltip::controller
		$_name: 'TypicalTooltipController'

angoolar.addDirective class TooltipContainer extends angoolar.BaseDirective
	$_name: 'TooltipContainer'

	$_requireParents: [ Tooltip, NavigationTooltip, TypicalTooltip ]

	controller: class TooltipContainerController extends angoolar.BaseDirectiveController
		$_name: 'TooltipContainerController'

		$_link: ->
			super
			@TooltipController?.          setTooltipContainer @$element
			@NavigationTooltipController?.setTooltipContainer @$element
			@TypicalTooltipController?.   setTooltipContainer @$element

			@$scope.$on '$destroy', =>
				@TooltipController?.          unsetTooltipContainer @$element
				@NavigationTooltipController?.unsetTooltipContainer @$element
				@TypicalTooltipController?.   unsetTooltipContainer @$element
