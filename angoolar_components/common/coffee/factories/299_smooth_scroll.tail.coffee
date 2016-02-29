###!
 *	 Angular Smooth Scroll (ngSmoothScroll)
 *	 Animates scrolling to elements, by David Oliveros.
 *   Coffeescript version, with element-less scrolling by Olen Davis
 * 
 *   Callback hooks contributed by Ben Armston https://github.com/benarmston
 *	 Easing support contributed by Willem Liu. https://github.com/willemliu
 *	 Easing functions forked from Gaëtan Renaudeau. https://gist.github.com/gre/1650294
 *	 Infinite loop bugs in iOS and Chrome (when zoomed) by Alex Guzman. https://github.com/alexguzman
 *	 Support for scrolling in custom containers by Joseph Matthias Goh. https://github.com/zephinzer
 *	 Influenced by Chris Ferdinandi
 *	 https://github.com/cferdinandi
 *
 *	 Version: 1.7.3
 * 	 License: MIT
 *   https://github.com/d-oliveros/ngSmoothScroll/blob/master/lib/angular-smooth-scroll.js
###

angoolar.addFactory class angoolar.SmoothScroll extends angoolar.BaseFactory
	$_name: 'SmoothScroll'

	to: ( element, options ) =>
		options = options or {}
		
		# Options
		duration         = options.duration or 800
		offset           = options.offset or 0
		easing           = options.easing or 'easeInOutQuart'
		callbackBefore   = options.callbackBefore or ->
		callbackAfter    = options.callbackAfter or ->
		container        = document.getElementById options.containerId
		containerPresent = container?
		
		###
		 * Retrieve current location
		 ###
		getScrollLocation = ->
			if containerPresent
				return container.scrollTop
			else
				if window.pageYOffset
					return window.pageYOffset
				else
					return document.documentElement.scrollTop
		
		###
		 * Calculate easing pattern.
		 * 
		 * 20150713 edit - zephinzer
		 * - changed if-else to switch
		 * @see http://archive.oreilly.com/pub/a/server-administration/excerpts/even-faster-websites/writing-efficient-javascript.html
		 ###
		getEasingPattern = (type, time) ->
			switch type
				when 'easeInQuad'
					time * time # accelerating from zero velocity
				when 'easeOutQuad'
					time * (2 - time) # decelerating to zero velocity
				when 'easeInOutQuad'
					if time < 0.5 then 2 * time * time else -1 + (4 - 2 * time) * time # acceleration until halfway, then deceleration
				when 'easeInCubic'
					time * time * time # accelerating from zero velocity
				when 'easeOutCubic'
					(--time) * time * time + 1 # decelerating to zero velocity
				when 'easeInOutCubic'
					if time < 0.5 then 4 * time * time * time else (time - 1) * (2 * time - 2) * (2 * time - 2) + 1 # acceleration until halfway, then deceleration
				when 'easeInQuart'
					time * time * time * time # accelerating from zero velocity
				when 'easeOutQuart'
					1 - (--time) * time * time * time # decelerating to zero velocity
				when 'easeInOutQuart'
					if time < 0.5 then 8 * time * time * time * time else 1 - 8 * (--time) * time * time * time # acceleration until halfway, then deceleration
				when 'easeInQuint'
					time * time * time * time * time # accelerating from zero velocity
				when 'easeOutQuint'
					1 + (--time) * time * time * time * time # decelerating to zero velocity
				when 'easeInOutQuint'
					if time < 0.5 then 16 * time * time * time * time * time else 1 + 16 * (--time) * time * time * time * time # acceleration until halfway, then deceleration
				else
					time
		
		###
		 * Calculate how far to scroll
		 ###
		getEndLocation = (element) ->
			location = 0
			if element.offsetParent
				(
					location += element.offsetTop
					element = element.offsetParent
				) while element
			location = Math.max(location - offset, 0)
			return location
		
		# Initialize the whole thing
		setTimeout ( =>
			currentLocation = null
			startLocation   = getScrollLocation()
			endLocation     = if angular.isNumber element then element else getEndLocation(element)
			distance        = endLocation - startLocation
			percentage      = undefined
			position        = undefined
			scrollHeight    = undefined
			internalHeight  = undefined
			frameRequest    = undefined
			startTime       = undefined

			###
			 * Stop the scrolling animation when the anchor is reached (or at the top/bottom of the page)
			 ###
			stopAnimation = =>
				currentLocation = getScrollLocation()
				internalHeight = window.innerHeight + currentLocation
				if containerPresent
					scrollHeight = container.scrollHeight
				else
					scrollHeight = document.body.scrollheight
				
				if (
					( # condition 1
						position == endLocation
					) or 
					( # condition 2
						currentLocation == endLocation
					) or 
					( # condition 3
						internalHeight >= scrollHeight 
					) 
				) # stop
					if endLocation isnt ( if angular.isNumber element then element else getEndLocation(element) )
						@to element, options
					else
						callbackAfter(element)
				else
					frameRequest = requestAnimationFrame animateScroll

			###
			 * Scroll the page by an increment, and check if it's time to stop
			 ###
			animateScroll = ( currentTime ) =>
				startTime or= currentTime
				timeLapsed = currentTime - startTime
				percentage = ( timeLapsed / duration )
				percentage = if ( percentage > 1 ) then 1 else percentage
				position = startLocation + ( distance * getEasingPattern(easing, percentage) )
				if containerPresent
					container.scrollTop = position
				else
					window.scrollTo( 0, position )
				stopAnimation()

			callbackBefore(element)
			frameRequest = requestAnimationFrame animateScroll
		), 0
