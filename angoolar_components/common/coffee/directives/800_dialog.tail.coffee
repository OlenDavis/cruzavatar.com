class DialogController extends angoolar.BaseDirectiveController
	$_name: 'DialogController'

	$_dependencies: [ '$q', angoolar.DialogState, '$log' ]

	constructor: ->
		super

		@hasPrimaryAction   = !! @$attrs.onPrimaryAction?.length   or @$attrs.primaryAction?.length
		@hasSecondaryAction = !! @$attrs.onSecondaryAction?.length or @$attrs.secondaryAction?.length
		@hasAction          = @hasPrimaryAction or @hasSecondaryAction

		@$scope.$watch 'shown && ! neverShown', ( shown, oldShown ) =>
			if shown
				@incrementShownDialogs()
				@offDecrementShownDialogs = @$scope.$on '$destroy', => @decrementShownDialogs()
			else if oldShown and not shown
				@offDecrementShownDialogs?()
				@decrementShownDialogs()

			# # If we desperately need to put this all back, just uncomment this; and comment it out if we don't.
			# if shown
			# 	setTimeout ( ->
			# 		rpc?.attachSubmitControls()
			# 		rpc?.processFormHints()
			# 		rpc?.processJSFields()
			# 		rpc?.attachAutocompleteInputs 'form'
			# 	), 500

	incrementShownDialogs: => ++@DialogState.shownDialogs
	decrementShownDialogs: => --@DialogState.shownDialogs

	dontHide: =>
		@preventHide = yes

	hideDialog: =>
		unless @preventHide
			unless @hasSecondaryAction
				@$scope.shown = no
			else
				@doSecondaryAction()
		else
			@preventHide = no

	doPrimaryAction  : -> @doAction @$scope.onPrimaryAction
	doSecondaryAction: -> @doAction @$scope.onSecondaryAction

	doAction: ( action ) ->
		return if @$doingAction

		@$doingAction = yes
		@$q.when( action.call() ).then(
			=>
				@$scope.shown = no
				@$closeRejection = null

			( rejection ) =>
				@$closeRejection = rejection if angular.isString rejection
		).finally => @$doingAction = no

	setScrollTarget: ( @$scrollTargetElement ) ->

angoolar.addDirective class angoolar.Dialog extends angoolar.RelocatedTemplatedDirective
	$_name: 'Dialog'

	transclude: yes

	controller: DialogController

	scope:
		shown            : '='
		dialogTitle      : '@'
		mode             : '@'
		width            : '@'
		maxWidth         : '@'
		minWidth         : '@'
		primaryAction    : '@'
		secondaryAction  : '@'
		onPrimaryAction  : '&'
		onSecondaryAction: '&'
		backgroundImage  : '@'
		version          : '@' # can be 'clear' or nothing
		neverShown       : '=?'
		noForm           : '=?'
		withFormErrors   : '=?'

	scopeDefaults:
		primaryAction  : 'OK'
		secondaryAction: 'Cancel'
