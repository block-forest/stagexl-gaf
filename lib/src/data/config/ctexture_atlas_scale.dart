 part of stagexl_gaf;
	/**
	 * @
	 */
	 class CTextureAtlasScale
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

		 num _scale;

		 List<CTextureAtlasCSF> _allContentScaleFactors;
		 CTextureAtlasCSF _contentScaleFactor;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 CTextureAtlasScale()
		{
			this._allContentScaleFactors = new List<CTextureAtlasCSF>();
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		  void dispose()
		{
			for (CTextureAtlasCSF cTextureAtlasCSF in this._allContentScaleFactors)
			{
				cTextureAtlasCSF.dispose();
			}
		}

		  CTextureAtlasCSF getTextureAtlasForCSF(num csf)
		{
			for (CTextureAtlasCSF textureAtlas in this._allContentScaleFactors)
			{
				if (MathUtility.equals(textureAtlas.csf, csf))
				{
					return textureAtlas;
				}
			}

			return null;
		}

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

		  void set scale(num scale)
		{
			this._scale = scale;
		}

		  num get scale
		{
			return this._scale;
		}

		  List<CTextureAtlasCSF> get allContentScaleFactors
		{
			return this._allContentScaleFactors;
		}

		  void set allContentScaleFactors(List<CTextureAtlasCSF> value)
		{
			this._allContentScaleFactors = value;
		}

		  CTextureAtlasCSF get contentScaleFactor
		{
			return this._contentScaleFactor;
		}

		  void set contentScaleFactor(CTextureAtlasCSF value)
		{
			this._contentScaleFactor = value;
		}
	}
