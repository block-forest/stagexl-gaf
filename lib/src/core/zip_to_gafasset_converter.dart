 part of stagexl_gaf;




	/** Dispatched when convertation completed */
	// [Event(name="complete", type="flash.events.Event")]

	/** Dispatched when conversion failed for some reason */
	// [Event(name="error", type="flash.events.ErrorEvent")]

	/**
	 * The ZipToGAFAssetConverter simply converts loaded GAF file into <code>GAFTimeline</code> object that
	 * is used to create <code>GAFMovieClip</code> - animation display object ready to be used in starling display list.
	 * If GAF file is created as Bundle it converts as <code>GAFBundle</code>
	 *
	 * <p>Here is the simple rules to understand what is <code>GAFTimeline</code>, <code>GAFBundle</code> and <code>GAFMovieClip</code>:</p>
	 *
	 * <ul>
	 *    <li><code>GAFTimeline</code> - is like a library symbol in Flash IDE. When you load GAF asset file you can not use it directly.
	 *        All you need to do is convert it into <code>GAFTimeline</code> using ZipToGAFAssetConverter</li>
	 *    <li><code>GAFBundle</code> - is a storage of all <code>GAFTimeline's</code> from Bundle</li>
	 *    <li><code>GAFMovieClip</code> - is like an instance of Flash <code>MovieClip</code>.
	 *        You can create it from <code>GAFTimeline</code> and use in <code>Starling Display Map</code></li>
	 * </ul>
	 *
	 * @see com.catalystapps.gaf.data.GAFTimeline
	 * @see com.catalystapps.gaf.data.GAFBundle
	 * @see com.catalystapps.gaf.display.GAFMovieClip
	 *
	 */
	 class ZipToGAFAssetConverter extends EventDispatcher
	{
		//--------------------------------------------------------------------------
		//
		//  PUBLIC VARIABLES
		//
		//--------------------------------------------------------------------------

		/**
		 * In process of conversion doesn't create textures (doesn't load in GPU memory).
		 * Be sure to set up <code>Starling.handleLostContext = true</code> when using this action, otherwise Error will occur
		 */
		 static const String ACTION_DONT_LOAD_IN_GPU_MEMORY = "actionDontLoadInGPUMemory";

		/**
		 * In process of conversion create textures (load in GPU memory).
		 */
		 static const String ACTION_LOAD_ALL_IN_GPU_MEMORY = "actionLoadAllInGPUMemory";

		/**
		 * In process of conversion create textures (load in GPU memory) only atlases for default scale and csf
		 */
		 static const String ACTION_LOAD_IN_GPU_MEMORY_ONLY_DEFAULT = "actionLoadInGPUMemoryOnlyDefault";

		/**
		 * Action that should be applied to atlases in process of conversion. Possible values are action constants.
		 * By default loads in GPU memory only atlases for default scale and csf
		 */
		 static String actionWithAtlases = ACTION_LOAD_IN_GPU_MEMORY_ONLY_DEFAULT;

		/**
		 * Defines the values to use for specifying a texture format.
		 * If you prefer to use 16 bit-per-pixel textures just set
		 * <code>Context3DTextureFormat.BGR_PACKED</code> or <code>Context3DTextureFormat.BGRA_PACKED</code>.
		 * It will cut texture memory usage in half.
		 */
		 String textureFormat = Context3DTextureFormat.BGRA;

		/**
		 * Indicates keep or not to keep zip file content as ByteList for further usage.
		 * It's available through get <code>zip</code> property.
		 * By default converter won't keep zip content for further usage.
		 */
		 static bool keepZipInRAM = false;

		//--------------------------------------------------------------------------
		//
		//  PRIVATE VARIABLES
		//
		//--------------------------------------------------------------------------
		 String _id;

		 FZip _zip;
		 FZipLibrary _zipLoader;

		 int _currentConfigIndex;
		 num _configConvertTimeout;

		 List _gafAssetsIDs;
		 Map _gafAssetConfigs;
		 Map _gafAssetConfigSources;

		 Map _sounds;
		 Map _taGFXs;

		 GAFGFXData _gfxData;
		 GAFSoundData _soundData;

		 GAFBundle _gafBundle;

		 num _defaultScale;
		 num _defaultContentScaleFactor;

		 bool _parseConfigAsync;
		 bool _ignoreSounds;

		///////////////////////////////////

		 List _gafAssetsConfigURLs;
		 int _gafAssetsConfigIndex;

		 List _atlasSourceURLs;
		 int _atlasSourceIndex;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------

		/** Creates a new <code>ZipToGAFAssetConverter</code> instance.
		 * @param id The id of the converter.
		 * If it is not empty <code>ZipToGAFAssetConverter</code> sets the <code>name</code> of produced bundle equal to this id.
		 */
	 ZipToGAFAssetConverter([String id=null])
		{
			this._id = id;
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		/**
		 * Converts GAF file (*.zip) into <code>GAFTimeline</code> or <code>GAFBundle</code> depending on file content.
		 * Because conversion process is asynchronous use <code>Event.COMPLETE</code> listener to trigger successful conversion.
		 * Use <code>ErrorEvent.ERROR</code> listener to trigger any conversion fail.
		 *
		 * @param data *.zip file binary or File object represents a path to a *.gaf file or directory with *.gaf config files
		 * @param defaultScale Scale value for <code>GAFTimeline</code> that will be set by default
		 * @param defaultContentScaleFactor Content scale factor (value as csf) for <code>GAFTimeline</code> that will be set by default
		 */
		  void convert(dynamic data,[num defaultScale, num defaultContentScaleFactor])
		{
			if (!Starling.handleLostContext && ZipToGAFAssetConverter.actionWithAtlases == ZipToGAFAssetConverter.ACTION_DONT_LOAD_IN_GPU_MEMORY)
			{
				throw new StateError("Impossible parameters combination! Starling.handleLostContext = false and actionWithAtlases = ACTION_DONT_LOAD_ALL_IN_VIDEO_MEMORY One of the parameters must be changed!");
			}

			this.reset();

			this._defaultScale = defaultScale;
			this._defaultContentScaleFactor = defaultContentScaleFactor;

			if (this._id != null && this._id.length > 0)
			{
				this._gafBundle.name = this._id;
			}

			if (data is ByteList)
			{
				this._zip = new FZip();
				this._zip.addEventListener(FZipErrorEvent.PARSE_ERROR, this.onParseError);
				this._zip.loadBytes(data);

				this._zipLoader = new FZipLibrary();
				this._zipLoader.formatAsBitmapData(".png");
				this._zipLoader.addEventListener(Event.COMPLETE, this.onZipLoadedComplete);
				this._zipLoader.addEventListener(FZipErrorEvent.PARSE_ERROR, this.onParseError);
				this._zipLoader.addZip(this._zip);

				if (!ZipToGAFAssetConverter.keepZipInRAM)
				{
					(data as ByteList).clear();
				}
			}
			else if (data is List || getQualifiedTypeName(data) == "flash.filesystem::File")
			{
				this._gafAssetsConfigURLs = [];

				if (data is List)
				{
					for (dynamic file in data)
					{
						this.processFile(file);
					}
				}
				else
				{
					this.processFile(data);
				}

				if (this._gafAssetsConfigURLs.length != null)
				{
					this.loadConfig();
				}
				else
				{
					this.zipProcessError(ErrorConstants.GAF_NOT_FOUND, 5);
				}
			}
			else if (data is Map && data.containsKey("configs") && data.containsKey("atlases"))
			{
				this.parseObject(data);
			}
			else
			{
				this.zipProcessError(ErrorConstants.UNKNOWN_FORMAT, 6);
			}
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		  void reset()
		{
			this._zip = null;
			this._zipLoader = null;
			this._currentConfigIndex = 0;
			this._configConvertTimeout = 0;

			this._sounds = {};
			this._taGFXs = {};

			this._gfxData = new GAFGFXData();
			this._soundData = new GAFSoundData();
			this._gafBundle = new GAFBundle();
			this._gafBundle.soundData = this._soundData;

			this._gafAssetsIDs = [];
			this._gafAssetConfigs = {};
			this._gafAssetConfigSources = {};

			this._gafAssetsConfigURLs = [];
			this._gafAssetsConfigIndex = 0;

			this._atlasSourceURLs = [];
			this._atlasSourceIndex = 0;
		}

		  void parseObject(Map data)
		{
			this._taGFXs = {};

			for (Map configObj in data["configs"])
			{
				this._gafAssetsIDs.add(configObj["name"]);

				ByteList ba = configObj["config"] as ByteList;
				ba.position = 0;

				if (configObj["type"] == "gaf")
				{
					this._gafAssetConfigSources[configObj["name"]] = ba;
				}
				else
				{
					this.zipProcessError(ErrorConstants.UNSUPPORTED_JSON);
				}
			}

			for (Map atlasObj in data["atlases"])
			{
				TAGFXBase taGFX = new TAGFXSourceBitmapData(atlasObj["bitmapData"], this.textureFormat);
				this._taGFXs[atlasObj["name"]] = taGFX;
			}

			///////////////////////////////////

			this.convertConfig();
		}

		  void processFile(dynamic data)
		{
			if (getQualifiedTypeName(data) == "flash.filesystem::File")
			{
				if (!data["exists"] || data["isHidden"])
				{
					this.zipProcessError(ErrorConstants.FILE_NOT_FOUND + data["url"] + "'", 4);
				}
				else
				{
					String url;

					if (data["isDirectory"])
					{
						List files = data["getDirectoryListing"]();

						for (dynamic file in files)
						{
							if (file["exists"] && !file["isHidden"] && !file["isDirectory"])
							{
								url = file["url"];

								if (isGAFConfig(url))
								{
									this._gafAssetsConfigURLs.add(url);
								}
								else if (isJSONConfig(url))
								{
									this.zipProcessError(ErrorConstants.UNSUPPORTED_JSON);
									return;
								}
							}
						}
					}
					else
					{
						url = data["url"];

						if (isGAFConfig(url))
						{
							this._gafAssetsConfigURLs.add(url);
						}
						else if (isJSONConfig(url))
						{
							this.zipProcessError(ErrorConstants.UNSUPPORTED_JSON);
						}
					}
				}
			}
		}

		  void findAllAtlasURLs()
		{
			this._atlasSourceURLs = [];

			String url;
			List<GAFTimelineConfig> gafTimelineConfigs;

			for (String id in this._gafAssetConfigs)
			{
				gafTimelineConfigs = this._gafAssetConfigs[id].timelines;

				for (GAFTimelineConfig config in gafTimelineConfigs)
				{
					String folderURL = getFolderURL(id);

					for (CTextureAtlasScale scale in config.allTextureAtlases)
					{
						if (isNaN(this._defaultScale) || MathUtility.equals(scale.scale, this._defaultScale))
						{
							for (CTextureAtlasCSF csf in scale.allContentScaleFactors)
							{
								if (isNaN(this._defaultContentScaleFactor) || MathUtility.equals(csf.csf, this._defaultContentScaleFactor))
								{
									for (CTextureAtlasSource source in csf.sources)
									{
										url = folderURL + source.source;

										if (source.source != "no_atlas"
												&& this._atlasSourceURLs.indexOf(url) == -1)
										{
											this._atlasSourceURLs.add(url);
										}
									}
								}
							}
						}
					}
				}
			}

			if (this._atlasSourceURLs.length > 0)
			{
				this.loadNextAtlas();
			}
			else
			{
				this.createGAFTimelines();
			}
		}

		  void loadNextAtlas()
		{
			String url = this._atlasSourceURLs[this._atlasSourceIndex];
			String fileName = url.substring(url.lastIndexOf("/") + 1);

			Point textureSize;
			TAGFXBase taGFX;
			Type FileType = getDefinitionByName("flash.filesystem::File") as Type;
			dynamic file = new FileType(url);
			if (file["exists"])
			{
				textureSize = FileUtils.getPNGSize(file);
				taGFX = new TAGFXSourcePNGURL(url, textureSize, this.textureFormat);

				this._taGFXs[fileName] = taGFX;
			}
			else
			{
				url = url.substring(0, url.lastIndexOf(".png")) + ".atf";
				file = new FileType(url);
				if (file["exists"])
				{
					GAFATFData atfData = FileUtils.getATFData(file);
					taGFX = new TAGFXSourceATFURL(url, atfData);

					this._taGFXs[fileName] = taGFX;
				}
				else
				{
					this.zipProcessError(ErrorConstants.FILE_NOT_FOUND + url + "'", 4);
				}
			}

			this._atlasSourceIndex++;

			if (this._atlasSourceIndex >= this._atlasSourceURLs.length)
			{
				this.createGAFTimelines();
			}
			else
			{
				this.loadNextAtlas();
			}
		}

		  void loadConfig()
		{
			String url = this._gafAssetsConfigURLs[this._gafAssetsConfigIndex];
			URLLoader gafAssetsConfigURLLoader = new URLLoader();
			gafAssetsConfigURLLoader.dataFormat = URLLoaderDataFormat.BINARY;
			gafAssetsConfigURLLoader.addEventListener(IOErrorEvent.IO_ERROR, this.onConfigIOError);
			gafAssetsConfigURLLoader.addEventListener(Event.COMPLETE, this.onConfigLoadComplete);
			gafAssetsConfigURLLoader.load(new URLRequest(url));
		}

		  void finalizeParsing()
		{
			this._taGFXs = null;
			this._sounds = null;

			if (this._zip && !ZipToGAFAssetConverter.keepZipInRAM)
			{
				FZipFile file;
				int count = this._zip.getFileCount();
				for (int i = 0; i < count; i++)
				{
					file = this._zip.getFileAt(i);
					if (file.filename.toLowerCase().indexOf(".atf") == -1
							&& file.filename.toLowerCase().indexOf(".png") == -1)
					{
						file.content.clear();
					}
				}
				this._zip.close();
				this._zip = null;
			}

			this.dispatchEvent(new Event(Event.COMPLETE));
		}

		 static  String getFolderURL(String url)
		{
			String cutURL = url.split("?")[0];

			int lastIndex = cutURL.lastIndexOf("/");

			return cutURL.slice(0, lastIndex + 1);
		}

		 static  bool isJSONConfig(String url)
		{
			return (url.split("?")[0].split(".").pop().toLowerCase() == "json");
		}

		 static  bool isGAFConfig(String url)
		{
			return (url.split("?")[0].split(".").pop().toLowerCase() == "gaf");
		}

		  void parseZip()
		{
			int length = this._zip.getFileCount();

			FZipFile zipFile;

			String fileName;
			TAGFXBase taGFX;

			this._taGFXs = {};

			this._gafAssetConfigSources = {};
			this._gafAssetsIDs = [];

			for (int i = 0; i < length; i++)
			{
				zipFile = this._zip.getFileAt(i);
				fileName = zipFile.filename;

				switch (fileName.substr(fileName.toLowerCase().lastIndexOf(".")))
				{
					case ".png":
						fileName = fileName.substring(fileName.lastIndexOf("/") + 1);
						ByteList pngBA = zipFile.content;
						Point pngSize = FileUtils.getPNGBASize(pngBA);
						taGFX = new TAGFXSourcePNGBA(pngBA, pngSize, this.textureFormat);
						this._taGFXs[fileName] = taGFX;
						break;
					case ".atf":
						fileName = fileName.substring(fileName.lastIndexOf("/") + 1, fileName.toLowerCase().lastIndexOf(".atf")) + ".png";
						taGFX = new TAGFXSourceATFBA(zipFile.content);
						this._taGFXs[fileName] = taGFX;
						break;
					case ".gaf":
						this._gafAssetsIDs.add(fileName);
						this._gafAssetConfigSources[fileName] = zipFile.content;
						break;
					case ".json":
						this.zipProcessError(ErrorConstants.UNSUPPORTED_JSON);
						break;
					case ".mp3":
					case ".wav":
						if (!this._ignoreSounds)
						{
							this._sounds[fileName] = zipFile.content;
						}
						break;
				}
			}

			this.convertConfig();
		}

		  void convertConfig()
		{
			clearTimeout(this._configConvertTimeout);
			this._configConvertTimeout = NaN;

			String configID = this._gafAssetsIDs[this._currentConfigIndex];
			Map configSource = this._gafAssetConfigSources[configID];
			String gafAssetID = this.getAssetId(this._gafAssetsIDs[this._currentConfigIndex]);

			if (configSource is ByteList)
			{
				BinGAFAssetConfigConverter converter = new BinGAFAssetConfigConverter(gafAssetID, configSource as ByteList);
				converter.defaultScale = this._defaultScale;
				converter.defaultCSF = this._defaultContentScaleFactor;
				converter.ignoreSounds = this._ignoreSounds;
				converter.addEventListener(Event.COMPLETE, onConverted);
				converter.addEventListener(ErrorEvent.ERROR, onConvertError);
				converter.convert(this._parseConfigAsync);
			}
			else
			{
				throw new StateError("");
			}
		}

		  void createGAFTimelines([Event event=null])
		{
			if( event != null || event == true)
			{
				Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, createGAFTimelines);
			}
			if (!Starling.current.contextValid)
			{
				Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE, createGAFTimelines);
			}

			List<GAFTimelineConfig> gafTimelineConfigs;
			String gafAssetConfigID;
			GAFAssetConfig gafAssetConfig;
			GAFAsset gafAsset;
			int i;

			if (!Starling.handleLostContext)
			{
				for (TAGFXBase taGFX in this._taGFXs)
				{
					taGFX.clearSourceAfterTextureCreated = true;
				}
			}

			for (i = 0; i < this._gafAssetsIDs.length; i++)
			{
				gafAssetConfigID = this._gafAssetsIDs[i];
				gafAssetConfig = this._gafAssetConfigs[gafAssetConfigID];
				gafTimelineConfigs = gafAssetConfig.timelines;

				gafAsset = new GAFAsset(gafAssetConfig);
				for (GAFTimelineConfig config in gafTimelineConfigs)
				{
					gafAsset.addGAFTimeline(this.createTimeline(config, gafAsset));
				}

				this._gafBundle.addGAFAsset(gafAsset);
			}

			if (gafAsset == null || gafAsset.timelines.length == 0)
			{
				this.zipProcessError(ErrorConstants.TIMELINES_NOT_FOUND);
				return;
			}

			if (this._gafAssetsIDs.length == 1)
			{

				this._gafBundle.name ??= gafAssetConfig.id;

			}

			if (this._soundData.hasSoundsToLoad && !this._ignoreSounds)
			{
				this._soundData.loadSounds(this.finalizeParsing, this.onSoundLoadIOError);
			}
			else
			{
				this.finalizeParsing();
			}
		}

		  GAFTimeline createTimeline(GAFTimelineConfig config,GAFAsset asset)
		{
			for (CTextureAtlasScale cScale in config.allTextureAtlases)
			{
				if ((this._defaultScale == null) || MathUtility.equals(this._defaultScale, cScale.scale))
				{
					for(CTextureAtlasCSF cCSF in cScale.allContentScaleFactors)
					{
						if ((this._defaultContentScaleFactor  == null) || MathUtility.equals(this._defaultContentScaleFactor, cCSF.csf))
						{
							for (CTextureAtlasSource taSource in cCSF.sources)
							{
								if (taSource.source == "no_atlas")
								{
									continue;
								}
								if (this._taGFXs[taSource.source])
								{
									TAGFXBase taGFX = this._taGFXs[taSource.source];
									taGFX.textureScale = cCSF.csf;
									this._gfxData.addTAGFX(cScale.scale, cCSF.csf, taSource.id, taGFX);
								}
								else
								{
									this.zipProcessError(ErrorConstants.ATLAS_NOT_FOUND + taSource.source + "' in zip", 3);
								}
							}
						}
					}
				}
			}

			GAFTimeline timeline = new GAFTimeline(config);
			timeline.gafgfxData = this._gfxData;
			timeline.gafSoundData = this._soundData;
			timeline.gafAsset = asset;

			switch (ZipToGAFAssetConverter.actionWithAtlases)
			{
				case ZipToGAFAssetConverter.ACTION_LOAD_ALL_IN_GPU_MEMORY:
					timeline.loadInVideoMemory(GAFTimeline.CONTENT_ALL);
					break;

				case ZipToGAFAssetConverter.ACTION_LOAD_IN_GPU_MEMORY_ONLY_DEFAULT:
					timeline.loadInVideoMemory(GAFTimeline.CONTENT_DEFAULT);
					break;
			}

			return timeline;
		}

		  String getAssetId(String configName)
		{
			int startIndex = configName.lastIndexOf("/");

			if (startIndex < 0)
			{
				startIndex = 0;
			}
			else
			{
				startIndex++;
			}

			int endIndex = configName.lastIndexOf(".");

			if (endIndex < 0)
			{
				endIndex = 0x7fffffff;
			}

			return configName.substring(startIndex, endIndex);
		}

		  void zipProcessError(String text,[int id=0])
		{
			this.onConvertError(new ErrorEvent(ErrorEvent.ERROR, false, false, text, id));
		}

		  void removeLoaderListeners(EventDispatcher target,Function onComplete,Function onError)
		{
			target.removeEventListener(Event.COMPLETE, onComplete);
			target.removeEventListener(IOErrorEvent.IO_ERROR, onError);
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

		  void onZipLoadedComplete(Event event)
		{
			if (this._zip.getFileCount())
			{
				this.parseZip();
			}
			else
			{
				this.zipProcessError(ErrorConstants.EMPTY_ZIP, 2);
			}
		}

		  void onParseError(FZipErrorEvent event)
		{
			this.zipProcessError(ErrorConstants.ERROR_PARSING, 1);
		}

		  void onConvertError(ErrorEvent event)
		{
			if (this.hasEventListener(ErrorEvent.ERROR))
			{
				this.dispatchEvent(event);
			}
			else
			{
				throw new StateError(event.text);
			}
		}

		  void onConverted(Event event)
		{
			//// use namespace gaf_internal;

			String configID = this._gafAssetsIDs[this._currentConfigIndex];
			String folderURL = getFolderURL(configID);
			BinGAFAssetConfigConverter converter = event.target as BinGAFAssetConfigConverter;
			converter.removeEventListener(Event.COMPLETE, onConverted);
			converter.removeEventListener(ErrorEvent.ERROR, onConvertError);

			this._gafAssetConfigs[configID] = converter.config;
			List<CSound> sounds = converter.config.sounds;
			if (sounds && !this._ignoreSounds)
			{
				for (int i = 0; i < sounds.length; i++)
				{
					sounds[i].source = folderURL + sounds[i].source;
					this._soundData.addSound(sounds[i], converter.config.id, this._sounds[sounds[i].source]);
				}
			}

			this._currentConfigIndex++;

			if (this._currentConfigIndex >= this._gafAssetsIDs.length)
			{
				if (this._gafAssetsConfigURLs && _gafAssetsConfigURLs.length)
				{
					this.findAllAtlasURLs();
				}
				else
				{
					this.createGAFTimelines();
				}
			}
			else
			{
				this._configConvertTimeout = setTimeout(this.convertConfig, 40);
			}
		}

		  void onConfigLoadComplete(Event event)
		{
			URLLoader loader = event.target as URLLoader;
			String url = this._gafAssetsConfigURLs[this._gafAssetsConfigIndex];

			this.removeLoaderListeners(loader, onConfigLoadComplete, onConfigIOError);

			this._gafAssetsIDs.add(url);

			this._gafAssetConfigSources[url] = loader.data;

			this._gafAssetsConfigIndex++;

			if (this._gafAssetsConfigIndex >= this._gafAssetsConfigURLs.length)
			{
				this.convertConfig();
			}
			else
			{
				this.loadConfig();
			}
		}

		  void onConfigIOError(IOErrorEvent event)
		{
			String url = this._gafAssetsConfigURLs[this._gafAssetsConfigIndex];
			this.removeLoaderListeners(event.target as URLLoader, onConfigLoadComplete, onConfigIOError);
			this.zipProcessError(ErrorConstants.ERROR_LOADING + url, 5);
		}

		  void onSoundLoadIOError(IOErrorEvent event)
		{
			Sound sound = event.target as Sound;
			this.removeLoaderListeners(event.target as URLLoader, onSoundLoadIOError, onSoundLoadIOError);
			this.zipProcessError(ErrorConstants.ERROR_LOADING + sound.url, 6);
		}

		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------

		/**
		 * Return converted <code>GAFBundle</code>. If GAF asset file created as single animation - returns null.
		 */
		  GAFBundle get gafBundle
		{
			return this._gafBundle;
		}

		/**
		 * Returns the first <code>GAFTimeline</code> in a <code>GAFBundle</code>.
		 */
		// [Deprecated(replacement="com.catalystapps.gaf.data.GAFBundle.getGAFTimeline()", since="5.0")]
		  GAFTimeline get gafTimeline
		{
			if (this._gafBundle && this._gafBundle.gafAssets.length > 0)
			{
				for (GAFAsset asset in this._gafBundle.gafAssets)
				{
					if (asset.timelines.length > 0)
					{
						return asset.timelines[0];
					}
				}
			}
			return null;
		}

		/**
		 * Return loaded zip file as <code>FZip</code> object
		 */
		  FZip get zip
		{
			return this._zip;
		}

		/**
		 * Return zipLoader object
		 */
		  FZipLibrary get zipLoader
		{
			return this._zipLoader;
		}

		/**
		 * The id of the converter.
		 * If it is not empty <code>ZipToGAFAssetConverter</code> sets the <code>name</code> of produced bundle equal to this id.
		 */
		  String get id
		{
			return this._id;
		}

		  void set id(String value)
		{
			this._id = value;
		}

		  bool get parseConfigAsync
		{
			return this._parseConfigAsync;
		}

		/**
		 * Indicates whether to convert *.gaf config file asynchronously.
		 * If <code>true</code> - conversion is divided by chunk of 20 ms (may be up to
		 * 2 times slower than synchronous conversion, but conversion won't freeze the abstract class).
		 * If <code>false</code> - conversion goes within one stack (up to
		 * 2 times faster than async conversion, but conversion freezes the abstract class).
		 */
		  void set parseConfigAsync(bool parseConfigAsync)
		{
			this._parseConfigAsync = parseConfigAsync;
		}

		/**
		 * Prevents loading of sounds
		 */
		  void set ignoreSounds(bool ignoreSounds)
		{
			this._ignoreSounds = ignoreSounds;
		}
	}
