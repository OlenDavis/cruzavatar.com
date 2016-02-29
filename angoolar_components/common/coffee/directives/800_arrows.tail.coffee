class ArrowsController extends angoolar.BaseDirectiveController
	$_name: 'ArrowsController'

	$images:
		black:
			left: "#{ angoolar.imgPath }arrow-left-default.png"
			right: "#{ angoolar.imgPath }arrow-right-default.png"
		white:
			left: "#{ angoolar.imgPath }arrow-left-default-white.png"
			right: "#{ angoolar.imgPath }arrow-right-default-white.png"

angoolar.addDirective class Arrows extends angoolar.BaseTemplatedDirective
	$_name: 'Arrows'

	controller: ArrowsController

	scope:
		showLeft       : '='
		showRight      : '='
		onLeftClick    : '&'
		onRightClick   : '&'
		containerHeight: '='
		arrowWidth     : '@'
		external       : '=?'
		arrowColor     : '@'

	scopeDefaults:
		arrowWidth: '1.4em'
		arrowColor: 'black'