 part of stagexl_gaf;
	/**
	 * @
	 */
	 class CTextureAtlasCSF
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
		 num _csf;

		 List<CTextureAtlasSource> _sources;

		 CTextureAtlasElements _elements;

		 CTextureAtlas _atlas;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 CTextureAtlasCSF(num csf,num scale)
		{
			this._csf = csf;
			this._scale = scale;

			this._sources = new List<CTextureAtlasSource>();
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		  void dispose()
		{
			(this._atlas) ? this._atlas.dispose() : null;

			this._atlas = null;
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

		  num get csf
		{
			return this._csf;
		}

		  List<CTextureAtlasSource> get sources
		{
			return this._sources;
		}

		  void set sources(List<CTextureAtlasSource> sources)
		{
			this._sources = sources;
		}

		  CTextureAtlas get atlas
		{
			return this._atlas;
		}

		  void set atlas(CTextureAtlas atlas)
		{
			this._atlas = atlas;
		}

		  CTextureAtlasElements get elements
		{
			return this._elements;
		}

		  void set elements(CTextureAtlasElements elements)
		{
			this._elements = elements;
		}
	}
