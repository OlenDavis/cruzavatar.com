debouncedResizeBroadcast = null

class WipeDimensionAnimation extends angoolar.BaseAnimation

	$_dependencies: [
		'$animateCss',
		'$rootScope'
		'$log'
	]

	$_prefix: ''

	$dimensionProperty: null # expected to be overridden with such as 'width' or 'min-height'

	constructor: ->
		super

		debouncedResizeBroadcast or= _.debounce ( => @$rootScope.$evalAsync => @$rootScope.$broadcast 'resize' ), 50

	enter: ( element, done ) =>
		@doAnimation 'ng-enter', yes, element, done

	leave: ( element, done ) =>
		@doAnimation 'ng-leave', no, element, done

	move: ( element, done ) =>
		@doAnimation 'ng-move', yes, element, done

	doAnimation: ( eventName, wipeIn, element, done ) ->
		targetValue = element.css @$dimensionProperty
		targetValue = element[ 0 ][ "offset#{ if @$dimensionProperty.indexOf( 'width' ) >= 0 then 'Width' else 'Height' }" ] if not targetValue or targetValue is 'none'
		unless unit = targetValue.match?( /\d+(\w+)/ )?[ 1 ]
			unit = 'px'
			targetValue = "#{ targetValue }#{ unit }"
		zeroValue = "0#{ unit }"

		( cssTo   = {} )[ @$dimensionProperty ] = if wipeIn then targetValue else zeroValue
		( cssFrom = {} )[ @$dimensionProperty ] = if wipeIn then zeroValue else targetValue

		options = event: eventName
		unless element.hasClass( 'wipe-width' ) and /whole-width|width-ratio-4-5|width-ratio-1-5|width-ratio-2-3|width-ratio-1-3|width-ratio-1-2/.test element.attr 'class'
			angular.extend( options, {
				to   : cssTo
				from : cssFrom
			} )
		
		runner = @$animateCss element, options

		# This runs the CSS animation
		runner.start().then =>
			element.css @$dimensionProperty, '' if wipeIn
			debouncedResizeBroadcast()
			done()

		# This is the cancellation function
		=> runner.end()

angoolar.addAnimation class WipeWidth extends WipeDimensionAnimation
	$_name: 'WipeWidth'

	$dimensionProperty: 'width'

angoolar.addAnimation class WipeHeight extends WipeDimensionAnimation
	$_name: 'WipeHeight'

	$dimensionProperty: 'height'

angoolar.addAnimation class WipeMaxWidth extends WipeDimensionAnimation
	$_name: 'WipeMaxWidth'

	$dimensionProperty: 'max-width'

angoolar.addAnimation class WipeMaxHeight extends WipeDimensionAnimation
	$_name: 'WipeMaxHeight'

	$dimensionProperty: 'max-height'
