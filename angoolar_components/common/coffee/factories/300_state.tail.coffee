$body   = null
$html   = null
$window = null

angoolar.addFactory class angoolar.State extends angoolar.BaseFactory
	$_name: 'State'

	$_dependencies: [
		'$window',
		'$animate',
		'$document',
		'$rootScope'
		'$timeout'
		'$injector'
		angoolar.CookieManager
		angoolar.PersistentState
	]

	maxMobileWidth: 480
	maxTabletWidth: 768

	constructor: ->
		super

		$window = angular.element @$window
		$html = @$document.find 'html'
		$body = @$document.find 'body'

		@debouncedOnResize = _.debounce @onResize, 0

		@enableResponsiveDesign()

		@$rootScope.$watch ( => @windowHeight - ( @headerHeight or 0 ) ), ( viewportHeight ) =>
			@viewportHeight = Math.max 300, viewportHeight

		@stickyAreaChildrenHeights = {}
		@stickyAreasHeight         = 0

		@$rootScope.$watch ( => @headerStuck ), =>
			@$timeout ( => @$rootScope.$broadcast 'resize' ), angoolar.AnimationHelper::slowDuration

	enableResponsiveDesign: =>
		return if $body.hasClass 'mobile-when-tablet'

		$body.addClass 'mobile-when-tablet'

		@updateWindowWidth()
		@updateResponsiveness()

		$window.bind 'resize', @debouncedOnResize

	disableResponsiveDesign: =>
		return unless $body.hasClass 'mobile-when-tablet'

		$body.removeClass 'mobile-when-tablet'

		$window.unbind 'resize', @debouncedOnResize

	onResize: =>
		wasTablet = @isTablet
		wasMobile = @isMobile
		@updateWindowWidth()
		@updateResponsiveness()

		@$rootScope.$digest() if @isTablet isnt wasTablet or @isMobile isnt wasMobile

	updateWindowWidth: ->
		@windowWidth = $html[ 0 ].offsetWidth

	updateResponsiveness: ->
		@isTablet = @windowWidth <= @maxTabletWidth
		@isMobile = @windowWidth <= @maxMobileWidth

	setWindowSize: ( @windowWidth, @windowHeight ) -> @viewportWidth = @windowWidth
	setHeaderSize: ( @headerWidth, @headerHeight ) ->
		
	setStickyAreaChildrenHeight: ( stickyAreaId, childrenHeight ) ->
		@stickyAreaChildrenHeights[ stickyAreaId ] = childrenHeight
		@stickyAreasHeight = Math.max ( height for key, height of @stickyAreaChildrenHeights )...

	scrollToTop: ->
		@$rootScope.scrollToTop = no
		@$timeout => @$rootScope.scrollToTop = yes

