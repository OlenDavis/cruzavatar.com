angoolar.addFilter class Unsafe extends angoolar.BaseFilter
	$_name: 'Unsafe'

	$_dependencies: [ '$sce' ]

	filter: ( html, disabled ) -> if disabled then html else @$sce.trustAsHtml html