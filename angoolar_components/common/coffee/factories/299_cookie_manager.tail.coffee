angoolar.addFactory class angoolar.CookieManager extends angoolar.BaseFactory
	$_name: 'CookieManager'

	$_autoAttachToDependency: '$rootScope'

	$_dependencies: [ '$document' ]

	redirectExpires: if angoolar.isBrowser.Mobile then new Date(new Date().getTime() + 900000).toUTCString() else ''  # 900000 = 15 min = 15 * 60 * 1000

	defaultExpires: new Date( new Date().getTime() + 2592000000 ).toUTCString() # 2592000000 = 30 days = 30 * 24 * 60 * 60 * 1000

	setRedirectUrl: ( url ) ->
		# if url is empty then current location
		url = encodeURIComponent(url or (document.location.pathname + document.location.search + document.location.hash))
		# clear it first for all sub-domains
		document.cookie = "prevUrl=;domain=tongal.com;expires=Thu, 01 Jan 1970 00:00:01 GMT;path=/";
		document.cookie = "prevUrl=;domain=.tongal.com;expires=Thu, 01 Jan 1970 00:00:01 GMT;path=/";
		document.cookie = "prevUrl=#{ url }; domain=@base.host@; expires=#{ @redirectExpires }; path=/" if url?.length

	get: ( name ) ->
		cookies = document.cookie.split(';')
		nameEQ = name + '='
		for c in cookies
			c = c.replace(/(^\s+)/, '')
			if !c.indexOf(nameEQ)
				return decodeURIComponent(c.substr(nameEQ.length))
		return null

	put: ( name, value ) ->
		document.cookie = "#{ name }=#{ encodeURIComponent value }; expires=#{ @defaultExpires }; path=/"

	remove: ( name ) ->
		document.cookie = "#{ name }=;"
