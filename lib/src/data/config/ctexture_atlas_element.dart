 part of stagexl_gaf;

	/**
	 * @
	 */
	 class CTextureAtlasElement
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  PRIVATE VARIABLES
		//
		//--------------------------------------------------------------------------

		 String _id;
		 String _linkage;
		 String _atlasID;
		 Rectangle _region;
		 Matrix _pivotMatrix;
		 Rectangle _scale9Grid;
		 bool _rotated;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 CTextureAtlasElement(String id,String atlasID)
		{
			this._id = id;
			this._atlasID = atlasID;
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

		  String get id
		{
			return this._id;
		}

		  Rectangle get region
		{
			return this._region;
		}

		  void set region(Rectangle region)
		{
			_region = region;
		}

		  Matrix get pivotMatrix
		{
			return this._pivotMatrix;
		}

		  void set pivotMatrix(Matrix pivotMatrix)
		{
			this._pivotMatrix = pivotMatrix;
		}

		  String get atlasID
		{
			return this._atlasID;
		}

		  Rectangle get scale9Grid
		{
			return this._scale9Grid;
		}

		  void set scale9Grid(Rectangle value)
		{
			this._scale9Grid = value;
		}

		  String get linkage
		{
			return this._linkage;
		}

		  void set linkage(String value)
		{
			this._linkage = value;
		}

		  bool get rotated
		{
			return this._rotated;
		}

		  void set rotated(bool value)
		{
			this._rotated = value;
		}
	}
