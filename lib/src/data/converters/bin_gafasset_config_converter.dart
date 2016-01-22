 part of stagexl_gaf;



	// use namespace gaf_internal;

	/**
	 * @
	 */
	 class BinGAFAssetConfigConverter extends EventDispatcher
	{
		 static const int SIGNATURE_GAF = 0x00474146;
		 static const int SIGNATURE_GAC = 0x00474143;
		 static const int HEADER_LENGTH = 36;

		//tags
		 static const int TAG_END = 0;
		 static const int TAG_DEFINE_ATLAS = 1;
		 static const int TAG_DEFINE_ANIMATION_MASKS = 2;
		 static const int TAG_DEFINE_ANIMATION_OBJECTS = 3;
		 static const int TAG_DEFINE_ANIMATION_FRAMES = 4;
		 static const int TAG_DEFINE_NAMED_PARTS = 5;
		 static const int TAG_DEFINE_SEQUENCES = 6;
		 static const int TAG_DEFINE_TEXT_FIELDS = 7; // v4.0
		 static const int TAG_DEFINE_ATLAS2 = 8; // v4.0
		 static const int TAG_DEFINE_STAGE = 9;
		 static const int TAG_DEFINE_ANIMATION_OBJECTS2 = 10; // v4.0
		 static const int TAG_DEFINE_ANIMATION_MASKS2 = 11; // v4.0
		 static const int TAG_DEFINE_ANIMATION_FRAMES2 = 12; // v4.0
		 static const int TAG_DEFINE_TIMELINE = 13; // v4.0
		 static const int TAG_DEFINE_SOUNDS = 14; // v5.0
		 static const int TAG_DEFINE_ATLAS3 = 15; // v5.0

		//filters
		 static const int FILTER_DROP_SHADOW = 0;
		 static const int FILTER_BLUR = 1;
		 static const int FILTER_GLOW = 2;
		 static const int FILTER_COLOR_MATRIX = 6;

		 static final Rectangle sHelperRectangle = new Rectangle(0, 0, 0, 0);
		 static final Matrix sHelperMatrix = new Matrix.fromIdentity();

		 String _assetID;
		 ByteList _bytes;
		 num _defaultScale;
		 num _defaultContentScaleFactor;
		 GAFAssetConfig _config;
		 Map _textureElementSizes; // Point by texture element id

		 int _time;
		 bool _isTimeline;
		 GAFTimelineConfig _currentTimeline;
		 bool _async;
		 bool _ignoreSounds;


		// --------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
	 BinGAFAssetConfigConverter(String assetID,ByteList bytes)
		{
			this._bytes = bytes;
			this._assetID = assetID;
			this._textureElementSizes = {};
		}

		  void convert([bool async=false])
		{
			this._async = async;
			this._time = /*getTimer()*/ (stage.juggler.elapsedTime*1000);
			if( async != null || async == true)
			{
				Starling.juggler.delayCall(this.parseStart, 0.001);
			}
			else
			{
				this.parseStart();
			}
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		  void parseStart()
		{
			this._bytes.endian = Endian.LITTLE_ENDIAN;

			this._config = new GAFAssetConfig(this._assetID);
			this._config.compression = this._bytes.readInt();
			this._config.versionMajor = this._bytes.readByte();
			this._config.versionMinor = this._bytes.readByte();
			this._config.fileLength = this._bytes.readUnsignedInt();

			/*if (this._config.versionMajor > GAFAssetConfig.MAX_VERSION)
			{
				this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, WarningConstants.UNSUPPORTED_FILE +
				"Library version: " + GAFAssetConfig.MAX_VERSION + ", file version: " + this._config.versionMajor));
				return;
			}*/

			switch (this._config.compression)
			{
				case SIGNATURE_GAC:
					this.decompressConfig();
					break;
			}

			if (this._config.versionMajor < 4)
			{
				this._currentTimeline = new GAFTimelineConfig( "${this._config.versionMajor}.${this._config.versionMinor}");
				this._currentTimeline.id = "0";
				this._currentTimeline.assetID = this._assetID;
				this._currentTimeline.framesCount = this._bytes.readShort();
				this._currentTimeline.bounds = new Rectangle(this._bytes.readFloat(), this._bytes.readFloat(), this._bytes.readFloat(), this._bytes.readFloat());
				this._currentTimeline.pivot = new Point(this._bytes.readFloat(), this._bytes.readFloat());
				this._config.timelines.add(this._currentTimeline);
			}
			else
			{
				int i;
				int l = this._bytes.readUnsignedInt();
				for (i = 0; i < l; i++)
				{
					this._config.scaleValues.add(this._bytes.readFloat());
				}

				l = this._bytes.readUnsignedInt();
				for (i = 0; i < l; i++)
				{
					this._config.csfValues.add(this._bytes.readFloat());
				}
			}

			this.readNextTag();
		}

		  void decompressConfig()
		{
			ByteList uncompressedBA = new ByteList();
			uncompressedBA.endian = Endian.LITTLE_ENDIAN;

			this._bytes.readBytes(uncompressedBA);
			this._bytes.clear();

			uncompressedBA.uncompress(CompressionAlgorithm.ZLIB);

			this._bytes = uncompressedBA;
		}

		  void checkForMissedRegions(GAFTimelineConfig timelineConfig)
		{
			if (timelineConfig.textureAtlas != null && timelineConfig.textureAtlas.contentScaleFactor.elements  != null)
			{
				for (CAnimationObject ao in timelineConfig.animationObjects.animationObjectsMap)
				{
					if (ao.type == CAnimationObject.TYPE_TEXTURE
							&& timelineConfig.textureAtlas.contentScaleFactor.elements.getElement(ao.regionID) == null)
					{
						timelineConfig.addWarning(WarningConstants.REGION_NOT_FOUND);
						break;
					}
				}
			}
		}

		  void readNextTag()
		{
			int tagID = this._bytes.readShort();
			int tagLength = this._bytes.readUnsignedInt();

			switch (tagID)
			{
				case BinGAFAssetConfigConverter.TAG_DEFINE_STAGE:
					readStageConfig(this._bytes, this._config);
					break;
				case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS:
				case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2:
				case BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3:
					readTextureAtlasConfig(tagID);
					break;
				case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS:
				case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS2:
					readAnimationMasks(tagID, this._bytes, this._currentTimeline);
					break;
				case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS:
				case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS2:
					readAnimationObjects(tagID, this._bytes, this._currentTimeline);
					break;
				case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES:
				case BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES2:
					readAnimationFrames(tagID);
					return;
				case BinGAFAssetConfigConverter.TAG_DEFINE_NAMED_PARTS:
					readNamedParts(this._bytes, this._currentTimeline);
					break;
				case BinGAFAssetConfigConverter.TAG_DEFINE_SEQUENCES:
					readAnimationSequences(this._bytes, this._currentTimeline);
					break;
				case BinGAFAssetConfigConverter.TAG_DEFINE_TEXT_FIELDS:
					readTextFields(this._bytes, this._currentTimeline);
					break;
				case BinGAFAssetConfigConverter.TAG_DEFINE_SOUNDS:
					if (!this._ignoreSounds)
					{
						readSounds(this._bytes, this._config);
					}
					else
					{
						this._bytes.position += tagLength;
					}
					break;
				case BinGAFAssetConfigConverter.TAG_DEFINE_TIMELINE:
					this._currentTimeline = readTimeline();
					break;
				case BinGAFAssetConfigConverter.TAG_END:
					if (this._isTimeline)
					{
						this._isTimeline = false;
					}
					else
					{
						this._bytes.position = this._bytes.length;
						this.endParsing();
						return;
					}
					break;
				default:
					print(WarningConstants.UNSUPPORTED_TAG);
					this._bytes.position += tagLength;
					break;
			}

			delayedReadNextTag();
		}

		  void delayedReadNextTag()
		{
			if (this._async)
			{
				int timer = /*getTimer()*/ (stage.juggler.elapsedTime*1000);
				if (timer - this._time >= 20)
				{
					this._time = timer;
					Starling.juggler.delayCall(this.readNextTag, 0.001);
				}
				else
				{
					this.readNextTag();
				}
			}
			else
			{
				this.readNextTag();
			}
		}

		  GAFTimelineConfig readTimeline()
		{
			GAFTimelineConfig timelineConfig = new GAFTimelineConfig("${this._config.versionMajor}.${this._config.versionMinor}");
			timelineConfig.id = this._bytes.readUnsignedInt().toString();
			timelineConfig.assetID = this._config.id;
			timelineConfig.framesCount = this._bytes.readUnsignedInt();
			timelineConfig.bounds = new Rectangle(this._bytes.readFloat(), this._bytes.readFloat(), this._bytes.readFloat(), this._bytes.readFloat());
			timelineConfig.pivot = new Point(this._bytes.readFloat(), this._bytes.readFloat());

			bool hasLinkage = this._bytes.readbool();
			if( hasLinkage != null || hasLinkage == true)
			{
				timelineConfig.linkage = this._bytes.readUTF();
			}

			this._config.timelines.add(timelineConfig);

			this._isTimeline = true;

			return timelineConfig;
		}

		  void readMaskMaxSizes()
		{
			for (GAFTimelineConfig timeline in this._config.timelines)
			{
				for (CAnimationFrame frame in timeline.animationConfigFrames.frames)
				{
					for (CAnimationFrameInstance frameInstance in frame.instances)
					{
						CAnimationObject animationObject = timeline.animationObjects.getAnimationObject(frameInstance.id);
						if (animationObject.mask)
						{
							if (animationObject.maxSize == null)
							{
								animationObject.maxSize = new Point(0,0);
							}

							Point maxSize = animationObject.maxSize;

							if (animationObject.type == CAnimationObject.TYPE_TEXTURE)
							{
								sHelperRectangle.copyFrom(this._textureElementSizes[animationObject.regionID]);
							}
							else if (animationObject.type == CAnimationObject.TYPE_TIMELINE)
							{
								GAFTimelineConfig maskTimeline;
								for (maskTimeline in this._config.timelines)
								{
									if (maskTimeline.id == frameInstance.id)
									{
										break;
									}
								}
								sHelperRectangle.copyFrom(maskTimeline.bounds);
							}
							else if (animationObject.type == CAnimationObject.TYPE_TEXTFIELD)
							{
								CTextFieldObject textField = timeline.textFields.textFieldObjectsMap[animationObject.regionID];
								sHelperRectangle.setTo(
										-textField.pivotPoint.x,
										-textField.pivotPoint.y,
										textField.width,
										textField.height);
							}
							RectangleUtil.getBounds(sHelperRectangle, frameInstance.matrix, sHelperRectangle);
							maxSize.setTo(
									/*Math.*/max(maxSize.x, (sHelperRectangle.width)).abs(),
									/*Math.*/max(maxSize.y, (sHelperRectangle.height)).abs());
						}
					}
				}
			}
		}

		  void endParsing()
		{
			this._bytes.clear();
			this._bytes = null;

			this.readMaskMaxSizes();

			int itemIndex;
			if (isNaN(this._config.defaultScale))
			{
				if (!isNaN(this._defaultScale))
				{
					itemIndex = MathUtility.getItemIndex(this._config.scaleValues, this._defaultScale);
					if (itemIndex < 0)
					{
						parseError("${this._defaultScale} + ${ErrorConstants.SCALE_NOT_FOUND}");
						return;
					}
				}
				this._config.defaultScale = this._config.scaleValues[itemIndex];
			}

			if (isNaN(this._config.defaultContentScaleFactor))
			{
				itemIndex = 0;
				if (!isNaN(this._defaultContentScaleFactor))
				{
					itemIndex = MathUtility.getItemIndex(this._config.csfValues, this._defaultContentScaleFactor);
					if (itemIndex < 0)
					{
						parseError("${this._defaultContentScaleFactor} + ${ErrorConstants.CSF_NOT_FOUND}");
						return;
					}
				}
				this._config.defaultContentScaleFactor = this._config.csfValues[itemIndex];
			}

			for (CTextureAtlasScale textureAtlasScale in this._config.allTextureAtlases)
			{
				for (CTextureAtlasCSF textureAtlasCSF in textureAtlasScale.allContentScaleFactors)
				{
					if (MathUtility.equals(this._config.defaultContentScaleFactor, textureAtlasCSF.csf))
					{
						textureAtlasScale.contentScaleFactor = textureAtlasCSF;
						break;
					}
				}
			}

			for (GAFTimelineConfig timelineConfig in this._config.timelines)
			{
				timelineConfig.allTextureAtlases = this._config.allTextureAtlases;

				for (CTextureAtlasScale textureAtlasScale in this._config.allTextureAtlases)
				{
					if (MathUtility.equals(this._config.defaultScale, textureAtlasScale.scale))
					{
						timelineConfig.textureAtlas = textureAtlasScale;
					}
				}

				timelineConfig.stageConfig = this._config.stageConfig;

				this.checkForMissedRegions(timelineConfig);
			}

			this.dispatchEvent(new Event(Event.COMPLETE));
		}

		  void readAnimationFrames(int tagID,[int startIndex=0, num framesCount, CAnimationFrame prevFrame=null])
		{
			if (isNaN(framesCount))
			{
				framesCount = this._bytes.readUnsignedInt();
			}
			int missedFramenum;
			int filterLength;
			int framenum;
			int statesCount;
			int filterType;
			int stateID;
			int zIndex;
			num alpha;
			Matrix matrix;
			String maskID;
			bool hasMask;
			bool hasEffect;
			bool hasActions;
			bool hasColorTransform;
			bool hasChangesInDisplayList;

			GAFTimelineConfig timelineConfig = this._config.timelines[this._config.timelines.length - 1];
			CAnimationFrameInstance instance;
			CAnimationFrame currentFrame;
			CBlurFilterData blurFilter;
			Map blurFilters = {};
			CFilter filter;

			int cycleTime = /*getTimer()*/ (stage.juggler.elapsedTime*1000);

			if( framesCount != null || framesCount == true)
			{
				for (int i = startIndex; i < framesCount; i++)
				{
					if (this._async
					&& (/*getTimer()*/ (stage.juggler.elapsedTime*1000) - cycleTime >= 20))
					{
						Starling.juggler.delayCall(readAnimationFrames, 0.001, tagID, i, framesCount, prevFrame);
						return;
					}

					framenum = this._bytes.readUnsignedInt();

					if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_FRAMES)
					{
						hasChangesInDisplayList = true;
						hasActions = false;
					}
					else
					{
						hasChangesInDisplayList = this._bytes.readbool();
						hasActions = this._bytes.readbool();
					}

					if( prevFrame != null || prevFrame == true)
					{
						currentFrame = prevFrame.clone(framenum);

						for (missedFramenum = prevFrame.framenum + 1; missedFramenum < currentFrame.framenum; missedFramenum++)
						{
							timelineConfig.animationConfigFrames.addFrame(prevFrame.clone(missedFramenum));
						}
					}
					else
					{
						currentFrame = new CAnimationFrame(framenum);

						if (currentFrame.framenum > 1)
						{
							for (missedFramenum = 1; missedFramenum < currentFrame.framenum; missedFramenum++)
							{
								timelineConfig.animationConfigFrames.addFrame(new CAnimationFrame(missedFramenum));
							}
						}
					}

					if( hasChangesInDisplayList != null || hasChangesInDisplayList == true)
					{
						statesCount = this._bytes.readUnsignedInt();

						for (int j = 0; j < statesCount; j++)
						{
							hasColorTransform = this._bytes.readbool();
							hasMask = this._bytes.readbool();
							hasEffect = this._bytes.readbool();

							stateID = this._bytes.readUnsignedInt();
							zIndex = this._bytes.readInt();
							alpha = this._bytes.readFloat();
							if (alpha == 1)
							{
								alpha = GAF.maxAlpha;
							}
							matrix = new Matrix(this._bytes.readFloat(), this._bytes.readFloat(), this._bytes.readFloat(),
									this._bytes.readFloat(), this._bytes.readFloat(), this._bytes.readFloat());

							filter = null;

							if( hasColorTransform != null || hasColorTransform == true)
							{
								List<num> params = [
									this._bytes.readFloat(), this._bytes.readFloat(), this._bytes.readFloat(),
									this._bytes.readFloat(), this._bytes.readFloat(), this._bytes.readFloat(),
									this._bytes.readFloat()];
								params.fixed = true;
								(filter != null) ? filter :filter =  new CFilter();
								filter.addColorTransform(params);
							}

							if( hasEffect != null || hasEffect == true)
							{
								(filter != null) ? filter :filter =  new CFilter();

								filterLength = this._bytes.readByte();
								for (int k = 0; k < filterLength; k++)
								{
									filterType = this._bytes.readUnsignedInt();
									String warning;

									switch (filterType)
									{
										case BinGAFAssetConfigConverter.FILTER_DROP_SHADOW:
											warning = readDropShadowFilter(this._bytes, filter);
											break;
										case BinGAFAssetConfigConverter.FILTER_BLUR:
											warning = readBlurFilter(this._bytes, filter);
											blurFilter = filter.filterConfigs[filter.filterConfigs.length - 1] as CBlurFilterData;
											if (blurFilter.blurX >= 2 && blurFilter.blurY >= 2)
											{
												if (!blurFilters.containsKey(stateID))
												{
													blurFilters[stateID] = blurFilter;
												}
											}
											else
											{
												blurFilters[stateID] = null;
											}
											break;
										case BinGAFAssetConfigConverter.FILTER_GLOW:
											warning = readGlowFilter(this._bytes, filter);
											break;
										case BinGAFAssetConfigConverter.FILTER_COLOR_MATRIX:
											warning = readColorMatrixFilter(this._bytes, filter);
											break;
										default:
											print(WarningConstants.UNSUPPORTED_FILTERS);
											break;
									}

									timelineConfig.addWarning(warning);
								}
							}

							if( hasMask != null || hasMask == true)
							{
								maskID = this._bytes.readUnsignedInt() + "";
							}
							else
							{
								maskID = "";
							}

							instance = new CAnimationFrameInstance(stateID.toString());
							instance.update(zIndex, matrix, alpha, maskID, filter);

							if (maskID != null && filter != null)
							{
								timelineConfig.addWarning(WarningConstants.FILTERS_UNDER_MASK);
							}

							currentFrame.addInstance(instance);
						}

						currentFrame.sortInstances();
					}

					if( hasActions != null || hasActions == true)
					{
						Map data;
						CFrameAction action;
						int count = this._bytes.readUnsignedInt();
						for (int a = 0; a < count; a++)
						{
							action = new CFrameAction();
							action.type = this._bytes.readUnsignedInt();
							action.scope = this._bytes.readUTF();

							int paramsLength = this._bytes.readUnsignedInt();
							if (paramsLength > 0)
							{
								ByteList paramsBA = new ByteList();
								paramsBA.endian = Endian.LITTLE_ENDIAN;
								this._bytes.readBytes(paramsBA, 0, paramsLength);
								paramsBA.position = 0;

								while (paramsBA.bytesAvailable > 0)
								{
									action.params.add(paramsBA.readUTF());
								}
								paramsBA.clear();
							}

							if (action.type == CFrameAction.DISPATCH_EVENT
							&&  action.params[0] == CSound.GAF_PLAY_SOUND
							&&  action.params.length > 3)
							{
								if (this._ignoreSounds)
								{
									continue; //do not add sound events if they're ignored
								}
								data = JSON.parse(action.params[3]);
								timelineConfig.addSound(data, framenum);
							}

							currentFrame.addAction(action);
						}
					}

					timelineConfig.animationConfigFrames.addFrame(currentFrame);

					prevFrame = currentFrame;
				} //end loop

				for (missedFramenum = prevFrame.framenum + 1; missedFramenum <= timelineConfig.framesCount; missedFramenum++)
				{
					timelineConfig.animationConfigFrames.addFrame(prevFrame.clone(missedFramenum));
				}

				for (currentFrame in timelineConfig.animationConfigFrames.frames)
				{
					for (instance in currentFrame.instances)
					{
						if (blurFilters[instance.id] && instance.filter != null)
						{
							blurFilter = instance.filter.getBlurFilter();
							if (blurFilter != null && blurFilter.resolution == 1)
							{
								blurFilter.blurX *= 0.5;
								blurFilter.blurY *= 0.5;
								blurFilter.resolution = 0.75;
							}
						}
					}
				}
			} //end condition

			this.delayedReadNextTag();
		}

		  void readTextureAtlasConfig(int tagID)
		{
			int i;
			int j;

			num scale = this._bytes.readFloat();
			if (this._config.scaleValues.indexOf(scale) == -1)
			{
				this._config.scaleValues.add(scale);
			}

			CTextureAtlasScale textureAtlas = this.getTextureAtlasScale(scale);

			/////////////////////

			CTextureAtlasCSF contentScaleFactor;
			int atlasLength = this._bytes.readByte();
			int atlasID;
			int sourceLength;
			num csf;
			String source;

			CTextureAtlasElements elements;
			if (textureAtlas.allContentScaleFactors.length > 0)
			{
				elements = textureAtlas.allContentScaleFactors[0].elements;
			}

			if( elements == null || elements == false)
			{
				elements = new CTextureAtlasElements();
			}

			for (i = 0; i < atlasLength; i++)
			{
				atlasID = this._bytes.readUnsignedInt();
				sourceLength = this._bytes.readByte();
				for (j = 0; j < sourceLength; j++)
				{
					source = this._bytes.readUTF();
					csf = this._bytes.readFloat();

					if (this._config.csfValues.indexOf(csf) == -1)
					{
						this._config.csfValues.add(csf);
					}

					contentScaleFactor = this.getTextureAtlasCSF(scale, csf);
					updateTextureAtlasSources(contentScaleFactor, atlasID.toString(), source);
					if (contentScaleFactor.elements == null)
					{
						contentScaleFactor.elements = elements;
					}
				}
			}

			/////////////////////

			int elementsLength = this._bytes.readUnsignedInt();
			CTextureAtlasElement element;
			bool hasScale9Grid;
			Rectangle scale9Grid;
			Point pivot;
			Point topLeft;
			num elementScaleX;
			num elementScaleY;
			num elementWidth;
			num elementHeight;
			int elementAtlasID;
			bool rotation;
			String linkageName;

			for (i = 0; i < elementsLength; i++)
			{
				pivot = new Point(this._bytes.readFloat(), this._bytes.readFloat());
				topLeft = new Point(this._bytes.readFloat(), this._bytes.readFloat());
				if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS
				|| tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2)
				{
					elementScaleX = elementScaleY = this._bytes.readFloat();
				}

				elementWidth = this._bytes.readFloat();
				elementHeight = this._bytes.readFloat();
				atlasID = this._bytes.readUnsignedInt();
				elementAtlasID = this._bytes.readUnsignedInt();

				if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS2
				|| tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3)
				{
					hasScale9Grid = this._bytes.readbool();
					if( hasScale9Grid != null || hasScale9Grid == true)
					{
						scale9Grid = new Rectangle(
								this._bytes.readFloat(), this._bytes.readFloat(),
								this._bytes.readFloat(), this._bytes.readFloat()
						);
					}
					else
					{
						scale9Grid = null;
					}
				}

				if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ATLAS3)
				{
					elementScaleX = this._bytes.readFloat();
					elementScaleY = this._bytes.readFloat();
					rotation = this._bytes.readbool();
					linkageName = this._bytes.readUTF();
				}

				if (elements.getElement(elementAtlasID.toString()) == null)
				{
					element = new CTextureAtlasElement(elementAtlasID.toString(), atlasID.toString());
					element.region = new Rectangle((topLeft.x).round(),(topLeft.y), elementWidth, elementHeight).round();
					element.pivotMatrix = new Matrix(1 / elementScaleX, 0, 0, 1 / elementScaleY, -pivot.x / elementScaleX, -pivot.y / elementScaleY);
					element.scale9Grid = scale9Grid;
					element.linkage = linkageName;
					element.rotated = rotation;
					elements.addElement(element);

					if (element.rotated)
					{
						sHelperRectangle.setTo(0, 0, elementHeight, elementWidth);
					}
					else
					{
						sHelperRectangle.setTo(0, 0, elementWidth, elementHeight);
					}
					sHelperMatrix.copyFrom(element.pivotMatrix);
					num invertScale = 1 / scale;
					sHelperMatrix.scale(invertScale, invertScale);
					RectangleUtil.getBounds(sHelperRectangle, sHelperMatrix, sHelperRectangle);

					if (!this._textureElementSizes[elementAtlasID])
					{
						this._textureElementSizes[elementAtlasID] = sHelperRectangle.clone();
					}
					else
					{
						this._textureElementSizes[elementAtlasID] = this._textureElementSizes[elementAtlasID].union(sHelperRectangle);
					}
				}
			}
		}

		  CTextureAtlasScale getTextureAtlasScale(num scale)
		{
			CTextureAtlasScale textureAtlasScale;
			List<CTextureAtlasScale> textureAtlasScales = this._config.allTextureAtlases;

			int l = textureAtlasScales.length;
			for (int i = 0; i < l; i++)
			{
				if (MathUtility.equals(textureAtlasScales[i].scale, scale))
				{
					textureAtlasScale = textureAtlasScales[i];
					break;
				}
			}

			if( textureAtlasScale == null || textureAtlasScale == false)
			{
				textureAtlasScale = new CTextureAtlasScale();
				textureAtlasScale.scale = scale;
				textureAtlasScales.add(textureAtlasScale);
			}

			return textureAtlasScale;
		}

		  CTextureAtlasCSF getTextureAtlasCSF(num scale,num csf)
		{
			CTextureAtlasScale textureAtlasScale = this.getTextureAtlasScale(scale);
			CTextureAtlasCSF textureAtlasCSF = textureAtlasScale.getTextureAtlasForCSF(csf);
			if( textureAtlasCSF == null || textureAtlasCSF == false)
			{
				textureAtlasCSF = new CTextureAtlasCSF(csf, scale);
				textureAtlasScale.allContentScaleFactors.add(textureAtlasCSF);
			}

			return textureAtlasCSF;
		}

		  void updateTextureAtlasSources(CTextureAtlasCSF textureAtlasCSF,String atlasID,String source)
		{
			CTextureAtlasSource textureAtlasSource;
			List<CTextureAtlasSource> textureAtlasSources = textureAtlasCSF.sources;
			int l = textureAtlasSources.length;
			for (int i = 0; i < l; i++)
			{
				if (textureAtlasSources[i].id == atlasID)
				{
					textureAtlasSource = textureAtlasSources[i];
					break;
				}
			}

			if( textureAtlasSource == null || textureAtlasSource == false)
			{
				textureAtlasSource = new CTextureAtlasSource(atlasID, source);
				textureAtlasSources.add(textureAtlasSource);
			}
		}

		  void parseError(String message)
		{
			if (this.hasEventListener(ErrorEvent.ERROR))
			{
				this.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, message));
			}
			else
			{
				throw new StateError(message);
			}
		}

		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------

		  GAFAssetConfig get config
		{
			return this._config;
		}

		  String get assetID
		{
			return this._assetID;
		}

		  void set ignoreSounds(bool ignoreSounds)
		{
			this._ignoreSounds = ignoreSounds;
		}

		//--------------------------------------------------------------------------
		//
		//  STATIC METHODS
		//
		//--------------------------------------------------------------------------

		 static  void readStageConfig(ByteList tagContent,GAFAssetConfig config)
		{
			CStage stageConfig = new CStage();

			stageConfig.fps = tagContent.readByte();
			stageConfig.color = tagContent.readInt();
			stageConfig.width = tagContent.readUnsignedShort();
			stageConfig.height = tagContent.readUnsignedShort();

			config.stageConfig = stageConfig;
		}



		 static  String readDropShadowFilter(ByteList source,CFilter filter)
		{
			List color = readColorValue(source);
			num blurX = source.readFloat();
			num blurY = source.readFloat();
			num angle = source.readFloat();
			num distance = source.readFloat();
			num strength = source.readFloat();
			bool inner = source.readbool();
			bool knockout = source.readbool();

			return filter.addDropShadowFilter(blurX, blurY, color[1], color[0], angle, distance, strength, inner, knockout);
		}

		 static  String readBlurFilter(ByteList source,CFilter filter)
		{
			return filter.addBlurFilter(source.readFloat(), source.readFloat());
		}

		 static  String readGlowFilter(ByteList source,CFilter filter)
		{
			List color = readColorValue(source);
			num blurX = source.readFloat();
			num blurY = source.readFloat();
			num strength = source.readFloat();
			bool inner = source.readbool();
			bool knockout = source.readbool();

			return filter.addGlowFilter(blurX, blurY, color[1], color[0], strength, inner, knockout);
		}

		 static  String readColorMatrixFilter(ByteList source,CFilter filter)
		{
			List<num> matrix = new List<num>(20, true);
			for (int i = 0; i < 20; i++)
			{
				matrix[i] = source.readFloat();
			}

			return filter.addColorMatrixFilter(matrix);
		}

		 static  List readColorValue(ByteList source)
		{
			int argbValue = source.readUnsignedInt();
			num alpha =(((argbValue >> 24) & 0xFF) * 100 / 255).toInt() / 100;
			int color = argbValue & 0xFFFFFF;

			return [alpha, color];
		}

		 static  void readAnimationMasks(int tagID,ByteList tagContent,GAFTimelineConfig timelineConfig)
		{
			int length = tagContent.readUnsignedInt();
			int objectID;
			int regionID;
			String type;

			for (int i = 0; i < length; i++)
			{
				objectID = tagContent.readUnsignedInt();
				regionID = tagContent.readUnsignedInt();
				if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS)
				{
					type = CAnimationObject.TYPE_TEXTURE;
				}
				else // BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_MASKS2
				{
					type = getAnimationObjectTypeString(tagContent.readUnsignedShort());
				}
				timelineConfig.animationObjects.addAnimationObject(new CAnimationObject(objectID.toString(), regionID.toString(), type, true));
			}
		}

		 static  String getAnimationObjectTypeString(int type)
		{
			String typeString = CAnimationObject.TYPE_TEXTURE;
			switch (type)
			{
				case 0:
					typeString = CAnimationObject.TYPE_TEXTURE;
					break;
				case 1:
					typeString = CAnimationObject.TYPE_TEXTFIELD;
					break;
				case 2:
					typeString = CAnimationObject.TYPE_TIMELINE;
					break;
			}

			return typeString;
		}

		 static  void readAnimationObjects(int tagID,ByteList tagContent,GAFTimelineConfig timelineConfig)
		{
			int length = tagContent.readUnsignedInt();
			int objectID;
			int regionID;
			String type;

			for (int i = 0; i < length; i++)
			{
				objectID = tagContent.readUnsignedInt();
				regionID = tagContent.readUnsignedInt();
				if (tagID == BinGAFAssetConfigConverter.TAG_DEFINE_ANIMATION_OBJECTS)
				{
					type = CAnimationObject.TYPE_TEXTURE;
				}
				else
				{
					type = getAnimationObjectTypeString(tagContent.readUnsignedShort());
				}
				timelineConfig.animationObjects.addAnimationObject(new CAnimationObject(objectID.toString(), regionID.toString(), type, false));
			}
		}

		 static  void readAnimationSequences(ByteList tagContent,GAFTimelineConfig timelineConfig)
		{
			int length = tagContent.readUnsignedInt();
			String sequenceID;
			int startFrameNo;
			int endFrameNo;

			for (int i = 0; i < length; i++)
			{
				sequenceID = tagContent.readUTF();
				startFrameNo = tagContent.readShort();
				endFrameNo = tagContent.readShort();
				timelineConfig.animationSequences.addSequence(new CAnimationSequence(sequenceID, startFrameNo, endFrameNo));
			}
		}

		 static  void readNamedParts(ByteList tagContent,GAFTimelineConfig timelineConfig)
		{
			timelineConfig.namedParts = {};

			int length = tagContent.readUnsignedInt();
			int partID;
			for (int i = 0; i < length; i++)
			{
				partID = tagContent.readUnsignedInt();
				timelineConfig.namedParts[partID] = tagContent.readUTF();
			}
		}

		 static  void readTextFields(ByteList tagContent,GAFTimelineConfig timelineConfig)
		{
			int length = tagContent.readUnsignedInt();
			num pivotX;
			num pivotY;
			int textFieldID;
			num width;
			num height;
			String text;
			bool embedFonts;
			bool multiline;
			bool wordWrap;
			String restrict;
			bool editable;
			bool selectable;
			bool displayAsPassword;
			int maxChars;

			TextFormat textFormat;

			for (int i = 0; i < length; i++)
			{
				textFieldID = tagContent.readUnsignedInt();
				pivotX = tagContent.readFloat();
				pivotY = tagContent.readFloat();
				width = tagContent.readFloat();
				height = tagContent.readFloat();

				text = tagContent.readUTF();

				embedFonts = tagContent.readbool();
				multiline = tagContent.readbool();
				wordWrap = tagContent.readbool();

				bool hasRestrict = tagContent.readbool();
				if( hasRestrict != null || hasRestrict == true)
				{
					restrict = tagContent.readUTF();
				}

				editable = tagContent.readbool();
				selectable = tagContent.readbool();
				displayAsPassword = tagContent.readbool();
				maxChars = tagContent.readUnsignedInt();

				// read textFormat
				int alignFlag = tagContent.readUnsignedInt();
				String align;
				switch (alignFlag)
				{
					case 0:
						align = TextFormatAlign.LEFT;
						break;
					case 1:
						align = TextFormatAlign.RIGHT;
						break;
					case 2:
						align = TextFormatAlign.CENTER;
						break;
					case 3:
						align = TextFormatAlign.JUSTIFY;
						break;
					case 4:
						align = TextFormatAlign.START;
						break;
					case 5:
						align = TextFormatAlign.END;
						break;
				}

				num blockIndent = tagContent.readUnsignedInt();
				bool bold = tagContent.readbool();
				bool bullet = tagContent.readbool();
				int color = tagContent.readUnsignedInt();

				String font = tagContent.readUTF();
				int indent = tagContent.readUnsignedInt();
				bool italic = tagContent.readbool();
				bool kerning = tagContent.readbool();
				int leading = tagContent.readUnsignedInt();
				num leftMargin = tagContent.readUnsignedInt();
				num letterSpacing = tagContent.readFloat();
				num rightMargin = tagContent.readUnsignedInt();
				int size = tagContent.readUnsignedInt();

				int l = tagContent.readUnsignedInt();
				List tabStops = [];
				for (int j = 0; j < l; j++)
				{
					tabStops.add(tagContent.readUnsignedInt());
				}

				String target = tagContent.readUTF();
				bool underline = tagContent.readbool();
				String url = tagContent.readUTF();

				/* String display = tagContent.readUTF();*/

				//TODO AS3 TextFormat has more features. Commented out. Problem?
				textFormat = new TextFormat(font, size, color, bold: bold, italic: italic, underline: underline, /*url, target, */ align: align, leftMargin: leftMargin,
						rightMargin: rightMargin, indent: blockIndent, leading: leading);
				/*
				textFormat.bullet = bullet;
				textFormat.kerning = kerning;
				//textFormat.display = display;
				textFormat.letterSpacing = letterSpacing;
				textFormat.tabStops = tabStops;
				*/
				textFormat.indent = indent;

				CTextFieldObject textFieldObject = new CTextFieldObject(textFieldID.toString(), text, textFormat,
						width, height);
				textFieldObject.pivotPoint.x = -pivotX;
				textFieldObject.pivotPoint.y = -pivotY;
				textFieldObject.embedFonts = embedFonts;
				textFieldObject.multiline = multiline;
				textFieldObject.wordWrap = wordWrap;
				textFieldObject.restrict = restrict;
				textFieldObject.editable = editable;
				textFieldObject.selectable = selectable;
				textFieldObject.displayAsPassword = displayAsPassword;
				textFieldObject.maxChars = maxChars;
				timelineConfig.textFields.addTextFieldObject(textFieldObject);
			}
		}

		 static  void readSounds(ByteList bytes,GAFAssetConfig config)
		{
			CSound soundData;
			int count = bytes.readShort();
			for (int i = 0; i < count; i++)
			{
				soundData = new CSound();
				soundData.soundID = bytes.readShort();
				soundData.linkageName = bytes.readUTF();
				soundData.source = bytes.readUTF();
				soundData.format = bytes.readByte();
				soundData.rate = bytes.readByte();
				soundData.sampleSize = bytes.readByte();
				soundData.stereo = bytes.readbool();
				soundData.sampleCount = bytes.readUnsignedInt();
				config.addSound(soundData);
			}
		}

		  void set defaultScale(num defaultScale)
		{
			_defaultScale = defaultScale;
		}

		  void set defaultCSF(num csf)
		{
			_defaultContentScaleFactor = csf;
		}
	}
