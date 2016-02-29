angoolar.addDirective class PaletteColoring extends angoolar.BaseDirective
	$_name: 'PaletteColoring'

	controller: class PaletteColoringController extends angoolar.BaseDirectiveController
		$_name: 'PaletteColoringController'

		$_dependencies: [ '$parse' ]

		constructor: ->
			super

			paletteGetter = @$parse @$attrs[ PaletteColoring::$_makeName() ]
			@$scope.$watch ( => paletteGetter @$scope ), ( @palette ) =>
			@$scope.$watch ( => @palette?.colorArrays ), ( @colorArrays ) =>
				if @colorArrays?.length
					@$element.css 'background-image', @palette.makeLinearGradient 2
