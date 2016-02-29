angoolar.addConfigBlock class AppConfig extends angoolar.BaseBlock
	$_dependencies: [
		'$animateProvider'
		'$sceDelegateProvider'
		'$httpProvider'
		'$logProvider'
	]

	constructor: ->
		super

		@$animateProvider.classNameFilter /c-animate/

		@$sceDelegateProvider.resourceUrlWhitelist [
			'self'
			"#{ angoolar.staticFilePath }**"
			/^(https?:)?\/\/www\.facebook\.com\/.*/
			/^(https?:)?\/\/twitter\.com\/.*/
			/^(https?:)?\/\/www\.pinterest\.com\/.*/
			/^(https?:)?\/\/platform\.tumblr\.com\/.*/
			/^(https?:)?\/\/(www\.youtube\.com|youtu\.be)\/.*/
			/^(https?:)?\/\/(www\.)?(player\.)?vimeo\.com\/.*/
		]

		@$httpProvider.defaults.withCredentials = yes

		@$logProvider.debugEnabled '@frontend.web.environment@' is 'development'

		moment.relativeTimeThreshold 's', 59
		moment.relativeTimeThreshold 'm', 59
		moment.relativeTimeThreshold 'h', 23
		moment.relativeTimeThreshold 'd', 30
		moment.relativeTimeThreshold 'M', 11
