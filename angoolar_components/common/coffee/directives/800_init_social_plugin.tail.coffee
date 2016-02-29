angoolar.addDirective class InitSocialPlugin extends angoolar.BaseDirective
	$_name: 'InitSocialPlugin'

	$_dependencies: [ angoolar.FileLoader ]

	link: ( $scope, $element, $attrs ) =>
		super

		setTimeout =>
			switch $attrs[ @$_makeName() ]
				when 'twitter'
					twttr.widgets?.load?()
				when 'linkedin'
					IN.parse?()
				when 'tumblr'
					Tumblr.activate_share_on_tumblr_buttons?()
				when 'pinterest'
					@FileLoader.loadScript '//assets.pinterest.com/js/pinit.js'