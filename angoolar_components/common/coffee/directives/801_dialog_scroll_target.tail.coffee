angoolar.addDirective class DialogScrollTarget extends angoolar.BaseDirective
	$_name: 'DialogScrollTarget'

	$_requireParents: [ angoolar.Dialog ]

	controller: class DialogScrollTargetController extends angoolar.BaseDirectiveController
		$_name: 'DialogScrollTargetController'

		$_link: ->
			super
			@DialogController?.setScrollTarget @$element
			@$scope.$on '$destroy', => @DialogController?.setScrollTarget null