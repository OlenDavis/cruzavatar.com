angoolar.addFactory class angoolar.DialogState extends angoolar.BaseFactory
	$_name: 'DialogState'

	$_dependencies: [ '$rootScope', '$document', '$animate' ]

	constructor: ->
		super
		@shownDialogs = 0

		$body = @$document.find 'body'

		@$rootScope.$watch ( => @shownDialogs > 0 ), ( aDialogIsShown ) =>
			$body.addClass 'c-animate'
			@$animate[ if aDialogIsShown then 'addClass' else 'removeClass' ] $body, 'dialog-shown'
