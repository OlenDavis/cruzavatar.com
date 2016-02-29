angoolar.addDirective class angoolar.ImgDirective extends angoolar.BaseDirective
	$_name: 'img'

	$_prefix: ''

	$_dependencies: [ '$parse' ]

	# scope: # for documentation purposes ('cause they're implemented manually to get away with not needing an isolated scope just for this directive)
	# 	onError: '&'
	# 	onLoad : '&'
	# 	palette: '=?'

	link: ( $scope, $element, $attrs ) ->
		super

		onError = => $scope.$evalAsync =>
			@$parse( $attrs.onError ) $scope if $attrs.onError
		$element.bind 'error', onError
		$scope.$on '$destroy', -> $element.unbind 'error', onError

	controller: class ImgController extends angoolar.BaseDirectiveController
		$_name: 'ImgController'

		$_dependencies: [
			'$parse'
			angoolar.PaletteManager
		]

		constructor: ->
			super

			loaded = => @$scope.$evalAsync @loaded
			@$element.bind 'load', loaded
			@$scope.$on '$destroy', =>
				@$element.unbind 'load', loaded

			if @$element[ 0 ]?.complete
				@loaded()

			@paletteSetter = @$parse( @$attrs.palette ).assign if @$attrs.palette

		loaded: =>
			@$parse( @$attrs.onLoad ) @$scope if @$attrs.onLoad
			@$scope.$emit '$_imgLoaded', @$element.attr 'src'
			@paletteSetter? @$scope, @PaletteManager.get @$element.attr 'src'
	