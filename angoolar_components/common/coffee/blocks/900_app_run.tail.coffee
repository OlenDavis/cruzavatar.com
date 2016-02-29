angoolar.addRunBlock class AppRun extends angoolar.BaseRunBlock
	$_dependencies: [
		# just to be sure these are available anywhere we need them
		angoolar.CookieManager
		angoolar.State
		'$rootScope'
	]

	constructor: ->
		super

		@$rootScope.State = @State
		@$rootScope.isBrowser = angoolar.isBrowser
		@$rootScope.Modernizr = Modernizr
