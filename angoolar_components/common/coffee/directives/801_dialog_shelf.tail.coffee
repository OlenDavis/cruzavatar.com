wholeRegex = /^\s*([\s\S]+?)\s+in\s+([\s\S]+?)\s*$/

angoolar.addDirective class angoolar.DialogShelf extends angoolar.Dialog
	$_name: 'DialogShelf'

	scope:
		shownIndex : '=?'
		fixedArrows: '=?'

	scopeDefaults:
		mode    : 'whole-width'
		maxWidth: '850px'
		minWidth: '250px'

	scopeDefaultExpressions:
		width: "$root.State.isMobile ? '100%' : ''"

	controller: class DialogShelfController extends angoolar.Dialog::controller
		$_name: 'DialogShelfController'

		$_dependencies: [ '$parse' ]

		constructor: ->
			super

			@$scope.$watch '$root.State.isTablet || fixedArrows', ( @fixedArrows ) =>

			dialogExpression = @$attrs[ DialogShelf::$_makeName() ]
			wholeMatches = dialogExpression.match wholeRegex

			unless wholeMatches
				throw new Error "#{ DialogShelf::$_makeName() } expression expected to be of the form '_item_ in _collection_', got '#{ dialogExpression }'."

			@contentSetter     = @$parse( wholeMatches[ 1 ] ).assign
			contentsExpression = wholeMatches[ 2 ]

			@$scope.$parent.$watchCollection contentsExpression, @contentsUpdated

			@$scope.$watch 'shown',      @shownUpdated
			@$scope.$watch 'shownIndex', @shownIndexUpdated

			@$scope.$watch ( => @$contents?.length ), ( length ) =>
				return unless @$scope.shown

				if length
					@$scope.shownIndex = Math.max 0, Math.min length - 1, @$scope.shownIndex
				else
					@$scope.shown = null

			@$scope.$watch '( width || maxWidth ) && ( mode || "" ).indexOf( "whole-width" ) != -1', ( @wholeWidthWithWidth ) =>

		shownUpdated: =>
			return @$scope.shownIndex = null unless @$scope.shown

			@$scope.shownIndex = @$scope.shownIndex or 0

			unless @$contents[ @$scope.shownIndex ] is @$scope.shown
				@$scope.shownIndex = Math.max 0, _.indexOf @$contents, @$scope.shown

		shownIndexUpdated: ( shownIndex ) =>
			@$scope.shown = @$contents[ @$scope.shownIndex ] if @$scope.shownIndex >= 0

		contentsUpdated: ( contents ) =>
			if angular.isArray contents
				@$contents = contents
			else
				( @$contents = @$contents or new Array() ).length = 0
				if contents?
					@$contents.push content for content in contents

		indexVisible: ( index ) ->
			@indexWithin index, 1

		indexReady: ( index ) ->
			@indexWithin index, 2

		indexWithin: ( index, range ) ->
			Math.abs( @$scope.shownIndex - index ) <= range

		canGoLeft : ( index = @$scope.shownIndex ) -> index > 0
		canGoRight: ( index = @$scope.shownIndex ) -> index < @$contents.length - 1

		goLeft: ->
			return unless @canGoLeft()

			@dontHide()

			@$scope.shownIndex -= 1

		goRight: ->
			return unless @canGoRight()

			@dontHide()

			@$scope.shownIndex += 1

		getContentScope: ( content, $first, $last ) ->
			contentScope = @$scope.$parent.$new()
			contentScope.$first = $first
			contentScope.$last  = $last
			@contentSetter contentScope, content
			contentScope

angoolar.addDirective class DialogShelfContent extends angoolar.BaseDirective
	$_name: 'DialogShelfContent'

	$_requireParents: [ angoolar.DialogShelf ]

	controller: class DialogShelfContentController extends angoolar.BaseDirectiveController
		$_name: 'DialogShelfContentController'

		$_link: ->
			super

			@$contentScope = @DialogShelfController.getContentScope( @$scope.content )
			@$scope.$on '$destroy', => @$contentScope.$destroy()

			@DialogShelfController.$transclude @$contentScope, ( dialogContent ) =>
				@$element.append dialogContent
