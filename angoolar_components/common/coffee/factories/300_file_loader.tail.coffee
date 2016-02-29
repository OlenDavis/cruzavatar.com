angoolar.addFactory class angoolar.FileLoader extends angoolar.BaseFactory
	$_name: 'FileLoader'

	$_dependencies: [ '$q', '$log', '$rootScope', '$document' ]

	constructor: ->
		super

		@deferreds = {}

	loadScript: ( scriptUrl, isLoadedFunction ) =>
		unless @deferreds[ scriptUrl ]?
			deferred = @deferreds[ scriptUrl ] = @$q.defer()

			script = @$document[ 0 ].createElement 'script'
			script.type = 'text/javascript'
			script.src = scriptUrl

			$rootScope = @$rootScope

			checkIsLoaded = ->
				if angular.isFunction isLoadedFunction
					intervalHandle = setInterval(
						->
							if isLoadedFunction()
								clearInterval intervalHandle
								$rootScope.$apply -> deferred.resolve()

						10
					)
				else
					deferred.resolve()

			if angular.isFunction( isLoadedFunction ) and isLoadedFunction()
				deferred.resolve()
			else
				if @$document[ 0 ].readyState is 'interactive' or @$document[ 0 ].readyState is 'complete'
					@$document[ 0 ].head.appendChild script
					checkIsLoaded()
				else
					@$document.bind 'ready', =>
						@$document[ 0 ].head.appendChild script
						$rootScope.$apply checkIsLoaded

		@deferreds[ scriptUrl ].promise

	loadStyle: ( styleUrl ) =>
		unless @deferreds[ styleUrl ]?
			deferred = @deferreds[ styleUrl ] = @$q.defer()

			style = @$document[ 0 ].createElement 'link'
			style.rel  = 'stylesheet'
			style.type = 'text/css'
			style.href = styleUrl

			$rootScope = @$rootScope

			if @$document[ 0 ].readyState is 'interactive' or @$document[ 0 ].readyState is 'complete'
				@$document[ 0 ].head.appendChild style
				deferred.resolve()
			else
				@$document.bind 'ready', =>
					@$document[ 0 ].head.appendChild style
					$rootScope.$apply -> deferred.resolve()

		@deferreds[ styleUrl ].promise
