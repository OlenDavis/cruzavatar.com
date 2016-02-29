angoolar.addDirective class angoolar.FixedProportionDiv extends angoolar.BaseTemplatedDirective
	$_name: 'FixedProportionDiv'

	transclude: yes

	scope:
		ratioWidth : '@'
		ratioHeight: '@'
		scrollable : '=?'
		withClass  : '='
		unfixed    : '=?'

	scopeDefaults:
		ratioWidth : 4
		ratioHeight: 3

	controller: class FixedProportionDivController extends angoolar.BaseDirectiveController
		$_name: 'FixedProportionDivController'
