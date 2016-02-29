angoolar.addFilter class Ordinal extends angoolar.BaseFilter
	$_name: 'Ordinal'

	# from https://gist.github.com/jlbruno/1535691
	suffixes: [ 'th', 'st', 'nd', 'rd' ]

	filter: ( value ) ->
		if angular.isNumber value
			twoDigits = value % 100
			value + ( @suffixes[ ( twoDigits - 20 ) % 10 ] or @suffixes[ twoDigits ] or @suffixes[ 0 ] )
		else
			value