angoolar.addDirective class AllAccordions extends angoolar.BaseDirective
	$_name: 'AllAccordions'

	scope:
		expanded  : '=?'
		collapsed : '=?'
		accordions: '=?' + @::$_makeName()

	controller: class AllAccordionsController extends angoolar.BaseDirectiveController
		$_name: 'AllAccordionsController'

		$_dependencies: [ '$log' ]

		constructor: ->
			super
			@accordionControllers = []
			@$scope.accordions = 0
			@expanded = 0

			@$scope.$watchGroup [ ( => @expanded ), 'accordions' ], =>
				@$scope.expanded = @expanded is @$scope.accordions
				@$scope.collapsed = @expanded is 0

			@$scope.$watch 'expanded', =>
				unless arguments[ 0 ] is arguments[ 1 ]
					if @$scope.expanded
						accordionController.$scope.expanded = yes for accordionController in @accordionControllers

			@$scope.$watch 'collapsed', =>
				unless arguments[ 0 ] is arguments[ 1 ]
					if @$scope.collapsed
						accordionController.$scope.expanded = no for accordionController in @accordionControllers

		# returns deregister function
		register: ( accordionController ) =>
			return if accordionController.ExcludeAccordionsFromAllController

			++@$scope.accordions

			currentlyExpanded = no
			unwatch = @$scope.$watch ( -> accordionController.$scope.expanded ), ( expanded, oldExpanded ) =>
				currentlyExpanded = expanded
				if expanded
					++@expanded
				else if oldExpanded and not expanded
					--@expanded

			unless 0 <= _.indexOf @accordionControllers, accordionController
				@accordionControllers.push accordionController
				=>
					if ( index = _.indexOf @accordionControllers, accordionController ) >= 0
						@accordionControllers.splice index, 1
						unwatch?()
						--@$scope.accordions
						--@expanded if currentlyExpanded

angoolar.addDirective class ExcludeAccordionsFromAll extends angoolar.BaseDirective
	$_name: 'ExcludeAccordionsFromAll'

	controller: class ExcludeAccordionsFromAllController extends angoolar.BaseDirectiveController
		$_name: 'ExcludeAccordionsFromAllController'

angoolar.addDirective class Accordion extends angoolar.BaseTemplatedDirective
	$_name: 'Accordion'

	transclude: yes

	$_requireParents: [ AllAccordions, ExcludeAccordionsFromAll ]

	scope:
		label         : '@' + @::$_makeName()
		labelClass    : '@'
		iconClass     : '@'
		expanded      : '=?'
		hasHeader     : '@'
		noAnimation   : '=?'
		noInnerPadding: '=?'
		mode          : '@' # expected values: NULL, small, very-small
		version       : '@' # expected values: NULL, minor
		noStickyHeader: '=?'
		hideHeader    : '=?'
		hideContent   : '=?'
		persistWith   : '@' # This only needs to be unique among other accordions, and results in the expandedness of the accordion being persisted if provided.

	scopeDefaults:
		labelClass: 'h4'

	controller: class AccordionController extends angoolar.BaseDirectiveController
		$_name: 'AccordionController'

		$_dependencies: [ angoolar.PersistentState ]

		setAccordionContentController: ( @AccordionContentController ) ->
		setAccordionHeaderController : ( @AccordionHeaderController  ) ->

		constructor: ->
			super

			@$scope.$watch '! hideContent && ( hideHeader || expanded )', ( @expanded ) =>
				if arguments[ 0 ] is arguments[ 1 ]
					@$scope.$watch ( => @expanded ), => @$scope.expanded = @expanded

					@$scope.$watch 'persistWith', ( persistWith ) =>
						if persistWith
							@PersistentState.defineLocalProperty 'expanded', @expanded, @, "#{ persistWith }:#{ @$_name }.expanded"

		$_link: ->
			super
			if deregister = @AllAccordionsController?.register @
				@$scope.$on '$destroy', deregister

angoolar.addDirective class AccordionHeader extends angoolar.BaseDirective
	$_name: 'AccordionHeader'

	transclude: yes

	$_requireParents: [ Accordion ]

	controller: class AccordionHeaderController extends angoolar.BaseDirectiveController
		$_name: 'AccordionHeaderController'

		$_link: ->
			super

			@AccordionController.setAccordionHeaderController @

angoolar.addDirective class AccordionContent extends angoolar.BaseDirective
	$_name: 'AccordionContent'

	transclude: yes

	$_requireParents: [ Accordion ]

	controller: class AccordionContentController extends angoolar.BaseDirectiveController
		$_name: 'AccordionContentController'

		$_link: ->
			super

			@AccordionController.setAccordionContentController @
