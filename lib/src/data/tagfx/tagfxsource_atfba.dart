/**
 * Created by Nazar on 13.01.2016.
 */
 part of stagexl_gaf;



	/**
	 * @
	 */
	 class TAGFXSourceATFBA extends TAGFXBase
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

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 TAGFXSourceATFBA(ByteList source)
		{
			this._source = source;
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

		@override 
		  String get sourceType
		{
			return TAGFXBase.SOURCE_TYPE_ATF_BA;
		}

		@override 
		  Texture get texture
		{
			if (!this._texture)
			{
				this._texture = Texture.fromAtfData(this._source, this._textureScale, GAF.useMipMaps, this.onTextureCreated);
				this._texture.root.onRestore = ()
				{
					_texture.root.uploadAtfData(_source, 0, onTextureCreated);
				};
			}

			return this._texture;
		}

		//--------------------------------------------------------------------------
		//
		//  EVENT HANDLERS
		//
		//--------------------------------------------------------------------------

		  void onTextureCreated(Texture texture)
		{
			if (this._clearSourceAfterTextureCreated)
				(this._source as ByteList).clear();
		}

		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------

		//--------------------------------------------------------------------------
		//
		//  STATIC METHODS
		//
		//--------------------------------------------------------------------------
	}