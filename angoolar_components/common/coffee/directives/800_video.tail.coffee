lastVideoId = 0
lastShownVideoId = null
facebookLoadPromise = null

angoolar.addDirective class Video extends angoolar.BaseTemplatedDirective
	$_name: 'Video'

	scope:
		image                : '@'
		video                : '@'
		cantShowVideo        : '=?'
		allowSimultaneousPlay: '=?'
		videoInfoCode        : '@' # The submission code for the video, if desired. 

	scopeDefaults:
		ratioWidth : 16
		ratioHeight: 9

	$_addClass: no # don't add the 'video' class to instances of the template

	$_dependencies: [ angoolar.FileLoader ]

	constructor: ->
		super

		facebookLoadPromise = @FileLoader.loadScript '//connect.facebook.net/en_US/sdk.js#xfbml=1&version=v2.3', -> FB?

	controller: class VideoController extends angoolar.BaseDirectiveController
		$_name: 'VideoController'

		$_dependencies: [
			'$timeout'
			angoolar.LoggingManager
			angoolar.VideoFileInfoManager
		]

		videoRegExpByEmbedType:
			FACEBOOK_V2_3: new RegExp '^https?://www\\.facebook\\.com/' # ([^/]+/videos/[^/\\?#]+|video\.php)
			HOSTED       : new RegExp '/@project.name@/video-popup\\.html|https?://[^/]*@base.host@[^/]*'
			YOUTUBE      : new RegExp '^https?://(?:www\\.youtube\\.com/watch\\?v=|youtu\\.be/)([^\\?#&]+)'
			VIMEO        : new RegExp '^https?://(?:www\\.)?(?:player\\.)?vimeo\\.com/(?:channels/(?:\\w+/)?|groups/(?:[^/]*)/videos/|album/\\d+/video/|video/|)(\\d+)'
			UPLOADED     : new RegExp '^https?://tongal\\.s3\\.amazonaws\\.com/'

		duration      : 800
		durationFactor: 1.25
		durationMax   : 5000

		constructor: ->
			super

			@id = ++lastVideoId

			@videoFileInfo = @VideoFileInfoManager.ensureInstance()

			@$scope.$watch 'videoInfoCode', ( videoInfoCode ) =>
				@videoFileInfo = @VideoFileInfoManager.get videoInfoCode

			@$scope.$watch 'video', ( video ) =>
				# Here we set the type of embedded video this is (which has a dramatic effect on how the video is played and how this whole directive behaves)
				for embedType, videoRegExp of @videoRegExpByEmbedType when videoRegExp.test video
					@embedType = embedType
					break

				@embedType = 'HOSTED' unless @embedType # default to treating the video as a HOSTED video

				# If it's one of our hosted videos, this block of logic ensures its URL has the current page's pageType query parameter for accurate logging of where videos' views are coming from.
				if @embedType is 'HOSTED' and @LoggingManager.$defaults.pageType and not /pageType=/ig.test video
					matches = video.match /^([^\?]+)(?:\?(.*))?$/ # Extracts everything before the ? of the video URL into the first group and everything after it into the second.
					if matches?.length >= 2
						@$scope.video = "#{ matches[ 1 ] }?pageType=#{ encodeURIComponent @LoggingManager.$defaults.pageType }&#{ matches[ 2 ] || '' }"
				else
					@cantShowVideo = no
					if @embedType is 'YOUTUBE'
						@youtubeVideo = "https://www.youtube.com/embed/#{ @$scope.video.match( @videoRegExpByEmbedType.YOUTUBE )[ 1 ] }"
					else if @embedType is 'VIMEO'
						@vimeoVideo = "https://player.vimeo.com/video/#{ @$scope.video.match( @videoRegExpByEmbedType.VIMEO )[ 1 ] }"

			@$scope.$watch ( => @showVideo ), =>
				lastShownVideoId = @id if @showVideo

			@$scope.$watch ( -> lastShownVideoId ), =>
				unless lastShownVideoId is @id
					unless @$scope.allowSimultaneousPlay or @$scope.$root.isBrowser.Mobile
						@showVideo = no

			@$scope.$watch "#{ @$_name }.beingTranscoded || ( #{ @$_name }.embedType != 'HOSTED' && #{ @$_name }.embedType != 'UPLOADED' && ! cantShowVideo )", ( @busy ) =>

			@$scope.$watch '$root.isBrowser.Mobile', ( isMobile ) =>
				@showVideo or= isMobile

		initFacebook: =>
			facebookLoadPromise.then ->
				FB.init
					appId  : '@facebook.key@'
					status : true
					cookie : true
					xfbml  : true
					version: 'v2.3'

		reloadVideo: ->
			@cantShowVideo = yes
			@$timeout ( => @cantShowVideo = no ), 500

		stillTranscoding: ->
			@beingTranscoded = @waitingToCheckTranscoding = yes
			@$timeout.cancel @timeoutHandle if @timeoutHandle
			@timeoutHandle = @$timeout ( => @waitingToCheckTranscoding = no ), @duration = Math.min @durationMax, @duration * @durationFactor

		doneTranscoding: =>
			@beingTranscoded = no
			if @timeoutHandle
				@$timeout.cancel @timeoutHandle
				@timeoutHandle = null
