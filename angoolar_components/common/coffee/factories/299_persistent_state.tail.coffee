storages =
	local  : window.localStorage
	session: window.sessionStorage

angoolar.addFactory angoolar.PersistentState = class PersistentState extends angoolar.BaseFactory
	$_name: 'PersistentState'

	$_dependencies: [ '$log' ]

	defineProperty: ( propertyName, defaultValue = null, storageType = 'local', propertyOf = @constructor::, storagePropertyName = propertyName, resourceClass ) =>
		return if @constructor::hasOwnProperty propertyName

		storage = storages[ storageType ]

		try
			value = JSON.parse value = storage.getItem storagePropertyName
		catch error
			@$log.warn "Error parsing #{ propertyName } from #{ storageType } storage:\n#{ error }\nUsing unparsed value: #{ value }"

		value = if value?
			if angular.isFunction resourceClass
				( new resourceClass ).$_fromJson JSON.parse value
			else
				value
		else
			defaultValue

		try
			Object.defineProperty propertyOf, propertyName,
				configurable: yes
				get: -> value
				set: ( newValue ) =>
					try
						if not newValue?
							storage.removeItem storagePropertyName
						else
							storage.setItem storagePropertyName, if angular.isObject( newValue ) or angular.isArray( newValue ) then JSON.stringify( newValue.$_toJson?() or newValue ) else newValue
					catch e
						@$log.warn "PersistentState set error of localStorage[ '#{ storagePropertyName }' ] = #{ newValue }\nError Message: #{ e?.message }\nStack Trace: #{ e?.stack }"
					finally
						return value = newValue
		catch
			@$log.warn "Object.defineProperty is unsupported by your browser; #{ propertyOf.$_name }'s #{ propertyName } property will not be persisted."

	defineLocalProperty: ( propertyName, defaultValue = null, args... ) =>
		@defineProperty propertyName, defaultValue, 'local', args...

	defineSessionProperty: ( propertyName, defaultValue = null, args... ) =>
		@defineProperty propertyName, defaultValue, 'session', args...

	initialize: ->
		for storageType, storage of storages
			angular.forEach Object.keys( storage ), ( propertyName, index ) => @defineProperty propertyName, null, storageType

	getProperty: ( propertyName, storageType = 'local' ) ->
		storage = storages[ storageType ]

		try
			JSON.parse storage.getItem propertyName
		catch error
			@$log.warn "Error parsing #{ propertyName } from #{ storageType } storage:\n#{ error }"

	getLocalProperty: ( propertyName ) =>
		@getProperty propertyName, 'local'

	getSessionProperty: ( propertyName ) =>
		@getProperty propertyName, 'session'
