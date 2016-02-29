$body = null

class angoolar.RelocatedTemplatedDirective extends angoolar.BaseTemplatedDirective

	constructor: ->
		super

		$body or= angular.element 'body'

	link: ( scope, iElement ) ->
		super

		$body.append iElement.detach()

		scope.$on '$destroy', => iElement.remove()
