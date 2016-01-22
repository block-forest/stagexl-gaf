 part of stagexl_gaf;


	/**
	 * @
	 */
	 class GAFTimelineConfig
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
		 String _version;
		 CStage _stageConfig;

		 String _id;
		 String _assetID;

		 List<CTextureAtlasScale> _allTextureAtlases;
		 CTextureAtlasScale _textureAtlas;

		 CAnimationFrames _animationConfigFrames;
		 CAnimationObjects _animationObjects;
		 CAnimationSequences _animationSequences;
		 CTextFieldObjects _textFields;

		 Map _namedParts;
		 String _linkage;

		 List<GAFDebugInformation> _debugRegions;

		 List<String> _warnings;
		 int _framesCount;
		 Rectangle _bounds;
		 Point _pivot;
		 Map _sounds;
		 bool _disposed;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 GAFTimelineConfig(String version)
		{
			this._version = version;

			this._animationConfigFrames = new CAnimationFrames();
			this._animationObjects = new CAnimationObjects();
			this._animationSequences = new CAnimationSequences();
			this._textFields = new CTextFieldObjects();
			this._sounds = new Map();
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		  void dispose()
		{
			for (CTextureAtlasScale cTextureAtlasScale in this._allTextureAtlases)
			{
				cTextureAtlasScale.dispose();
			}
			this._allTextureAtlases = null;

			this._animationConfigFrames = null;
			this._animationSequences = null;
			this._animationObjects = null;
			this._textureAtlas = null;
			this._textFields = null;
			this._namedParts = null;
			this._warnings = null;
			this._bounds = null;
			this._sounds = null;
			this._pivot = null;
			
			this._disposed = true;
		}

		  CTextureAtlasScale getTextureAtlasForScale(num scale)
		{
			for (CTextureAtlasScale cTextureAtlas in this._allTextureAtlases)
			{
				if (MathUtility.equals(cTextureAtlas.scale, scale))
				{
					return cTextureAtlas;
				}
			}

			return null;
		}

		  void addSound(Object data,int frame)
		{
			this._sounds[frame] = new CFrameSound(data);
		}

		  CFrameSound getSound(int frame)
		{
			return this._sounds[frame];
		}

		  void addWarning(String text)
		{
			if( text == null || text == false)
			{
				return;
			}

			if (!this._warnings)
			{
				this._warnings = new List<String>();
			}

			if (this._warnings.indexOf(text) == -1)
			{
				print(text);
				this._warnings.add(text);
			}
		}

		  String getNamedPartID(String name)
		{
			for (String id in this._namedParts)
			{
				if (this._namedParts[id] == name)
				{
					return id;
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

		  CTextureAtlasScale get textureAtlas
		{
			return this._textureAtlas;
		}

		  void set textureAtlas(CTextureAtlasScale textureAtlas)
		{
			this._textureAtlas = textureAtlas;
		}

		  CAnimationObjects get animationObjects
		{
			return this._animationObjects;
		}

		  void set animationObjects(CAnimationObjects animationObjects)
		{
			this._animationObjects = animationObjects;
		}

		  CAnimationFrames get animationConfigFrames
		{
			return this._animationConfigFrames;
		}

		  void set animationConfigFrames(CAnimationFrames animationConfigFrames)
		{
			this._animationConfigFrames = animationConfigFrames;
		}

		  CAnimationSequences get animationSequences
		{
			return this._animationSequences;
		}

		  void set animationSequences(CAnimationSequences animationSequences)
		{
			this._animationSequences = animationSequences;
		}

		  CTextFieldObjects get textFields
		{
			return this._textFields;
		}

		  void set textFields(CTextFieldObjects textFields)
		{
			this._textFields = textFields;
		}

		  List<CTextureAtlasScale> get allTextureAtlases
		{
			return this._allTextureAtlases;
		}

		  void set allTextureAtlases(List<CTextureAtlasScale> allTextureAtlases)
		{
			this._allTextureAtlases = allTextureAtlases;
		}

		  String get version
		{
			return this._version;
		}

		  List<GAFDebugInformation> get debugRegions
		{
			return this._debugRegions;
		}

		  void set debugRegions(List<GAFDebugInformation> debugRegions)
		{
			this._debugRegions = debugRegions;
		}

		  List<String> get warnings
		{
			return this._warnings;
		}

		  String get id
		{
			return this._id;
		}

		  void set id(String value)
		{
			this._id = value;
		}

		  String get assetID
		{
			return this._assetID;
		}

		  void set assetID(String value)
		{
			this._assetID = value;
		}

		  Map get namedParts
		{
			return this._namedParts;
		}

		  void set namedParts(Object value)
		{
			this._namedParts = value;
		}

		  String get linkage
		{
			return this._linkage;
		}

		  void set linkage(String value)
		{
			this._linkage = value;
		}

		  CStage get stageConfig
		{
			return this._stageConfig;
		}

		  void set stageConfig(CStage stageConfig)
		{
			this._stageConfig = stageConfig;
		}

		  int get framesCount
		{
			return this._framesCount;
		}

		  void set framesCount(int value)
		{
			this._framesCount = value;
		}

		  Rectangle get bounds
		{
			return this._bounds;
		}

		  void set bounds(Rectangle value)
		{
			this._bounds = value;
		}

		  Point get pivot
		{
			return this._pivot;
		}

		  void set pivot(Point value)
		{
			this._pivot = value;
		}

		  bool get disposed {
			return _disposed;
		}
	}
