 part of stagexl_gaf;

	/**
	 * @
	 */
	 class CAnimationObject
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------

		 static const String TYPE_TEXTURE = "texture";
		 static const String TYPE_TEXTFIELD = "textField";
		 static const String TYPE_TIMELINE = "timeline";

		//--------------------------------------------------------------------------
		//
		//  PRIVATE VARIABLES
		//
		//--------------------------------------------------------------------------

		 String _instanceID;
		 String _regionID;
		 String _type;
		 bool _mask;
		 Point _maxSize;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 CAnimationObject(String instanceID,String regionID,String type,bool mask)
		{
			this._instanceID = instanceID;
			this._regionID = regionID;
			this._type = type;
			this._mask = mask;
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		// OVERRIDDEN METHODS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  EVENT HANDLERS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------

		  String get instanceID
		{
			return this._instanceID;
		}

		  String get regionID
		{
			return this._regionID;
		}

		  bool get mask
		{
			return this._mask;
		}

		  String get type
		{
			return this._type;
		}

		  Point get maxSize
		{
			return this._maxSize;
		}

		  void set maxSize(Point value)
		{
			this._maxSize = value;
		}
	}
