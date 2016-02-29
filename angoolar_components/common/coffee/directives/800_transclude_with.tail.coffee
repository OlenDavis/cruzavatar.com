angoolar.addDirective class TranscludeWith extends angoolar.BaseDirective
	$_name: 'TranscludeWith'

	$_dependencies: [ '$parse']

	scope:
		$transclude: '=' + @::$_makeName()
		# andScope   : '=?'
		# andLocals  : '=?'

	link: ( $scope, $element, $attrs ) =>
		super

		$transcludedScope = null

		$scope.$on '$destroy', -> $transcludedScope?.$destroy()

		unwatch = $scope.$watch '$transclude', ( $transclude, $previousTransclude ) =>
			if angular.isFunction $transclude
				if $transclude isnt $previousTransclude
					$transcludedScope?.$destroy()
					$element.html ''

				linkingFunction = ( $contents, $newScope ) =>
					$transcludedScope = $newScope
					$element.append $contents

					if $attrs.andLocals
						andLocals = @$parse( $attrs.andLocals ) $scope.$parent

						if angular.isObject andLocals
							angular.extend $transcludedScope, andLocals

				andScope = @$parse( $attrs.andScope ) $scope.$parent

				if andScope and angular.isObject andScope
					$transclude andScope, linkingFunction
				else
					$transclude linkingFunction
					