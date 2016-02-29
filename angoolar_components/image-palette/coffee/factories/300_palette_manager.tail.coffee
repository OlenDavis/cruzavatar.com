class angoolar.Palette
	thresholdLightness: 187 # 'bb'

	constructor: ( @colorArrays ) ->

	makeLinearGradient: ( limitTo = @colorArrays.length )                 =>
		@setIsLight limitTo
		( @colorArrays and @linearGradient          = "linear-gradient(to right top, #{ ( "rgb(#{  colors.join ',' })"             for colors in @colorArrays[ 0 .. limitTo - 1 ] ).join ',' })" )
	makeLinearGradientWithAlpha: ( limitTo = @colorArrays.length, alpha ) =>
		@setIsLight limitTo
		( @colorArrays and @linearGradientWithAlpha = "linear-gradient(to right top, #{ ( "rgba(#{ colors.join ',' }, #{ alpha })" for colors in @colorArrays[ 0 .. limitTo - 1 ] ).join ',' })" )

	setIsLight: ( limitTo = @colorArrays.length ) ->
		avgLightness = 0
		for colors in @colorArrays[ 0 .. limitTo - 1 ]
			avgLightness += color for color in colors
		avgLightness /= limitTo * 3 # times 3 'cause there are three channels in each color array
		@isLight = avgLightness > @thresholdLightness

angoolar.addFactory class angoolar.PaletteManager extends angoolar.BaseFactory
	$_name: 'PaletteManager'

	$_dependencies: [ '$log', '$rootScope' ]

	constructor: ->
		super

		@palettes = {} # a hash of image source strings to color palettes (which are an array of 3 to 7 rgba(#, #, #) strings)

	get: ( imageSrc ) ->
		unless @palettes[ imageSrc ]
			image = new Image()
			image.crossOrigin = image.crossorigin = "anonymous"
			image.src = imageSrc
			palette = @palettes[ imageSrc ] = new angoolar.Palette()
			$image = angular.element image
			setPalette = =>
				$image.unbind 'load', setPalette
				@$rootScope.$evalAsync =>
					paletteStart = new Date()
					try
						palette.colorArrays = ColorThief.prototype.getPalette image, 4
						paletteDuration = new Date() - paletteStart
						if paletteDuration > 50
							@$log.warn "Palette generation for #{ $image.attr 'src' } took #{ paletteDuration }ms"
					catch e
						@$log.error e
						$image.remove()
			if image.complete
				setPalette()
			else
				$image.bind 'load', setPalette

		@palettes[ imageSrc ]
