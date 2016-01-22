/**
 * Created by Nazar on 12.01.2016.
 */
 part of stagexl_gaf;



	/**
	 * @
	 */
	 class TAGFXBase implements ITAGFX
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------

		 static final String SOURCE_TYPE_BITMAP_DATA = "sourceTypeBitmapData";
		 static final String SOURCE_TYPE_BITMAP = "sourceTypeBitmap";
		 static final String SOURCE_TYPE_PNG_BA = "sourceTypePNGBA";
		 static final String SOURCE_TYPE_ATF_BA = "sourceTypeATFBA";
		 static final String SOURCE_TYPE_PNG_URL = "sourceTypePNGURL";
		 static final String SOURCE_TYPE_ATF_URL = "sourceTypeATFURL";

		//--------------------------------------------------------------------------
		//
		//  PRIVATE VARIABLES
		//
		//--------------------------------------------------------------------------

		 Texture _texture;
		 Point _textureSize;
		 num _textureScale = -1;
		 String _textureFormat;
		 dynamic _source;
		 bool _clearSourceAfterTextureCreated;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 TAGFXBase()
		{
			if (Capabilities.isDebugger &&
					getQualifiedTypeName(this) == "com.catalystapps.gaf.data::TAGFXBase")
			{
				throw new AbstractTypeError();
			}
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

		  Texture get texture
		{
			return this._texture;
		}

		  Point get textureSize
		{
			return this._textureSize;
		}

		  void set textureSize(Point value)
		{
			this._textureSize = value;
		}

		  num get textureScale
		{
			return this._textureScale;
		}

		  void set textureScale(num value)
		{
			this._textureScale = value;
		}

		  String get textureFormat
		{
			return this._textureFormat;
		}

		  void set textureFormat(String value)
		{
			this._textureFormat = value;
		}

		  String get sourceType
		{
			throw new StateError("This is an abstract method.");
		}

		  dynamic get source
		{
			return _source;
		}

		  dynamic get clearSourceAfterTextureCreated
		{
			return this._clearSourceAfterTextureCreated;
		}

		  void set clearSourceAfterTextureCreated(bool value)
		{
			this._clearSourceAfterTextureCreated = value;
		}

		//--------------------------------------------------------------------------
		//
		//  STATIC METHODS
		//
		//--------------------------------------------------------------------------
	}
