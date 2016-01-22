 part of stagexl_gaf;



	/**
	 * Graphical data storage that used by <code>GAFTimeline</code>. It contain all created textures and all
	 * saved images as <code>BitmapData</code> (in case when <code>Starling.handleLostContext = true</code> was set before asset conversion).
	 * Used as shared graphical data storage between several GAFTimelines if they are used the same texture atlas (bundle created using "Create bundle" option)
	 */
	 class GAFGFXData
	{
		// [Deprecated(since="5.0")]
		 static final String ATF = "ATF";
		// [Deprecated(replacement="Context3DTextureFormat.BGRA", since="5.0")]
		 static final String BGRA = Context3DTextureFormat.BGRA;
		// [Deprecated(replacement="Context3DTextureFormat.BGR_PACKED", since="5.0")]
		 static final String BGR_PACKED = Context3DTextureFormat.BGR_PACKED;
		// [Deprecated(replacement="Context3DTextureFormat.BGRA_PACKED", since="5.0")]
		 static final String BGRA_PACKED = Context3DTextureFormat.BGRA_PACKED;
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

		 Map _texturesMap = {};
		 Map _taGFXMap = {};

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------

		/** @ */
	 GAFGFXData()
		{
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		/** @ */
		  void addTAGFX(num scale,num csf,String imageID,ITAGFX taGFX)
		{
			this._taGFXMap[scale] ??= {};
			this._taGFXMap[scale][csf] ??= {};
			this._taGFXMap[scale][csf][imageID] ??= taGFX;
		}

		/** @ */
		  Map getTAGFXs(num scale,num csf)
		{
			if (this._taGFXMap != null)
			{
				if (this._taGFXMap[scale])
				{
					return this._taGFXMap[scale][csf];
				}
			}

			return null;
		}

		/** @ */
		  ITAGFX getTAGFX(num scale,num csf,String imageID)
		{
			if (this._taGFXMap != null)
			{
				if (this._taGFXMap[scale])
				{
					if (this._taGFXMap[scale][csf])
					{
						return this._taGFXMap[scale][csf][imageID];
					}
				}
			}

			return null;
		}

		/**
		 * Creates textures from all images for specified scale and csf.
		 * @param scale
		 * @param csf
		 * @return {bool}
		 * @see #createTexture()
		 */
		  bool createTextures(num scale,num csf)
		{
			Map taGFXs = this.getTAGFXs(scale, csf);
			if( taGFXs != null || taGFXs == true)
			{
				this._texturesMap[scale] ??= {};
				this._texturesMap[scale][csf] ??= {};

				for (String imageAtlasID in taGFXs)
				{
					if (taGFXs[imageAtlasID])
					{
						addTexture(this._texturesMap[scale][csf], taGFXs[imageAtlasID], imageAtlasID);
					}
				}
				return true;
			}

			return false;
		}

		/**
		 * Creates texture from specified image.
		 * @param scale
		 * @param csf
		 * @param imageID
		 * @return {bool}
		 * @see #createTextures()
		 */
		  bool createTexture(num scale,num csf,String imageID)
		{
			ITAGFX taGFX = this.getTAGFX(scale, csf, imageID);
			if( taGFX != null || taGFX == true)
			{
				this._texturesMap[scale] ??= {};
				this._texturesMap[scale][csf] ??= {};

				addTexture(this._texturesMap[scale][csf], taGFX, imageID);

				return true;
			}

			return false;
		}

		/**
		 * Returns texture by unique key consist of scale + csf + imageID
		 */
		  Texture getTexture(num scale,num csf,String imageID)
		{
			if (this._texturesMap != null)
			{
				if (this._texturesMap[scale])
				{
					if (this._texturesMap[scale][csf])
					{
						if (this._texturesMap[scale][csf][imageID])
						{
							return this._texturesMap[scale][csf][imageID];
						}
					}
				}
			}

			// in case when there is no texture created
			// create texture and check if it successfully created
			if (this.createTexture(scale, csf, imageID))
			{
				return this._texturesMap[scale][csf][imageID];
			}

			return null;
		}

		/**
		 * Returns textures for specified scale and csf in Map as combination key-value where key - is imageID and value - is Texture
		 */
		  Map getTextures(num scale,num csf)
		{
			if (this._texturesMap != null)
			{
				if (this._texturesMap[scale])
				{
					return this._texturesMap[scale][csf];
				}
			}

			return null;
		}

		/**
		 * Dispose specified texture or textures for specified combination scale and csf. If nothing was specified - dispose all texturea
		 */
		  void disposeTextures([num scale, num csf, String imageID=null])
		{
			if ((scale == null))
			{
				for (String scaleToDispose in this._texturesMap)
				{
					this.disposeTextures(num.parse(scaleToDispose));
				}

				this._texturesMap = null;
			}
			else
			{
				if ((csf == null))
				{
					for (String csfToDispose in this._texturesMap[scale])
					{
						this.disposeTextures(scale, num.parse(csfToDispose));
					}

					this._texturesMap.remove(scale);
				}
				else
				{
					if( imageID != null || imageID == true)
					{
						(this._texturesMap[scale][csf][imageID] as Texture).dispose();

						this._texturesMap[scale][csf].remove(imageID);
					}
					else
					{
						if (this._texturesMap[scale] && this._texturesMap[scale][csf])
						{
							for(String atlasIDToDispose in this._texturesMap[scale][csf])
							{
								this.disposeTextures(scale, csf, atlasIDToDispose);
							}
							this._texturesMap[scale].remove(csf);
						}
					}
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		  void addTexture(Map dictionary,ITAGFX tagfx,String imageID)
		{
			if (DebugUtility.RENDERING_DEBUG && tagfx.sourceType == TAGFXBase.SOURCE_TYPE_BITMAP_DATA)
			{
				BitmapData bitmapData = setGrayScale(tagfx.source.clone());
				dictionary[imageID] = Texture.fromBitmapData(bitmapData, GAF.useMipMaps, false, tagfx.textureScale, tagfx.textureFormat);
			}
			else if (!dictionary[imageID])
			{
				dictionary[imageID] = tagfx.texture;
			}
		}

		  BitmapData setGrayScale(BitmapData image)
		{
			List matrix = [
				0.26231, 0.51799, 0.0697, 0, 81.775,
				0.26231, 0.51799, 0.0697, 0, 81.775,
				0.26231, 0.51799, 0.0697, 0, 81.775];

			List offsets = [
				0, 0, 0, 1, 0];

			ColorMatrixFilter filter = new ColorMatrixFilter(matrix, offsets);
			image.applyFilter(filter, new Rectangle(0, 0, image.width, image.height));
			//A3 original
			//image.applyFilter(image, new Rectangle(0, 0, image.width, image.height), new Point(0, 0), filter);

			return image;
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
