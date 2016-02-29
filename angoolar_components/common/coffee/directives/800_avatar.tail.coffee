angoolar.addDirective class Avatar extends angoolar.BaseTemplatedDirective
	$_name: 'Avatar'

	scope:
		overlayUrl: '@?' + @::$_makeName()

	controller: class AvatarController extends angoolar.BaseDirectiveController
		$_name: 'AvatarController'

		messages: [
			'Genuine, Ted-Approved<sup>*</sup>'
			'"This is \'uge!" - Trump<sup>*</sup>'
			"Rubio's amazed.<sup>*</sup>\nCan't even take it back."
		]

		indexByDataUrl: {}

		constructor: ->
			super

			@$scope.container = {}
			@$scope.overlay   = {}
			@$scope.avatar    = {}

			@reader = new FileReader()

			@$scope.$watch ( => @selectedFile ), =>
				if @selectedFile
					@selectedFileDataUrl = null
					@reader.onload = => @$scope.$apply =>
						@selectedFileDataUrl = @reader.result
					@reader.readAsDataURL @selectedFile

		generate: ->
			@$canvas = angular.element "<canvas width='#{ @$scope.overlay.width }' height='#{ @$scope.overlay.height }'></canvas>"
			context = @$canvas[ 0 ].getContext '2d'
			avatarLeft = @$scope.avatar.left - @$scope.overlay.left
			avatarTop = @$scope.avatar.top - @$scope.overlay.top
			context.drawImage @AvatarImageController.$element[ 0 ], avatarLeft, avatarTop, @$scope.avatar.width, @$scope.avatar.height
			context.drawImage @AvatarOverlayController.$element[ 0 ], 0, 0, @$scope.overlay.width, @$scope.overlay.height
			@generatedDataUrl = @$canvas[ 0 ].toDataURL 'image/png'
			@ofSelectedFileDataUrl = @selectedFileDataUrl
			@messageIndex = -1 + ( @indexByDataUrl[ @selectedFileDataUrl ] or= 1 + Math.floor Math.random() * @messages.length )

angoolar.addDirective class AvatarInput extends angoolar.BaseDirective
	$_name: 'AvatarInput'

	link: ( $scope, $element, $attrs ) ->
		super

		$element.bind 'change', => $scope.$apply => $scope.$eval $attrs[ @$_makeName() ], files: $element[ 0 ].files

angoolar.addDirective class AvatarImage extends angoolar.BaseDirective
	$_name: 'AvatarImage'

	$_requireParents: [ Avatar ]

	controller: class AvatarImageController extends angoolar.BaseDirectiveController
		$_name: 'AvatarImageController'

		$_link: ->
			super

			@AvatarController.AvatarImageController = @

angoolar.addDirective class AvatarOverlay extends angoolar.BaseDirective
	$_name: 'AvatarOverlay'

	$_requireParents: [ Avatar ]

	controller: class AvatarOverlayController extends angoolar.BaseDirectiveController
		$_name: 'AvatarOverlayController'

		$_link: ->
			super

			@AvatarController.AvatarOverlayController = @ 
