 part of stagexl_gaf;



	/** Dispatched when playhead reached first frame of sequence */
	// [Event(name="typeSequenceStart", type="starling.events.Event")]

	/** Dispatched when playhead reached end frame of sequence */
	// [Event(name="typeSequenceEnd", type="starling.events.Event")]

	/** Dispatched whenever the movie has displayed its last frame. */
	// [Event(name="complete", type="starling.events.Event")]

	/**
	 * GAFMovieClip represents animation display object that is ready to be used in Starling display list. It has
	 * all controls for animation familiar from standard MovieClip (<code>play</code>, <code>stop</code>, <code>gotoAndPlay,</code> etc.)
	 * and some more like <code>loop</code>, <code>nPlay</code>, <code>setSequence</code> that helps manage playback
	 */
	dynamic  class GAFMovieClip extends Sprite implements IAnimatable, IGAFDisplayObject, IMaxSize
	{
		 static final String EVENT_TYPE_SEQUENCE_START = "typeSequenceStart";
		 static final String EVENT_TYPE_SEQUENCE_END = "typeSequenceEnd";

		 static final Matrix HELPER_MATRIX = new Matrix.fromIdentity();
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

		 String _smoothing = TextureSmoothing.BILINEAR;

		 Map _displayObjectsDictionary;
		 Map _pixelMasksDictionary;
		 List<IGAFDisplayObject> _displayObjectsList;
		 List<IGAFImage> _imagesList;
		 List<GAFMovieClip> _mcVector;
		 List<GAFPixelMaskDisplayObject> _pixelMasksList;

		 CAnimationSequence _playingSequence;
		 Rectangle _timelineBounds;
		 Point _maxSize;
		 QuadBatch _boundsAndPivot;
		 GAFTimelineConfig _config;
		 GAFTimeline _gafTimeline;

		 bool _loop = true;
		 bool _skipFrames = true;
		 bool _reset;
		 bool _masked;
		 bool _inPlay;
		 bool _hidden;
		 bool _reverse;
		 bool _started;
		 bool _disposed;
		 bool _hasFilter;
		 bool _useClipping;
		 bool _alphaLessMax;
		 bool _addToJuggler;

		 num _scale;
		 num _contentScaleFactor;
		 num _currentTime = 0;
		// Hold the current time spent animating
		 num _lastFrameTime = 0;
		 num _frameDuration;

		 int _nextFrame;
		 int _startFrame;
		 int _finalFrame;
		 int _currentFrame;
		 int _totalFrames;

		 CFilter _filterConfig;
		 num _filterScale;

		 bool _pivotChanged;

		/** @ */
		num __debugOriginalAlpha = null;

		 bool _orientationChanged;

		// --------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------

		/**
		 * Creates a new GAFMovieClip instance.
		 *
		 * @param gafTimeline <code>GAFTimeline</code> from what <code>GAFMovieClip</code> will be created
		 * @param fps defines the frame rate of the movie clip. If not set - the stage config frame rate will be used instead.
		 * @param addToJuggler if <code>true - GAFMovieClip</code> will be added to <code>Starling.juggler</code>
		 * and removed automatically on <code>dispose</code>
		 */
	 GAFMovieClip(GAFTimeline gafTimeline,[int fps=-1, bool addToJuggler=true])
		{
			this._gafTimeline = gafTimeline;
			this._config = gafTimeline.config;
			this._scale = gafTimeline.scale;
			this._contentScaleFactor = gafTimeline.contentScaleFactor;
			this._addToJuggler = addToJuggler;

			this.initialize(gafTimeline.textureAtlas, gafTimeline.gafAsset);

			if (this._config.bounds != null)
			{
				this._timelineBounds = this._config.bounds.clone();
			}
			if (fps > 0)
			{
				this.fps = fps;
			}

			this.draw();
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		/** @
		 * Returns the child display object that exists with the specified ID. Use to obtain animation's parts
		 *
		 * @param id Child ID
		 * @return The child display object with the specified ID
		 */
		  DisplayObject getChildByID(String id)
		{
			return this._pixelMasksDictionary[id];
		}

		/** @
		 * Returns the mask display object that exists with the specified ID. Use to obtain animation's masks
		 *
		 * @param id Mask ID
		 * @return The mask display object with the specified ID
		 */
		  DisplayObject getMaskByID(String id)
		{
			return this._pixelMasksDictionary[id];
		}

		/**
		 * Shows mask display object that exists with the specified ID. Used for debug purposes only!
		 *
		 * @param id Mask ID
		 */
		  void showMaskByID(String id)
		{
			IGAFDisplayObject maskObject = this._pixelMasksDictionary[id];
			DisplayObject maskAsDisplayObject = maskObject as DisplayObject;
			GAFPixelMaskDisplayObject pixelMaskObject = this._pixelMasksDictionary[id];
			if (maskObject != null && pixelMaskObject != null)
			{
				CAnimationFrame frameConfig = this._config.animationConfigFrames.frames[this._currentFrame];
				CAnimationFrameInstance maskInstance = frameConfig.getInstanceByID(id);
				if( maskInstance != null || maskInstance == true)
				{
					this.getTransformMatrix(maskObject as IGAFDisplayObject, HELPER_MATRIX);
					maskInstance.applyTransformMatrix(maskObject.transformationMatrix, HELPER_MATRIX, this._scale);
					maskObject.invalidateOrientation();
				}

				////////////////////////////////

				CFilter cFilter = new CFilter();
				List<num> cmf = new List<num>(20)
						..setAll(0,[1, 0, 0, 0, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0]);
				cFilter.addColorMatrixFilter(cmf);

				GAFFilter gafFilter = new GAFFilter();
				gafFilter.setConfig(cFilter, this._scale);

				maskAsDisplayObject.filter = gafFilter;

				////////////////////////////////

				pixelMaskObject.pixelMask = null;
				this.addChild(maskAsDisplayObject);
			}
			else
			{
				print("WARNING: mask object is missing. It might be disposed.");
			}
		}

		/**
		 * Hides mask display object that previously has been shown using <code>showMaskByID</code> method.
		 * Used for debug purposes only!
		 *
		 * @param id Mask ID
		 */
		  void hideMaskByID(String id)
		{
			IGAFDisplayObject maskObject = this._displayObjectsMap[id];
			DisplayObject maskAsDisplayObject = maskObject as DisplayObject;
			GAFPixelMaskDisplayObject pixelMaskObject = this._pixelMasksMap[id];
			if (maskObject != null && pixelMaskObject != null)
			{
				maskAsDisplayObject.filter = null;
				CAnimationFrame frameConfig = this._config.animationConfigFrames.frames[this._currentFrame];
				CAnimationFrameInstance maskInstance = frameConfig.getInstanceByID(id);
				if( maskInstance != null || maskInstance == true)
				{
					this.getTransformMatrix(maskObject as IGAFDisplayObject, HELPER_MATRIX);
					maskInstance.applyTransformMatrix(maskObject.transformationMatrix, HELPER_MATRIX, this._scale);
					maskObject.invalidateOrientation();
				}

				if (maskObject.parent == this)
				{
					this.removeChild(maskAsDisplayObject);
				}
				pixelMaskObject.pixelMask = maskAsDisplayObject;
			}
			else
			{
				print("WARNING: mask object is missing. It might be disposed.");
			}
		}

		/**
		 * Clear playing sequence. If animation already in play just continue playing without sequence limitation
		 */
		  void clearSequence()
		{
			this._playingSequence = null;
		}

		/**
		 * Returns id of the sequence where animation is right now. If there is no sequences - returns <code>null</code>.
		 *
		 * @return id of the sequence
		 */
		  String get currentSequence
		{
			CAnimationSequence sequence = this._config.animationSequences.getSequenceByFrame(this.currentFrame);
			if( sequence != null || sequence == true)
			{
				return sequence.id;
			}
			return null;
		}

		/**
		 * Set sequence to play
		 *
		 * @param id Sequence ID
		 * @param play Play or not immediately. <code>true</code> - starts playing from sequence start frame. <code>false</code> - go to sequence start frame and stop
		 * @return sequence to play
		 */
		  CAnimationSequence setSequence(String id,[bool play=true])
		{
			this._playingSequence = this._config.animationSequences.getSequenceByID(id);

			if (this._playingSequence != null)
			{
				int startFrame = this._reverse ? this._playingSequence.endFrameNo - 1 : this._playingSequence.startFrameNo;
				if( play != null || play == true)
				{
					this.gotoAndPlay(startFrame);
				}
				else
				{
					this.gotoAndStop(startFrame);
				}
			}

			return this._playingSequence;
		}

		/**
		 * Moves the playhead in the timeline of the movie clip <code>play()</code> or <code>play(false)</code>.
		 * Or moves the playhead in the timeline of the movie clip and all child movie clips <code>play(true)</code>.
		 * Use <code>play(true)</code> in case when animation contain nested timelines for correct playback right after
		 * initialization (like you see in the original swf file).
		 * @param applyToAllChildren Specifies whether playhead should be moved in the timeline of the movie clip
		 * (<code>false</code>) or also in the timelines of all child movie clips (<code>true</code>).
		 */
		  void play([bool applyToAllChildren=false])
		{
			this._started = true;

			if( applyToAllChildren != null || applyToAllChildren == true)
			{
				int i = this._mcVector.length;
				while (i-- > 0)
				{
					this._mcVector[i]._started = true;
				}
			}

			this._play(applyToAllChildren, true);
		}

		/**
		 * Stops the playhead in the movie clip <code>stop()</code> or <code>stop(false)</code>.
		 * Or stops the playhead in the movie clip and in all child movie clips <code>stop(true)</code>.
		 * Use <code>stop(true)</code> in case when animation contain nested timelines for full stop the
		 * playhead in the movie clip and in all child movie clips.
		 * @param applyToAllChildren Specifies whether playhead should be stopped in the timeline of the
		 * movie clip (<code>false</code>) or also in the timelines of all child movie clips (<code>true</code>)
		 */
		  void stop([bool applyToAllChildren=false])
		{
			this._started = false;

			if( applyToAllChildren != null || applyToAllChildren == true)
			{
				int i = this._mcVector.length;
				while (i-- > 0)
				{
					this._mcVector[i]._started = false;
				}
			}

			this._stop(applyToAllChildren, true);
		}

		/**
		 * Brings the playhead to the specified frame of the movie clip and stops it there. First frame is "1"
		 *
		 * @param frame A number representing the frame number, or a string representing the label of the frame, to which the playhead is sent.
		 */
		  void gotoAndStop(dynamic frame)
		{
			this.checkAndSetCurrentFrame(frame);

			this.stop();
		}

		/**
		 * Starts playing animation at the specified frame. First frame is "1"
		 *
		 * @param frame A number representing the frame number, or a string representing the label of the frame, to which the playhead is sent.
		 */
		  void gotoAndPlay(dynamic frame)
		{
			this.checkAndSetCurrentFrame(frame);

			this.play();
		}

		/**
		 * Set the <code>loop</code> value to the GAFMovieClip instance and for the all children.
		 */
		  void loopAll(bool loop)
		{
			this.loop = loop;

			int i = this._mcVector.length;
			while (i-- > 0)
			{
				this._mcVector[i].loop = loop;
			}
		}

		/** @
		 * Advances all objects by a certain time (in seconds).
		 * @see starling.animation.IAnimatable
		 */
		  void advanceTime(num passedTime)
		{
			if (this._disposed)
			{
				print("WARNING: GAFMovieClip is disposed but is not removed from the Juggler");
				return;
			}
			else if (this._config.disposed)
			{
				this.dispose();
				return;
			}

			if (this._inPlay && this._frameDuration != num.POSITIVE_INFINITY)
			{
				this._currentTime += passedTime;

				int framesToPlay = ((this._currentTime - this._lastFrameTime) / this._frameDuration).round();
				if (this._skipFrames)
				{
					//here we skip the drawing of all frames to be played right now, but the last one
					for (int i = 0; i < framesToPlay; ++i)
					{
						if (this._inPlay)
						{
							this.changeCurrentFrame((i + 1) != framesToPlay);
						}
						else //if a playback was interrupted by some action or an event
						{
							if (!this._disposed)
							{
								this.draw();
							}
							break;
						}
					}
				}
				else if (framesToPlay > 0)
				{
					this.changeCurrentFrame(false);
				}
			}
			if (this._mcVector != null)
			{
				for (int i = 0; i < this._mcVector.length; i++)
				{
					this._mcVector[i].advanceTime(passedTime);
				}
			}
		}

		/** Shows bounds of a whole animation with a pivot point.
		 * Used for debug purposes.
		 */
		  void showBounds(bool value)
		{
			if (this._config.bounds != null)
			{
				if (!this._boundsAndPivot)
				{
					this._boundsAndPivot = new QuadBatch();
					this.updateBounds(this._config.bounds);
				}

				if( value != null || value == true)
				{
					this.addChild(this._boundsAndPivot);
				}
				else
				{
					this.removeChild(this._boundsAndPivot);
				}
			}
		}

		/**
		 * Disposes GAFMovieClip with config and all textures that was loaded with gaf file.
		 * Do not call this method if you have another GAFMovieClips that made from the same config
		 * or even loaded from the same gaf file.
		 */
		// [Deprecated(replacement="com.catalystapps.gaf.data.GAFBundle.dispose()", since="5.0")]
		  void disposeWithTextures()
		{
			this._gafTimeline.unloadFromVideoMemory();
			this._gafTimeline = null;
			this._config.dispose();
			this.dispose();
		}

		/** @ */
		  void setFilterConfig(CFilter value,[num scale=1])
		{
			if (!Starling.current.contextValid)
			{
				return;
			}

			if (this._filterConfig != value || this._filterScale != scale)
			{
				if( value != null || value == true)
				{
					this._filterConfig = value;
					this._filterScale = scale;
					GAFFilter gafFilter;
					if (this.filter != null)
					{
						if (this.filter is GAFFilter)
						{
							gafFilter = this.filter as GAFFilter;
						}
						else
						{
							this.filter.dispose();
							gafFilter = new GAFFilter();
						}
					}
					else
					{
						gafFilter = new GAFFilter();
					}

					gafFilter.setConfig(this._filterConfig, this._filterScale);
					this.filter = gafFilter;
				}
				else
				{
					if (this.filter != null)
					{
						this.filter.dispose();
						this.filter = null;
					}
					this._filterConfig = null;
					this._filterScale = null;
				}
			}
		}

		/** @ */
		  void invalidateOrientation()
		{
			this._orientationChanged = true;
		}

		/**
		 * Creates a new instance of GAFMovieClip.
		 */
		  GAFMovieClip copy()
		{
			return new GAFMovieClip(this._gafTimeline, this.fps, this._addToJuggler);
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		// --------------------------------------------------------------------------

		  void _gotoAndStop(dynamic frame)
		{
			this.checkAndSetCurrentFrame(frame);

			this._stop();
		}

		  void _play([bool applyToAllChildren=false, bool calledByUser=false])
		{
			if (this._inPlay && !applyToAllChildren)
			{
				return;
			}

			int i, l;

			if (this._totalFrames > 1)
			{
				this._inPlay = true;
			}

			if (applyToAllChildren
					&& this._config.animationConfigFrames.frames.length > 0)
			{
				CAnimationFrame frameConfig = this._config.animationConfigFrames.frames[this._currentFrame];
				if (frameConfig.actions != null)
				{
					CFrameAction action;
					l = frameConfig.actions.length;
					for (i = 0; i < l; i++)
					{
						action = frameConfig.actions[i];
						if (action.type == CFrameAction.STOP
								|| (action.type == CFrameAction.GOTO_AND_STOP
								&& int.parse(action.params[0]) == this.currentFrame))
						{
							this._inPlay = false;
							return;
						}
					}
				}

				DisplayObjectContainer child;
				GAFMovieClip childMC;
				GAFPixelMaskDisplayObject pixelMask;
				l = this.numChildren;
				for (i = 0; i < l; i++)
				{
					child = this.getChildAt(i) as DisplayObjectContainer;
					if (child is GAFMovieClip)
					{
						childMC = child as GAFMovieClip;
						if( calledByUser != null || calledByUser == true)
						{
							childMC.play(true);
						}
						else
						{
							childMC._play(true);
						}
					}
					else if (child is GAFPixelMaskDisplayObject)
					{
						pixelMask = child as GAFPixelMaskDisplayObject;
		    		int ml = pixelMask.numChildren;
						for (int mi = 0; mi < ml; mi++)
						{
							childMC = pixelMask.getChildAt(mi) as GAFMovieClip;
							if( childMC != null || childMC == true)
							{
								if( calledByUser != null || calledByUser == true)
								{
									childMC.play(true);
								}
								else
								{
									childMC._play(true);
								}
							}
						}
						if (pixelMask.pixelMask is GAFMovieClip)
						{
							if( calledByUser != null || calledByUser == true)
							{
								(pixelMask.pixelMask as GAFMovieClip).play(true);
							}
							else
							{
								(pixelMask.pixelMask as GAFMovieClip)._play(true);
							}
						}
					}
				}
			}

			this.runActions();

			this._reset = false;
		}

		  void _stop([bool applyToAllChildren=false, bool calledByUser=false])
		{
			this._inPlay = false;

			if (applyToAllChildren
			&& this._config.animationConfigFrames.frames.length > 0)
			{
				DisplayObjectContainer child;
				GAFMovieClip childMC;
				GAFPixelMaskDisplayObject childMask;
				for (int i = 0; i < this.numChildren; i++)
				{
					child = this.getChildAt(i) as DisplayObjectContainer;
					if (child is GAFMovieClip)
					{
						childMC = child as GAFMovieClip;
						if( calledByUser != null || calledByUser == true)
						{
							childMC.stop(true);
						}
						else
						{
							childMC._stop(true);
						}
					}
					else if (child is GAFPixelMaskDisplayObject)
					{
						childMask = (child as GAFPixelMaskDisplayObject);
						for (int m = 0; m < childMask.numChildren; m++)
						{
							childMC = childMask.getChildAt(m) as GAFMovieClip;
							if( childMC != null || childMC == true)
							{
								if( calledByUser != null || calledByUser == true)
								{
									childMC.stop(true);
								}
								else
								{
									childMC._stop(true);
								}
							}
						}
						if (childMask.pixelMask is GAFMovieClip)
						{
							if( calledByUser != null || calledByUser == true)
							{
								(childMask.pixelMask as GAFMovieClip).stop(true);
							}
							else
							{
								(childMask.pixelMask as GAFMovieClip)._stop(true);
							}
						}
					}
				}
			}
		}

		  void checkPlaybackEvents()
		{
			CAnimationSequence sequence;
			if (this.hasEventListener(EVENT_TYPE_SEQUENCE_START))
			{
				sequence = this._config.animationSequences.getSequenceStart(this._currentFrame + 1);
				if( sequence != null || sequence == true)
				{
					this.dispatchEventWith(EVENT_TYPE_SEQUENCE_START, false, sequence);
				}
			}
			if (this.hasEventListener(EVENT_TYPE_SEQUENCE_END))
			{
				sequence = this._config.animationSequences.getSequenceEnd(this._currentFrame + 1);
				if( sequence != null || sequence == true)
				{
					this.dispatchEventWith(EVENT_TYPE_SEQUENCE_END, false, sequence);
				}
			}
			if (this.hasEventListener(Event.COMPLETE))
			{
				if (this._currentFrame == this._finalFrame)
				{
					this.dispatchEventWith(Event.COMPLETE);
				}
			}
		}

		  void runActions()
		{
			if (this._config.animationConfigFrames.frames.length > 0)
			{
				return;
			}

			int i, l;
			List<CFrameAction> actions = this._config.animationConfigFrames.frames[this._currentFrame].actions;
			if( actions != null || actions == true)
			{
				CFrameAction action;
		 		l = actions.length;
				for (i = 0; i < l; i++)
				{
					action = actions[i];
					switch (action.type)
					{
						case CFrameAction.STOP:
							this.stop();
							break;
						case CFrameAction.PLAY:
							this.play();
							break;
						case CFrameAction.GOTO_AND_STOP:
							this.gotoAndStop(action.params[0]);
							break;
						case CFrameAction.GOTO_AND_PLAY:
							this.gotoAndPlay(action.params[0]);
							break;
						case CFrameAction.DISPATCH_EVENT:
							String type = action.params[0];
							if (this.hasEventListener(type))
							{
								switch (action.params.length)
								{
									case 4:
										Map data = action.params[3];
									case 3:
									// cancelable param is not used
									case 2:
										bool bubbles = (action.params[1] == "true" ? true : false);
										break;
								}
								this.dispatchEventWith(type, bubbles, data);
							}
							if (type == CSound.GAF_PLAY_SOUND
							&& GAF.autoPlaySounds)
							{
								this._gafTimeline.startSound(this.currentFrame);
							}
							break;
					}
				}
			}
		}

		  void checkAndSetCurrentFrame(dynamic frame)
		{
			if (int.parse(frame) > 0)
			{
				if (frame > this._totalFrames)
				{
					frame = this._totalFrames;
				}
			}
			else if (frame is String)
			{
				String label = frame;
				frame = this._config.animationSequences.getStartFrameNo(label);

				if (frame == 0)
				{
					throw new ArgumentError("Frame label " + label + " not found");
				}
			}
			else
			{
				frame = 1;
			}

			if (this._playingSequence != null && this._playingSequence.isSequenceFrame(frame) == null)
			{
				this._playingSequence = null;
			}

			if (this._currentFrame != frame - 1)
			{
				this._currentFrame = frame - 1;
				this.runActions();
				//actions may interrupt playback and lead to content disposition
				if (!this._disposed)
				{
					this.draw();
				}
			}
		}

		  void clearDisplayList()
		{
			this.removeChildren();

		 	int l = this._pixelMasksMap.length;
			for (int i = 0; i < l; i++)
			{
				this._pixelMasksMap[i].removeChildren();
			}
		}

		  void draw()
		{
			int i;
			int l;

			if (this._config.debugRegions != null)
			{
				// Non optimized way when there are debug regions
				this.clearDisplayList();
			}
			else
			{
				// Just hide the children to avoid dispatching a lot of events and alloc temporary arrays
				l = this._displayObjectsMap.length;
				for (i = 0; i < l; i++)
				{
					this._displayObjectsMap[i].alpha = 0;
				}

				l = this._mcVector.length;
				for (i = 0; i < l; i++)
				{
					this._mcVector[i]._hidden = true;
				}
			}

			List<CAnimationFrame> frames = this._config.animationConfigFrames.frames;
			if (frames.length > this._currentFrame)
			{
				int maskIndex;
				GAFMovieClip mc;
				Matrix objectPivotMatrix;
				IGAFDisplayObject displayObject;
				CAnimationFrameInstance instance;
				GAFPixelMaskDisplayObject pixelMaskObject;

				Map animationObjectsMap = this._config.animationObjects.animationObjectsMap;
				CAnimationFrame frameConfig = frames[this._currentFrame];
				List<CAnimationFrameInstance> instances = frameConfig.instances;
				l = instances.length;
				i = 0;
				while (i < l)
				{
					instance = instances[i++];

					displayObject = this._displayObjectsMap[instance.id];
					if( displayObject != null || displayObject == true)
					{
						objectPivotMatrix = getTransformMatrix(displayObject, HELPER_MATRIX);
						mc = displayObject as GAFMovieClip;
						if( mc != null || mc == true)
						{
							if (instance.alpha < 0)
							{
								mc.reset();
							}
							else if (mc._reset && mc._started)
							{
								mc._play(true);
							}
							mc._hidden = false;
						}

						if (instance.alpha <= 0)
						{
							continue;
						}

						displayObject.alpha = instance.alpha;

						//if display object is not a mask
						if (!animationObjectsMap[instance.id].mask)
						{
							//if display object is under mask
							if (instance.maskID != null)
							{
								this.renderDebug(mc, instance, true);

								pixelMaskObject = this._pixelMasksMap[instance.maskID];
								if( pixelMaskObject != null || pixelMaskObject == true)
								{
									pixelMaskObject.addChild(displayObject as DisplayObject);
									maskIndex++;

									instance.applyTransformMatrix(displayObject.transformationMatrix, objectPivotMatrix, this._scale);
									displayObject.invalidateOrientation();
									displayObject.setFilterConfig(null);

									if (maskIndex == 1)
									{
										this.addChild(pixelMaskObject);
									}
								}
							}
							else //if display object is not masked
							{
								if( pixelMaskObject != null || pixelMaskObject == true)
								{
									maskIndex = 0;
									pixelMaskObject = null;
								}

								this.renderDebug(mc, instance, this._masked);

								instance.applyTransformMatrix(displayObject.transformationMatrix, objectPivotMatrix, this._scale);
								displayObject.invalidateOrientation();
								displayObject.setFilterConfig(instance.filter, this._scale);

								this.addChild(displayObject as DisplayObject);
							}

							if (mc && mc._started)
							{
								mc._play(true);
							}

							if (DebugUtility.RENDERING_DEBUG && displayObject is IGAFDebug)
							{
								List<int> colors = DebugUtility.getRenderingDifficultyColor(
										instance, this._alphaLessMax, this._masked, this._hasFilter);
								(displayObject as IGAFDebug).debugColors = colors;
							}
						}
						else
						{
							maskIndex = 0;

							IGAFDisplayObject maskObject = this._displayObjectsMap[instance.id];
							if( maskObject != null || maskObject == true)
							{
								CAnimationFrameInstance maskInstance = frameConfig.getInstanceByID(instance.id);
								if( maskInstance != null || maskInstance == true)
								{
									getTransformMatrix(maskObject, HELPER_MATRIX);
									maskInstance.applyTransformMatrix(maskObject.transformationMatrix, HELPER_MATRIX, this._scale);
									maskObject.invalidateOrientation();
								}
								else
								{
									throw new StateError("Unable to find mask with ID " + instance.id);
								}

								mc = maskObject as GAFMovieClip;
								if (mc && mc._started)
								{
									mc._play(true);
								}
							}
							/*else
							{
								throw new StateError("Unable to find mask with ID " + instance.id);
							}*/
						}
					}
				}
			}

			if (this._config.debugRegions != null)
			{
				this.addDebugRegions();
			}

			this.checkPlaybackEvents();
		}

		  void renderDebug(GAFMovieClip mc,CAnimationFrameInstance instance,bool masked)
		{
			if (DebugUtility.RENDERING_DEBUG && mc != null)
			{
				bool hasFilter = (instance.filter != null) || this._hasFilter;
				bool alphaLessMax = instance.alpha < GAF.maxAlpha || this._alphaLessMax;

				bool changed;
				if (mc._alphaLessMax != alphaLessMax)
				{
					mc._alphaLessMax = alphaLessMax;
					changed = true;
				}
				if (mc._masked != masked)
				{
					mc._masked = masked;
					changed = true;
				}
				if (mc._hasFilter != hasFilter)
				{
					mc._hasFilter = hasFilter;
					changed = true;
				}
				if( changed != null || changed == true)
				{
					mc.draw();
				}
			}
		}

		  void addDebugRegions()
		{
			Quad debugView;
			for (GAFDebugInformation debugRegion in this._config.debugRegions)
			{
				switch (debugRegion.type)
				{
					case GAFDebugInformation.TYPE_POINT:
						debugView = new Quad(4, 4, debugRegion.color);
						debugView.x = debugRegion.point.x - 2;
						debugView.y = debugRegion.point.y - 2;
						debugView.alpha = debugRegion.alpha;
						break;
					case GAFDebugInformation.TYPE_RECT:
						debugView = new Quad(debugRegion.rect.width, debugRegion.rect.height, debugRegion.color);
						debugView.x = debugRegion.rect.x;
						debugView.y = debugRegion.rect.y;
						debugView.alpha = debugRegion.alpha;
						break;
				}

				this.addChild(debugView);
			}
		}

		  void reset()
		{
			this._gotoAndStop((this._reverse ? this._finalFrame : this._startFrame) + 1);
			this._reset = true;
			this._currentTime = 0;
			this._lastFrameTime = 0;

			int i = this._mcVector.length;
			while (i-- > 0)
			{
				this._mcVector[i].reset();
			}
		}

		  Matrix getTransformMatrix(IGAFDisplayObject displayObject,[Matrix matrix=null])
		{
			if( matrix == null || matrix == false) matrix = new Matrix();

			matrix.copyFrom(displayObject.pivotMatrix);

			return matrix;
		}

		  void initialize(CTextureAtlas textureAtlas,GAFAsset gafAsset)
		{
			this._displayObjectsDictionary = {};
			this._pixelMasksDictionary = {};
			this._displayObjectsList= [];
			this._imagesList= [];
			this._mcVector= [];
			this._pixelMasksList= [];

			this._currentFrame = 0;
			this._totalFrames = this._config.framesCount;
			this.fps = this._config.stageConfig != null ? this._config.stageConfig.fps : Starling.current.nativeStage.frameRate;

			Map animationObjectsMap = this._config.animationObjects.animationObjectsMap;

			DisplayObject displayObject;
			for (CAnimationObject animationObjectConfig in animationObjectsMap)
			{
				switch (animationObjectConfig.type)
				{
					case CAnimationObject.TYPE_TEXTURE:
						IGAFTexture texture = textureAtlas.getTexture(animationObjectConfig.regionID);
						if (texture is GAFScale9Texture && !animationObjectConfig.mask) // GAFScale9Image doesn't work as mask
						{
							displayObject = new GAFScale9Image(texture as GAFScale9Texture);
						}
						else
						{
							displayObject = new GAFImage(texture);
							//(displayObject as GAFImage)//.smoothing = this._smoothing; //not supported in StageXL
						}
						break;
					case CAnimationObject.TYPE_TEXTFIELD:
						CTextFieldObject tfObj = this._config.textFields.textFieldObjectsMap[animationObjectConfig.regionID];
						displayObject = new GAFTextField(tfObj, this._scale, this._contentScaleFactor);
						break;
					case CAnimationObject.TYPE_TIMELINE:
						GAFTimeline timeline = gafAsset.getGAFTimelineByID(animationObjectConfig.regionID);
						displayObject = new GAFMovieClip(timeline, this.fps, false);
						break;
				}

				if (animationObjectConfig.maxSize != null && displayObject is IMaxSize)
				{
					Point maxSize = new Point(
							animationObjectConfig.maxSize.x * this._scale,
							animationObjectConfig.maxSize.y * this._scale);
					(displayObject as IMaxSize).maxSize = maxSize;
				}

				this.addDisplayObject(animationObjectConfig.instanceID, displayObject);
				if (animationObjectConfig.mask)
				{
					GAFPixelMaskDisplayObject pixelMaskDisplayObject = new GAFPixelMaskDisplayObject(this._gafTimeline.contentScaleFactor);
					pixelMaskDisplayObject.pixelMask = displayObject;

					this.addDisplayObject(animationObjectConfig.instanceID, pixelMaskDisplayObject);
				}

				if (this._config.namedParts != null)
				{
					String instanceName = this._config.namedParts[animationObjectConfig.instanceID];
					if (instanceName != null && !this.hasOwnProperty(instanceName))
					{
						this[this._config.namedParts[animationObjectConfig.instanceID]] = displayObject;
						displayObject.name = instanceName;
					}
				}
			}

			if (this._addToJuggler)
			{
				Starling.juggler.add(this);
			}
		}

		  void addDisplayObject(String id,DisplayObject displayObject)
		{
			if (displayObject is GAFPixelMaskDisplayObject)
			{
				this._pixelMasksDictionary[id] = displayObject;
				this._pixelMasksList[_pixelMasksList.length] = displayObject as GAFPixelMaskDisplayObject;
			}
			else
			{
				this._displayObjectsDictionary[id] = displayObject;
				this._displayObjectsList[_displayObjectsList.length] = displayObject as IGAFDisplayObject;
				if (displayObject is IGAFImage)
				{
					this._imagesList[_imagesList.length] = displayObject as IGAFImage;
				}
				else if (displayObject is GAFMovieClip)
				{
					this._mcVector[_mcVector.length] = displayObject as GAFMovieClip;
				}
			}
		}

		  void updateBounds(Rectangle bounds)
		{
			this._boundsAndPivot.reset();
			//bounds
			if (bounds.width > 0 &&  bounds.height > 0)
			{
				Quad quad = new Quad(bounds.width * this._scale, 2, 0xff0000);
				quad.x = bounds.x * this._scale;
				quad.y = bounds.y * this._scale;
				this._boundsAndPivot.addQuad(quad);
				quad = new Quad(bounds.width * this._scale, 2, 0xff0000);
				quad.x = bounds.x * this._scale;
				quad.y = bounds.bottom * this._scale - 2;
				this._boundsAndPivot.addQuad(quad);
				quad = new Quad(2, bounds.height * this._scale, 0xff0000);
				quad.x = bounds.x * this._scale;
				quad.y = bounds.y * this._scale;
				this._boundsAndPivot.addQuad(quad);
				quad = new Quad(2, bounds.height * this._scale, 0xff0000);
				quad.x = bounds.right * this._scale - 2;
				quad.y = bounds.y * this._scale;
				this._boundsAndPivot.addQuad(quad);
			}
			//pivot point
			quad = new Quad(5, 5, 0xff0000);
			this._boundsAndPivot.addQuad(quad);
		}

		/** @ */
		 void __debugHighlight()
		{
			// use namespace gaf_internal;

			if ((this.__debugOriginalAlpha == null))
			{
				this.__debugOriginalAlpha = this.alpha;
			}
			this.alpha = 1;
		}

		/** @ */
		 void __debugLowlight()
		{
			// use namespace gaf_internal;

			if ((this.__debugOriginalAlpha) == null)
			{
				this.__debugOriginalAlpha = this.alpha;
			}
			this.alpha = .05;
		}

		/** @ */
		 void __debugResetLight()
		{
			// use namespace gaf_internal;

			if ((this.__debugOriginalAlpha) != null)
			{
				this.alpha = this.__debugOriginalAlpha;
				this.__debugOriginalAlpha = null;
			}
		}

		//[Inline]
		 void updateTransformMatrix()
		{
			if (this._orientationChanged)
			{
				this.transformationMatrix = this.transformationMatrix;
				this._orientationChanged = false;
			}
		}

		//--------------------------------------------------------------------------
		//
		// OVERRIDDEN METHODS
		//
		//--------------------------------------------------------------------------

		/** Removes a child at a certain index. The index positions of any display objects above
         *  the child are decreased by 1. If requested, the child will be disposed right away. */
		@override 
		  void removeChildAt(int index,[bool dispose=false])
		{
			if( dispose != null || dispose == true)
			{
				String key;
				DisplayObject child = this.getChildAt(index);
				if (child is IGAFDisplayObject)
				{
					int id = this._mcVector.indexOf(child as GAFMovieClip);
					if (id >= 0)
					{
						this._mcVector.splice(id, 1);
					}
					id = this._imagesList.indexOf(child as IGAFImage);
					if (id >= 0)
					{
						this._imagesList.splice(id, 1);
					}
					id = this._displayObjectsList.indexOf(child as IGAFDisplayObject);
					if (id >= 0)
					{
						this._displayObjectsList.splice(id, 1);

						for (key in this._displayObjectsDictionary)
						{
							if (this._displayObjectsDictionary[key] == child)
							{
								this._displayObjectsDictionary.remove(key);
								break;
							}
						}
					}
					id = this._pixelMasksList.indexOf(child as GAFPixelMaskDisplayObject);
					if (id >= 0)
					{
						this._pixelMasksList.splice(id, 1);

						for (key in this._pixelMasksDictionary)
						{
							if (this._pixelMasksDictionary[key] == child)
							{
								this._pixelMasksDictionary.remove(key);
								break;
							}
						}
					}
				}
			}

			return super.removeChildAt(index, dispose);
		}

		/** Returns a child object with a certain name (non-recursively). */
		@override 
		  DisplayObject getChildByName(String name)
		{
			int numChildren = this._displayObjectsList.length;
			for (int i = 0; i < numChildren; ++i)
				if (this._displayObjectsDictionary.name == name)
					return this._displayObjectsDictionary as DisplayObject;

			return super.getChildByName(name);
		}

		/**
		 * Disposes all resources of the display object instance. Note: this method won't delete used texture atlases from GPU memory.
		 * To delete texture atlases from GPU memory use <code>unloadFromVideoMemory()</code> method for <code>GAFTimeline</code> instance
		 * from what <code>GAFMovieClip</code> was instantiated.
		 * Call this method every time before delete no longer required instance! Otherwise GPU memory leak may occur!
		 */
		@override 
		  void dispose()
		{
			if (this._disposed)
			{
				return;
			}
			this.stop();

			if (this._addToJuggler)
			{
				Starling.juggler.remove(this);
			}

			int i, l;

			l = this._displayObjectsList.length;
			for (i = 0; i < l; i++)
			{
				this._displayObjectsList[i].dispose();
			}

			l = this._pixelMasksList.length;
			for (i = 0; i < l; i++)
			{
				this._pixelMasksList[i].dispose();
			}

			if (this._boundsAndPivot)
			{
				this._boundsAndPivot.dispose();
				this._boundsAndPivot = null;
			}

			this._displayObjectsDictionary = null;
			this._pixelMasksDictionary = null;
			this._displayObjectsList= null;
			this._pixelMasksList= null;
			this._imagesList= null;
			this._gafTimeline = null;
			this._mcVector= null;
			this._config = null;

			if (this.parent != null)
			{
				this.removeFromParent();
			}
			super.dispose();

			this._disposed = true;
		}

		/** @ */
		@override 
		  void render(RenderSupport support,num parentAlpha)
		{
			try
			{
				super.render(support, parentAlpha);
			}
			catch (error)
			{
				if (error is IllegalOperationError
						&& (error.message as String).indexOf("not possible to stack filters") != -1)
				{
					if (this.hasEventListener(ErrorEvent.ERROR))
					{
						this.dispatchEventWith(ErrorEvent.ERROR, true, error.message);
					}
					else
					{
						throw error;
					}
				}
				else
				{
					throw error;
				}
			}
		}

		/** @ */
		@override 
		  void set pivotX(num value)
		{
			this._pivotChanged = true;
			super.pivotX = value;
		}

		/** @ */
		@override 
		  void set pivotY(num value)
		{
			this._pivotChanged = true;
			super.pivotY = value;
		}

		/** @ */
		@override 
		  num get x
		{
			updateTransformMatrix();
			return super.x;
		}

		/** @ */
		@override 
		  num get y
		{
			updateTransformMatrix();
			return super.y;
		}

		/** @ */
		@override 
		  num get rotation
		{
			updateTransformMatrix();
			return super.rotation;
		}

		/** @ */
		@override 
		  num get scaleX
		{
			updateTransformMatrix();
			return super.scaleX;
		}

		/** @ */
		@override 
		  num get scaleY
		{
			updateTransformMatrix();
			return super.scaleY;
		}

		/** @ */
		@override 
		  num get skewX
		{
			updateTransformMatrix();
			return super.skewX;
		}

		/** @ */
		@override 
		  num get skewY
		{
			updateTransformMatrix();
			return super.skewY;
		}

		//--------------------------------------------------------------------------
		//
		//  EVENT HANDLERS
		//
		//--------------------------------------------------------------------------

		  void changeCurrentFrame(bool isSkipping)
		{
			this._nextFrame = this._currentFrame + (this._reverse ? -1 : 1);
			this._startFrame = (this._playingSequence != null? this._playingSequence.startFrameNo : 1) - 1;
			this._finalFrame = (this._playingSequence != null ? this._playingSequence.endFrameNo : this._totalFrames) - 1;

			if (this._nextFrame >= this._startFrame && this._nextFrame <= this._finalFrame)
			{
				this._currentFrame = this._nextFrame;
				this._lastFrameTime += this._frameDuration;
			}
			else
			{
				if (!this._loop)
				{
					this.stop();
				}
				else
				{
					this._currentFrame = this._reverse ? this._finalFrame : this._startFrame;
					this._lastFrameTime += this._frameDuration;
					bool resetInvisibleChildren = true;
				}
			}

			this.runActions();

			//actions may interrupt playback and lead to content disposition
			if (this._disposed)
			{
				return;
			}
			else if (this._config.disposed)
			{
				this.dispose();
				return;
			}

			if( isSkipping == null || isSkipping == false)
			{
				// Draw will trigger events if any
				this.draw();
			}
			else
			{
				this.checkPlaybackEvents();
			}

			if( resetInvisibleChildren != null || resetInvisibleChildren == true)
			{
				//reset timelines that aren't visible
				int i = this._mcVector.length;
				while (i--)
				{
					if (this._mcVector[i]._hidden != null)
					{
						this._mcVector[i].reset();
					}
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------

		/**
		 * Specifies the number of the frame in which the playhead is located in the timeline of the GAFMovieClip instance. First frame is "1"
		 */
		  int get currentFrame
		{
			return this._currentFrame + 1;// Like in standart AS3 API for MovieClip first frame is "1" instead of "0" (but internally used "0")
		}

		/**
		 * The total number of frames in the GAFMovieClip instance.
		 */
		  int get totalFrames
		{
			return this._totalFrames;
		}

		/**
		 * Indicates whether GAFMovieClip instance already in play
		 */
		  bool get inPlay
		{
			return this._inPlay;
		}

		/**
		 * Indicates whether GAFMovieClip instance continue playing from start frame after playback reached animation end
		 */
		  bool get loop
		{
			return this._loop;
		}

		  void set loop(bool loop)
		{
			this._loop = loop;
		}

		/**
		 * The smoothing filter that is used for the texture. Possible values are <code>TextureSmoothing.BILINEAR, TextureSmoothing.NONE, TextureSmoothing.TRILINEAR</code>
		 */
		  void set smoothing(String value)
		{
			if (TextureSmoothing.isValid(value))
			{
				this._smoothing = value;

				int i = this._imagesList.length;
				while (i-- > 0)
				{
					//this._imagesList[i]//.smoothing = this._smoothing; //not supported in StageXL
				}
			}
		}

		  String get smoothing
		{
			return this._smoothing;
		}

		  bool get useClipping
		{
			return this._useClipping;
		}

		/** @ */
		  Point get maxSize
		{
			return this._maxSize;
		}

		/** @ */
		  void set maxSize(Point value)
		{
			this._maxSize = value;
		}

		/**
		 * if set <code>true</code> - <code>GAFMivieclip</code> will be clipped with flash stage dimensions
		 */
		  void set useClipping(bool value)
		{
			this._useClipping = value;

			if (this._useClipping && this._config.stageConfig != null)
			{
				this.clipRect = new Rectangle(0, 0, this._config.stageConfig.width * this._scale, this._config.stageConfig.height * this._scale);
			}
			else
			{
				this.clipRect = null;
			}
		}

		  num get fps
		{
			if (this._frameDuration == double.INFINITY)
			{
				return 0;
			}
			return 1 / this._frameDuration;
		}

		/**
		 * Sets an individual frame rate for <code>GAFMovieClip</code>. If this value is lower than stage fps -  the <code>GAFMovieClip</code> will skip frames.
		 */
		  void set fps(num value)
		{
			if (value <= 0)
			{
				this._frameDuration = double.INFINITY;
			}
			else
			{
				this._frameDuration = 1 / value;
			}

			int i = this._mcVector.length;
			while (i-- > 0)
			{
				this._mcVector[i].fps = value;
			}
		}

		  bool get reverse
		{
			return this._reverse;
		}

		/**
		 * If <code>true</code> animation will be playing in reverse mode
		 */
		  void set reverse(bool value)
		{
			this._reverse = value;

			int i = this._mcVector.length;
			while (i-- > 0)
			{
				this._mcVector[i]._reverse = value;
			}
		}

		  bool get skipFrames
		{
			return this._skipFrames;
		}

		/**
		 * Indicates whether GAFMovieClip instance should skip frames when application fps drops down or play every frame not depending on application fps.
		 * Value false will force GAFMovieClip to play each frame not depending on application fps (the same behavior as in regular Flash Movie Clip).
		 * Value true will force GAFMovieClip to play animation "in time". And when application fps drops down it will start skipping frames (default behavior).
		 */
		  void set skipFrames(bool value)
		{
			this._skipFrames = value;

			int i = this._mcVector.length;
			while (i-- > 0)
			{
				this._mcVector[i]._skipFrames = value;
			}
		}

		/** @ */
		  Matrix get pivotMatrix
		{
			//HELPER_MATRIX.copyFrom(this._pivotMatrix);
			HELPER_MATRIX.identity();

			if (this._pivotChanged)
			{
				HELPER_MATRIX.tx = this.pivotX;
				HELPER_MATRIX.ty = this.pivotY;
			}

			return HELPER_MATRIX;
		}
	}
