/**
 * Created by Nazar on 11.06.2015.
 */
 part of stagexl_gaf;



	/** @ */
	 class GAFAsset
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

		 GAFAssetConfig _config;

		 List<GAFTimeline> _timelines;
		 Map _timelinesMap = {};
		 Map _timelinesByLinkage = {};

		 num _scale;
		 num _csf;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 GAFAsset(GAFAssetConfig config)
		{
			this._config = config;

			this._scale = config.defaultScale;
			this._csf = config.defaultContentScaleFactor;

			this._timelines = new List<GAFTimeline>();
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		/**
		 * Disposes all assets in bundle
		 */
		  void dispose()
		{
			if (this._timelines.length > 0)
			{
				for (GAFTimeline timeline in this._timelines)
				{
					timeline.dispose();
				}
			}
			this._timelines = null;

			this._config.dispose();
			this._config = null;
		}

		 void addGAFTimeline(GAFTimeline timeline)
		{
			// use namespace gaf_internal;
			if (!this._timelinesMap[timeline.id])
			{
				this._timelinesMap[timeline.id] = timeline;
				this._timelines.add(timeline);

				if (timeline.config.linkage != null)
				{
					this._timelinesByLinkage[timeline.linkage] = timeline;
				}
			}
			else
			{
				throw new StateError("Bundle error. More then one timeline use id: '" + timeline.id + "'");
			}
		}

		/**
		 * Returns <code>GAFTimeline</code> from gaf asset by linkage
		 * @param linkage linkage in a *.fla file library
		 * @return <code>GAFTimeline</code> from gaf asset
		 */
		  GAFTimeline getGAFTimelineByLinkage(String linkage)
		{
			GAFTimeline gafTimeline = this._timelinesByLinkage[linkage];

			return gafTimeline;
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		/** @
		 * Returns <code>GAFTimeline</code> from gaf asset by ID
		 * @param id internal timeline id
		 * @return <code>GAFTimeline</code> from gaf asset
		 */
		 GAFTimeline getGAFTimelineByID(String id)
		{
			return this._timelinesMap[id];
		}

		/** @
		 * Returns <code>GAFTimeline</code> from gaf asset bundle by linkage
		 * @param linkage linkage in a *.fla file library
		 * @return <code>GAFTimeline</code> from gaf asset
		 */
		 GAFTimeline _getGAFTimelineByLinkage(String linkage)
		{
			return this._timelinesByLinkage[linkage];
		}

		 IGAFTexture getCustomRegion(String linkage,[num scale, num csf])
		{
			if (scale == null) scale = this._scale;
			if (csf == null) csf = this._csf;

			IGAFTexture gafTexture;
			CTextureAtlasScale atlasScale;
			CTextureAtlasCSF atlasCSF;
			CTextureAtlasElement element;

			int tasl = this._config.allTextureAtlases.length;
			for (int i = 0; i < tasl; i++)
			{
				atlasScale = this._config.allTextureAtlases[i];
				if (atlasScale.scale == scale)
				{
					int tacsfl = atlasScale.allContentScaleFactors.length;
					for (int j = 0; j < tacsfl; j++)
					{
						atlasCSF = atlasScale.allContentScaleFactors[j];
						if (atlasCSF.csf == csf)
						{
							element = atlasCSF.elements.getElementByLinkage(linkage);

							if( element != null || element == true)
							{
								Texture texture = atlasCSF.atlas.getTextureByIDAndAtlasID(element.id, element.atlasID);
								Matrix pivotMatrix = element.pivotMatrix;
								if (element.scale9Grid != null)
								{
									gafTexture =  new GAFScale9Texture(id, texture, pivotMatrix, element.scale9Grid);
								}
								else
								{
									gafTexture =  new GAFTexture(id, texture, pivotMatrix);
								}
							}

							break;
						}
					}
					break;
				}
			}

			return gafTexture;
		}

		/** @ */
		 num getValidScale(num value)
		{
			int index = MathUtility.getItemIndex(this._config.scaleValues, value);
			if (index != -1)
			{
				return this._config.scaleValues[index];
			}
			return null;
		}

		/** @ */
		 bool hasCSF(num value)
		{
			return MathUtility.getItemIndex(this._config.csfValues, value) >= 0;
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
		 * Returns all <code>GAFTimeline's</code> from gaf asset as <code>List/code>
		 * @return <code>GAFTimeline's</code> from gaf asset
		 */
		  List<GAFTimeline> get timelines
		{
			return this._timelines;
		}

		  String get id
		{
			return this._config.id;
		}

		  num get scale
		{
			return this._scale;
		}

		  void set scale(num value)
		{
			this._scale = value;
		}

		  num get csf
		{
			return this._csf;
		}

		  void set csf(num value)
		{
			this._csf = value;
		}
	}
