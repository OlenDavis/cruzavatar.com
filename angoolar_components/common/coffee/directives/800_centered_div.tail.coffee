angoolar.addDirective class CenteredDiv extends angoolar.BaseTemplatedDirective
	$_name: 'CenteredDiv'

	transclude: yes

	scope:
		mode: '@'

	controller: class CenteredDivController extends angoolar.BaseDirectiveController
		$_name: 'CenteredDivController'
