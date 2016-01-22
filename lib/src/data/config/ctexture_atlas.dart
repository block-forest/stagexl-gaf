 part of stagexl_gaf;



	/**
	 * @
	 */
	 class CTextureAtlas
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

		 Map _textureAtlasesMap;
		 CTextureAtlasCSF _textureAtlasConfig;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 CTextureAtlas(Object textureAtlasesMap,CTextureAtlasCSF textureAtlasConfig)
		{
			this._textureAtlasesMap = textureAtlasesMap;
			this._textureAtlasConfig = textureAtlasConfig;
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		 static  CTextureAtlas createFromTextures(Object texturesMap,CTextureAtlasCSF textureAtlasConfig)
		{
			Map atlasesMap = {};

			TextureAtlas atlas;

			for(CTextureAtlasElement element in textureAtlasConfig.elements.elementsList)
			{
				if (!atlasesMap[element.atlasID])
				{
					atlasesMap[element.atlasID] = new TextureAtlas(texturesMap[element.atlasID]);
				}

				atlas = atlasesMap[element.atlasID];

				atlas.addRegion(element.id, element.region, null, element.rotated);
			}

			return new CTextureAtlas(atlasesMap, textureAtlasConfig);
		}

		  void dispose()
		{
			for(TextureAtlas textureAtlas in this._textureAtlasesMap)
			{
				textureAtlas.dispose();
			}
		}

		  IGAFTexture getTexture(String id)
		{
			CTextureAtlasElement textureAtlasElement = this._textureAtlasConfig.elements.getElement(id);
			if( textureAtlasElement != null || textureAtlasElement == true)
			{
				Texture texture = this.getTextureByIDAndAtlasID(id, textureAtlasElement.atlasID);

				Matrix pivotMatrix;

				if (this._textureAtlasConfig.elements.getElement(id))
				{
					pivotMatrix = this._textureAtlasConfig.elements.getElement(id).pivotMatrix;
				}
				else
				{
					pivotMatrix = new Matrix();
				}

				if (textureAtlasElement.scale9Grid != null)
				{
					return new GAFScale9Texture(id, texture, pivotMatrix, textureAtlasElement.scale9Grid);
				}
				else
				{
					return new GAFTexture(id, texture, pivotMatrix);
				}
			}

			return null;
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		Texture getTextureByIDAndAtlasID(String id,String atlasID)
		{
			TextureAtlas textureAtlas = this._textureAtlasesMap[atlasID];

			return textureAtlas.getTexture(id);
		}

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
	}
