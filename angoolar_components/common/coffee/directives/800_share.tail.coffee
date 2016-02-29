twitterPromise   = null
linkedInPromise  = null
tumblrPromise    = null

class ShareController extends angoolar.BaseDirectiveController
	$_name: 'ShareController'

	$_dependencies: [ '$location', '$document' ]

	widget:
		facebook : 'facebook'
		twitter  : 'twitter'
		pinterest: 'pinterest'
		linkedin : 'linkedin'
		tumblr   : 'tumblr'

	widgetImage:
		facebook : "@shtml.dir@/images/share-widget/facebook.png"
		twitter  : "@shtml.dir@/images/share-widget/twitter.png"
		pinterest: "@shtml.dir@/images/share-widget/pinterest.png"
		linkedin : "@shtml.dir@/images/share-widget/linkedin.png"
		tumblr   : "@shtml.dir@/images/share-widget/tumblr.png"

	defaults:
		facebookAppId: '@facebook.key@'
		size         : 'h2'
		widgets      : "#{
			ShareController::widget.facebook
		}|#{
			ShareController::widget.twitter
		}|#{
			ShareController::widget.linkedin
		}"

	getDefaultUrl        : -> @$location.absUrl()
	getDefaultTitle      : -> angular.element( 'title',                           document.head )[ 0 ]?.text
	getDefaultDescription: -> angular.element( "meta[property='og:description']", document.head )[ 0 ]?.content
	getDefaultImage      : -> angular.element( "meta[property='og:image']",       document.head )[ 0 ]?.content

	facebookStyles:
		height: 86
		width : 97

	tumblrStyles:
		display    : "inline-block"
		textIndent : "-9999px"
		overflow   : "hidden"
		width      : "81px"
		height     : "20px"
		background : "url('//platform.tumblr.com/v1/share_1.png') top left no-repeat transparent"

	constructor: ->
		super

		# This takes care of only displaying the respective widgets when their requisite JS libraries have asynchronously loaded.
		twitterPromise.then  => @twitterLoaded  = yes
		linkedInPromise.then => @linkedInLoaded = yes
		tumblrPromise.then   => @tumblrLoaded   = yes
		@$scope.$watch ( => @twitterLoaded  ), => if @twitterLoaded  then setTimeout -> twttr.widgets?.load?()
		@$scope.$watch ( => @linkedInLoaded ), => if @linkedInLoaded then setTimeout -> IN.parse?()
		@$scope.$watch ( => @tumblrLoaded   ), => if @tumblrLoaded   then setTimeout -> Tumblr.activate_share_on_tumblr_buttons?()

		# This takes care of adding the options.parameters to the URL (truncating any existing parameters) when parameters is defined.
		@$scope.$watchGroup [ 'url', 'options.parameters' ], ( args ) =>
			[ url, parameters ] = args

			return @$scope.url = url unless url && parameters

			parametersString = angular.element.param parameters

			if -1 is url.indexOf parametersString # if the url does not already contain the parameterString, then PUT IT THERE.
				if ( questionIndex = url.indexOf '?' ) >= 0 # and if it already has any query parameters
					url = url.substr 0, questionIndex # then STRIP the existing query parameters
				@$scope.url = "#{ url }?#{ parametersString }" # and PUT the new parameters there

		# This takes care of setting the widget order array whenever the widgets expression changes
		@$scope.$watch 'widgets', ( widgets ) =>
			return unless angular.isString widgets

			# Splits the string into segments of 2 (with a trailing 1-character segment if odd):
			@widgetArray = widgets.split '|'

	getWidgetClasses: ( widget ) ->
		classes = {}
		classes[ widget ]       = yes if @widget[ widget ]
		classes[ @$scope.size ] = yes
		classes

	getFacebookSrc: ->
		@$scope.url = @$scope.url or @getDefaultUrl()
		"//www.facebook.com/v2.3/plugins/like.php?#{ angular.element.param(
			angular.extend( {
				href      : @$scope.url
				appId     : @$scope.facebookAppId
				layout    : 'box_count'
				action    : 'like'
				show_faces: false
				share     : true
			}, @facebookStyles )
		) }"

	getPinterestHref: ->
		"//www.pinterest.com/pin/create/button/?#{ angular.element.param(
			url  : @$scope.url
			media: @$scope.image
		) }"

	getTumblrSrc: ->
		"//www.tumblr.com/share/link?#{ angular.element.param(
			url        : @$scope.url
			name       : @$scope.title
			description: @$scope.description
		) }"

angoolar.addDirective class Share extends angoolar.BaseTemplatedDirective
	$_name: 'Share'

	$_dependencies: [ '$q', angoolar.FileLoader ]

	scope:
		options      : '=?' + @::$_makeName()
		url          : '@'
		facebookAppId: '@'
		title        : '@'
		description  : '@'
		image        : '@'
		size         : '@'
		widgets      : '@'

	scopeDefaultExpressions:
		url          : 'options.url           || ShareController.getDefaultUrl()'
		facebookAppId: 'options.facebookAppId || ShareController.defaults.facebookAppId'
		title        : 'options.title         || ShareController.getDefaultTitle()'
		description  : 'options.description   || ShareController.getDefaultDescription()'
		image        : 'options.image         || ShareController.getDefaultImage()'
		size         : 'options.size          || ShareController.defaults.size'
		widgets      : 'options.widgets       || ShareController.defaults.widgets'

	compile: ->
		super

		twitterPromise   = @FileLoader.loadScript '//platform.twitter.com/widgets.js', -> twttr?
		linkedInPromise  = @FileLoader.loadScript '//platform.linkedin.com/in.js',     -> IN?
		tumblrPromise    = @FileLoader.loadScript '//platform.tumblr.com/v1/share.js', -> Tumblr?

		@FileLoader.loadScript '//assets.pinterest.com/js/pinit.js'

	controller: ShareController
