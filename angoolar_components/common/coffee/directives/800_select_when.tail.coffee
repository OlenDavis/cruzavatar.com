angoolar.addDirective class SelectWhen extends angoolar.BaseDirective
	$_name: 'SelectWhen'

	controller: class SelectWhenController extends angoolar.BaseDirectiveController
		$_name: 'SelectWhenController'

		constructor: ->
			super

			@$attrs.$observe SelectWhen::$_makeName(), ( @event ) =>

			@$scope.$watch ( => @event ), ( event, lastEvent ) =>
				@$element.unbind lastEvent, @select if lastEvent
				@$element.bind   event,     @select if event

			@$scope.$on '$destroy', =>
				@$element.unbind @event, @select if @event

		select: => @$element[ 0 ].select()