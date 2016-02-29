lastTime = 0
vendors = [ 'webkit', 'moz' ]
if !window.requestAnimationFrame
	for vendor in vendors
		window.requestAnimationFrame = window[ "#{ vendor }RequestAnimationFrame" ]
		window.cancelAnimationFrame  = window[ "#{ vendor }CancelAnimationFrame" ] || window[ "#{ vendor }CancelRequestAnimationFrame" ]

if !window.requestAnimationFrame
	window.requestAnimationFrame = ( callback, element ) ->
		currTime = new Date().getTime()
		timeToCall = Math.max(0, 16 - (currTime - lastTime))
		id = window.setTimeout ( -> callback currTime + timeToCall ), timeToCall
		lastTime = currTime + timeToCall
		return id

	window.cancelAnimationFrame = ( id ) ->
		clearTimeout id

angoolar.addFactory class angoolar.FastScroll extends angoolar.BaseFactory
	$_name: 'FastScroll'

	$_dependencies: [ '$document', angoolar.SmoothScroll, '$injector' ]

	constructor: ->
		super

		@topCallbacks = new Array()
		@leftCallbacks = new Array()

		@State = @$injector.get angoolar.State::$_makeName()

	bindScrollTop: ( callback ) ->
		unless ( @topCallbacks.indexOf callback ) >= 0
			@topCallbacks.push callback

		unless @animationFrameRequest
			@trackScroll()

	unbindScrollTop: ( callback ) ->
		if ( index = @topCallbacks.indexOf callback ) >= 0
			@topCallbacks.splice index, 1

			unless @topCallbacks.length
				@untrackScroll()

	bindScrollLeft: ( callback ) ->
		unless ( @leftCallbacks.indexOf callback ) >= 0
			@leftCallbacks.push callback

		unless @animationFrameRequest
			@trackScroll()

	unbindScrollLeft: ( callback ) ->
		if ( index = @leftCallbacks.indexOf callback ) >= 0
			@leftCallbacks.splice index, 1

			unless @leftCallbacks.length
				@untrackScroll()

	getScrollTop : -> window.pageYOffset or document.documentElement.scrollTop
	getScrollLeft: -> window.pageXOffset or document.documentElement.scrollLeft

	trackScroll: =>
		@animationFrameRequest = requestAnimationFrame @trackScroll

		oldScrollTop = @scrollTop
		@scrollTop = @getScrollTop()
		if oldScrollTop isnt @scrollTop
			callback @scrollTop for callback in @topCallbacks

		oldScrollLeft = @scrollLeft
		@scrollLeft = @getScrollLeft()
		if oldScrollLeft isnt @scrollLeft
			callback @scrollLeft for callback in @leftCallbacks

	untrackScroll: ->
		cancelAnimationFrame @animationFrameRequest

	scrollTopTo: ( scrollTop ) ->
		startingOffset = @State.stickyAreasHeight
		@SmoothScroll.to scrollTop,
			offset: startingOffset
			callbackAfter: =>
				if Math.abs( startingOffset - @State.stickyAreasHeight ) > 10
					@scrollTopTo scrollTop

		# setTimeout => window.scrollTo 0, scrollTop
