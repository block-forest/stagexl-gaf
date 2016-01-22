 part of stagexl_gaf;


	/**
	 * <p>GAFTimeline represents converted GAF file. It is like a library symbol in Flash IDE that contains all information about GAF animation.
	 * It is used to create <code>GAFMovieClip</code> that is ready animation object to be used in starling display list</p>
	 */
	 class GAFTimeline
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------

		 static const String CONTENT_ALL = "contentAll";
		 static const String CONTENT_DEFAULT = "contentDefault";
		 static const String CONTENT_SPECIFY = "contentSpecify";

		//--------------------------------------------------------------------------
		//
		//  PRIVATE VARIABLES
		//
		//--------------------------------------------------------------------------

		 GAFTimelineConfig _config;

		 GAFSoundData _gafSoundData;
		 GAFGFXData _gafgfxData;
		 GAFAsset _gafAsset;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------

		/**
		 * Creates an GAFTimeline object
		 * @param timelineConfig GAF timeline config
		 */
	 GAFTimeline(GAFTimelineConfig timelineConfig)
		{
			this._config = timelineConfig;
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		// --------------------------------------------------------------------------

		/**
		 * Returns GAF Texture by name of an instance inside a timeline.
		 * @param animationObjectName name of an instance inside a timeline
		 * @return GAF Texture
		 */
		  IGAFTexture getTextureByName(String animationObjectName)
		{
			String instanceID = this._config.getNamedPartID(animationObjectName);
			if( instanceID != null || instanceID == true)
			{
				CAnimationObject part = this._config.animationObjects.getAnimationObject(instanceID);
				if( part != null || part == true)
				{
					return this.textureAtlas.getTexture(part.regionID);
				}
			}
			return null;
		}

		/**
		 * Disposes the underlying GAF timeline config
		 */
		  void dispose()
		{
			this._config.dispose();
			this._config = null;
			this._gafAsset = null;
			this._gafgfxData = null;
			this._gafSoundData = null;
		}

		/**
		 * Load all graphical data connected with this asset in device GPU memory. Used in case of manual control of GPU memory usage.
		 * Works only in case when all graphical data stored in RAM (<code>Starling.handleLostContext</code> should be set to <code>true</code>
		 * before asset conversion)
		 *
		 * @param content content type that should be loaded. Available types: <code>CONTENT_ALL, CONTENT_DEFAULT, CONTENT_SPECIFY</code>
		 * @param scale in case when specified content is <code>CONTENT_SPECIFY</code> scale and csf should be set in required values
		 * @param csf in case when specified content is <code>CONTENT_SPECIFY</code> scale and csf should be set in required values
		 */
		  void loadInVideoMemory([String content="contentDefault", num scale, num csf])
		{
			if (this._config.textureAtlas == null || this._config.textureAtlas.contentScaleFactor.elements == null)
			{
				return;
			}

			Map textures;
			CTextureAtlasCSF csfConfig;

			switch (content)
			{
				case CONTENT_ALL:
					for (CTextureAtlasScale scaleConfig in this._config.allTextureAtlases)
					{
						for (csfConfig in scaleConfig.allContentScaleFactors)
						{
							this._gafgfxData.createTextures(scaleConfig.scale, csfConfig.csf);

							textures = this._gafgfxData.getTextures(scaleConfig.scale, csfConfig.csf);
							if (csfConfig.atlas == null && textures != null)
							{
								csfConfig.atlas = CTextureAtlas.createFromTextures(textures, csfConfig);
							}
						}
					}
					return;

				case CONTENT_DEFAULT:
					csfConfig = this._config.textureAtlas.contentScaleFactor;

					if (csfConfig == null)
					{
						return;
					}

					if (csfConfig.atlas == null && this._gafgfxData.createTextures(this.scale, this.contentScaleFactor))
					{
						csfConfig.atlas = CTextureAtlas.createFromTextures(this._gafgfxData.getTextures(this.scale, this.contentScaleFactor), csfConfig);
					}

					return;

				case CONTENT_SPECIFY:
					csfConfig = this.getCSFConfig(scale, csf);

					if (csfConfig == null)
					{
						return;
					}

					if (csfConfig.atlas == null && this._gafgfxData.createTextures(scale, csf))
					{
						csfConfig.atlas = CTextureAtlas.createFromTextures(this._gafgfxData.getTextures(scale, csf), csfConfig);
					}
					return;
			}
		}

		/**
		 * Unload all all graphical data connected with this asset from device GPU memory. Used in case of manual control of video memory usage
		 *
		 * @param content content type that should be loaded (CONTENT_ALL, CONTENT_DEFAULT, CONTENT_SPECIFY)
		 * @param scale in case when specified content is CONTENT_SPECIFY scale and csf should be set in required values
		 * @param csf in case when specified content is CONTENT_SPECIFY scale and csf should be set in required values
		 */
		  void unloadFromVideoMemory([String content="contentDefault", num scale, num csf])
		{
			if (this._config.textureAtlas == null || this._config.textureAtlas.contentScaleFactor.elements == null)
			{
				return;
			}

			CTextureAtlasCSF csfConfig;

			switch (content)
			{
				case CONTENT_ALL:
					this._gafgfxData.disposeTextures();
					this._config.dispose();
					return;
				case CONTENT_DEFAULT:
					this._gafgfxData.disposeTextures(this.scale, this.contentScaleFactor);
					this._config.textureAtlas.contentScaleFactor.dispose();
					return;
				case CONTENT_SPECIFY:
					csfConfig = this.getCSFConfig(scale, csf);
					if( csfConfig != null || csfConfig == true)
					{
						this._gafgfxData.disposeTextures(scale, csf);
						csfConfig.dispose();
					}
					return;
			}
		}

		/** @ */
		  void startSound(int frame)
		{
			CFrameSound frameSoundConfig = this._config.getSound(frame);
			if( frameSoundConfig != null || frameSoundConfig == true)
			{
				// use namespace gaf_internal;

				if (frameSoundConfig.action == CFrameSound.ACTION_STOP)
				{
					GAFSoundManager.getInstance().stop(frameSoundConfig.soundID, this._config.assetID);
				}
				else
				{
					Sound sound;
					if (frameSoundConfig.linkage != null)
					{
						sound = this.gafSoundData.getSoundByLinkage(frameSoundConfig.linkage);
					}
					else
					{
						sound = this.gafSoundData.getSound(frameSoundConfig.soundID, this._config.assetID);
					}
					Map soundOptions = {};
					soundOptions["continue"] = frameSoundConfig.action == CFrameSound.ACTION_CONTINUE;
					soundOptions["repeatCount"] = frameSoundConfig.repeatCount;
					GAFSoundManager.getInstance().play(sound, frameSoundConfig.soundID, soundOptions, this._config.assetID);
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		  CTextureAtlasCSF getCSFConfig(num scale,num csf)
		{
			CTextureAtlasScale scaleConfig = this._config.getTextureAtlasForScale(scale);

			if( scaleConfig != null || scaleConfig == true)
			{
				CTextureAtlasCSF csfConfig = scaleConfig.getTextureAtlasForCSF(csf);

				if( csfConfig != null || csfConfig == true)
				{
					return csfConfig;
				}
				else
				{
					return null;
				}
			}
			else
			{
				return null;
			}
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

		/**
		 * Timeline identifier (name given at animation's upload or assigned by developer)
		 */
		  String get id
		{
			return this.config.id;
		}

		/**
		 * Timeline linkage in a *.fla file library
		 */
		  String get linkage
		{
			return this.config.linkage;
		}

		/** @
		 * Asset identifier (name given at animation's upload or assigned by developer)
		 */
		  String get assetID
		{
			return this.config.assetID;
		}

		/** @ */
		  CTextureAtlas get textureAtlas
		{
			if (this._config.textureAtlas == null)
			{
				return null;
			}

			if (this._config.textureAtlas.contentScaleFactor.atlas == null)
			{
				this.loadInVideoMemory(CONTENT_DEFAULT);
			}

			return this._config.textureAtlas.contentScaleFactor.atlas;
		}

		/** @ */
		  GAFTimelineConfig get config
		{
			return this._config;
		}

		////////////////////////////////////////////////////////////////////////////

		/**
		 * Texture atlas scale that will be used for <code>GAFMovieClip</code> creation. To create <code>GAFMovieClip's</code>
		 * with different scale assign appropriate scale to <code>GAFTimeline</code> and only after that instantiate <code>GAFMovieClip</code>.
		 * Possible values are values from converted animation config. They are depends from project settings on site converter
		 */
		  void set scale(num value)
		{
			num scale = this._gafAsset.getValidScale(value);
			if ((scale == null))
			{
				throw new StateError(ErrorConstants.SCALE_NOT_FOUND);
			}
			else
			{
				this._gafAsset.scale = scale;
			}

			if (this._config.textureAtlas == null)
			{
				return;
			}

			num csf = this.contentScaleFactor;
			CTextureAtlasScale taScale = this._config.getTextureAtlasForScale(scale);
			if( taScale != null || taScale == true)
			{
				this._config.textureAtlas = taScale;

				CTextureAtlasCSF taCSF = this._config.textureAtlas.getTextureAtlasForCSF(csf);

				if( taCSF != null || taCSF == true)
				{
					this._config.textureAtlas.contentScaleFactor = taCSF;
				}
				else
				{
					throw new StateError("There is no csf $csf in timeline config for scalse $scale");
				}
			}
			else
			{
				throw new StateError("There is no scale $scale in timeline config");
			}
		}

		  num get scale
		{
			return this._gafAsset.scale;
		}

		/**
		 * Texture atlas content scale factor (that as csf) will be used for <code>GAFMovieClip</code> creation. To create <code>GAFMovieClip's</code>
		 * with different csf assign appropriate csf to <code>GAFTimeline</code> and only after that instantiate <code>GAFMovieClip</code>.
		 * Possible values are values from converted animation config. They are depends from project settings on site converter
		 */
		  void set contentScaleFactor(num csf)
		{
			if (this._gafAsset.hasCSF(csf))
			{
				this._gafAsset.csf = csf;
			}

			if (this._config.textureAtlas == null)
			{
				return;
			}

			CTextureAtlasCSF taCSF = this._config.textureAtlas.getTextureAtlasForCSF(csf);

			if( taCSF != null || taCSF == true)
			{
				this._config.textureAtlas.contentScaleFactor = taCSF;
			}
			else
			{
				throw new StateError("There is no csf $csf in timeline config");
			}
		}

		  num get contentScaleFactor
		{
			return this._gafAsset.csf;
		}

		/**
		 * Graphical data storage that used by <code>GAFTimeline</code>.
		 */
		  void set gafgfxData(GAFGFXData gafgfxData)
		{
			this._gafgfxData = gafgfxData;
		}

		  GAFGFXData get gafgfxData
		{
			return this._gafgfxData;
		}

		/** @ */
		  GAFAsset get gafAsset
		{
			return this._gafAsset;
		}

		/** @ */
		  void set gafAsset(GAFAsset asset)
		{
			this._gafAsset = asset;
		}

		/** @ */
		  GAFSoundData get gafSoundData
		{
			return this._gafSoundData;
		}

		/** @ */
		  void set gafSoundData(GAFSoundData gafSoundData)
		{
			this._gafSoundData = gafSoundData;
		}

		//--------------------------------------------------------------------------
		//
		//  STATIC METHODS
		//
		//--------------------------------------------------------------------------
	}
