# 32 bit FNV-1a hash
# Ref.: http://isthe.com/chongo/tech/comp/fnv/
# console.log "Lorem -> #{ fnv32a 'Lorem' }" // Lorem -> 1789342528
fnv32a = ( str ) ->
	FNV1_32A_INIT = 0x811c9dc5
	hval = FNV1_32A_INIT
	for char, i in str
		hval ^= str.charCodeAt i
		hval += (hval << 1) + (hval << 4) + (hval << 7) + (hval << 8) + (hval << 24)
	hval >>> 0

angoolar.addDirective class LazyCompileChildren extends angoolar.BaseDirective
	$_name: 'LazyCompileChildren'

	$_dependencies: [ '$compile', '$animate', '$cacheFactory', '$log' ]

	scope: {}

	constructor: ->
		super
		@cache = @$cacheFactory @$_makeName()

	$_compile: ( $templateElement ) =>
		@compile.apply @, arguments

		elementHtml = $templateElement.html()
		$templateElement.empty()

		pre: @preLink
		post: ( $scope, $element, $attr ) =>
			@link.apply @, arguments

			$contentScope = $content = contentBeingRemoved = animationPromise = linkFn = null

			ifValueTrue = =>
				unless $contentScope
					$contentScope = $scope.$parent.$new()
					hashStart = Date.now()
					linkFn or= @cache.get hash = fnv32a elementHtml
					hashDuration = Date.now() - hashStart
					unless linkFn
						compileStart = Date.now()
						@cache.put hash, linkFn = @$compile elementHtml
						compileDuration = Date.now() - compileStart
					linkFn $contentScope, ( $linkedContent ) =>
						$content = $linkedContent
						@$animate.enter $content, $element

			ifValueFalse = =>
				if contentBeingRemoved
					contentBeingRemoved.remove()
					contentBeingRemoved = null

				if $contentScope
					$contentScope.$destroy()
					$contentScope = null

				if $content
					contentBeingRemoved = $content
					$content = null
					@$animate.leave( contentBeingRemoved ).then =>
						contentBeingRemoved = null

			if lazyIfExpression = $attr[ @$_makeName() ]
				$scope.$parent.$watch lazyIfExpression, ( ifValue ) ->
					if ifValue
						ifValueTrue()
					else
						ifValueFalse()
			else
				ifValueTrue()

			# $scope.$on '$destroy', ifValueFalse

