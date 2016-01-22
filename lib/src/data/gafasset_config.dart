/**
 * Created by Nazar on 19.05.2014.
 */
 part of stagexl_gaf;

	/**
	 * @
	 */
	 class GAFAssetConfig
	{
		 static final int MAX_VERSION = 5;

		 String _id;
		 int _compression;
		 int _versionMajor;
		 int _versionMinor;
		 int _fileLength;
		 List<num> _scaleValues;
		 List<num> _csfValues;
		 num _defaultScale;
		 num _defaultContentScaleFactor;

		 CStage _stageConfig;

		 List<GAFTimelineConfig> _timelines;
		 List<CTextureAtlasScale> _allTextureAtlases;
		 List<CSound> _sounds;
	 GAFAssetConfig(String id)
		{
			this._id = id;
			this._scaleValues = new List<num>();
			this._csfValues = new List<num>();

			this._timelines = new List<GAFTimelineConfig>();
			this._allTextureAtlases = new List<CTextureAtlasScale>();
		}

		  void addSound(CSound soundData)
		{
			this._sounds ??= new List<CSound>();
			this._sounds.add(soundData);
		}

		  void dispose()
		{
			this._allTextureAtlases = null;
			this._stageConfig = null;
			this._scaleValues = null;
			this._csfValues = null;
			this._timelines = null;
			this._sounds = null;
		}

		  int get compression
		{
			return this._compression;
		}

		  void set compression(int value)
		{
			this._compression = value;
		}

		  int get versionMajor
		{
			return this._versionMajor;
		}

		  void set versionMajor(int value)
		{
			this._versionMajor = value;
		}

		  int get versionMinor
		{
			return this._versionMinor;
		}

		  void set versionMinor(int value)
		{
			this._versionMinor = value;
		}

		  int get fileLength
		{
			return this._fileLength;
		}

		  void set fileLength(int value)
		{
			this._fileLength = value;
		}

		  List<num> get scaleValues
		{
			return this._scaleValues;
		}

		  List<num> get csfValues
		{
			return this._csfValues;
		}

		  num get defaultScale
		{
			return this._defaultScale;
		}

		  void set defaultScale(num value)
		{
			this._defaultScale = value;
		}

		  num get defaultContentScaleFactor
		{
			return this._defaultContentScaleFactor;
		}

		  void set defaultContentScaleFactor(num value)
		{
			this._defaultContentScaleFactor = value;
		}

		  List<GAFTimelineConfig> get timelines
		{
			return this._timelines;
		}

		  List<CTextureAtlasScale> get allTextureAtlases
		{
			return this._allTextureAtlases;
		}

		  CStage get stageConfig
		{
			return this._stageConfig;
		}

		  void set stageConfig(CStage value)
		{
			this._stageConfig = value;
		}

		  String get id
		{
			return this._id;
		}

		  List<CSound> get sounds
		{
			return this._sounds;
		}
	}
