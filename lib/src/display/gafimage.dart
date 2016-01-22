 part of stagexl_gaf;



	/**
	 * GAFImage represents static GAF display object that is part of the <code>GAFMovieClip</code>.
	 */
	 class GAFImage extends Image implements IGAFImage, IMaxSize, IGAFDebug
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

		 static final Point HELPER_POINT = new Point(0,0);
		 static final ListD HELPER_POINT_3D = new ListD();
		 static final Matrix HELPER_MATRIX = new Matrix.fromIdentity();
		 static final Matrix3D HELPER_MATRIX_3D = new Matrix3D();

		 IGAFTexture _assetTexture;

		 CFilter _filterConfig;
		 num _filterScale;

		 Point _maxSize;

		 bool _pivotChanged;

		/** @ */
		num __debugOriginalAlpha = null;

		 bool _orientationChanged;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------

		/**
		 * Creates a new <code>GAFImage</code> instance.
		 * @param assetTexture <code>IGAFTexture</code> from which it will be created.
		 */
	 GAFImage(IGAFTexture assetTexture)
		{
			this._assetTexture = assetTexture.clone();

			super(this._assetTexture.texture);
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		/**
		 * Creates a new instance of GAFImage.
		 */
		  GAFImage copy()
		{
			return new GAFImage(this._assetTexture);
		}

		/** @ */
		  void invalidateOrientation()
		{
			this._orientationChanged = true;
		}

		/** @ */
		  void set debugColors(List<int> value)
		{
			num alpha0;
			num alpha1;

			switch (value.length)
			{
				case 1:
					this.color = value[0];
					this.alpha = (value[0] >>/*>*/ 24) / 255;
					break;
				case 2:
					this.setVertexColor(0, value[0]);
					this.setVertexColor(1, value[0]);
					this.setVertexColor(2, value[1]);
					this.setVertexColor(3, value[1]);

					alpha0 = (value[0] >>/*>*/ 24) / 255;
					alpha1 = (value[1] >>/*>*/ 24) / 255;
					this.setVertexAlpha(0, alpha0);
					this.setVertexAlpha(1, alpha0);
					this.setVertexAlpha(2, alpha1);
					this.setVertexAlpha(3, alpha1);
					break;
				case 3:
					this.setVertexColor(0, value[0]);
					this.setVertexColor(1, value[0]);
					this.setVertexColor(2, value[1]);
					this.setVertexColor(3, value[2]);

					alpha0 = (value[0] >>/*>*/ 24) / 255;
					this.setVertexAlpha(0, alpha0);
					this.setVertexAlpha(1, alpha0);
					this.setVertexAlpha(2, (value[1] >>/*>*/ 24) / 255);
					this.setVertexAlpha(3, (value[2] >>/*>*/ 24) / 255);
					break;
				case 4:
					this.setVertexColor(0, value[0]);
					this.setVertexColor(1, value[1]);
					this.setVertexColor(2, value[2]);
					this.setVertexColor(3, value[3]);

					this.setVertexAlpha(0, (value[0] >>/*>*/ 24) / 255);
					this.setVertexAlpha(1, (value[1] >>/*>*/ 24) / 255);
					this.setVertexAlpha(2, (value[2] >>/*>*/ 24) / 255);
					this.setVertexAlpha(3, (value[3] >>/*>*/ 24) / 255);
					break;
			}
		}

		/**
		 * Change the texture of the <code>GAFImage</code> to a new one.
		 * @param newTexture the new <code>IGAFTexture</code> which will be used to replace existing one.
		 */
		  void changeTexture(IGAFTexture newTexture)
		{
			this.texture = newTexture.texture;
			this.readjustSize();
			this._assetTexture.copyFrom(newTexture);
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
					this._filterScale = NaN;
				}
			}
		}

		//--------------------------------------------------------------------------
		//
		//  PRIVATE METHODS
		//
		//--------------------------------------------------------------------------

		/** @ */
		 void __debugHighlight()
		{
			// use namespace gaf_internal;

			if ((this.__debugOriginalAlpha) == null)
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

		//AS3: [Inline]
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

		/**
		 * Disposes all resources of the display object.
		 */
		@override 
		  void dispose()
		{
			if (this.filter != null)
			{
				this.filter.dispose();
				this.filter = null;
			}
			this._assetTexture = null;
			this._filterConfig = null;

			super.dispose();
		}

		@override 
		  Rectangle getBounds(DisplayObject targetSpace,[Rectangle resultRect=null])
		{
			if (resultRect == null) resultRect = new Rectangle();

			if (targetSpace == this) // optimization
			{
				mVertexData.getPosition(3, HELPER_POINT);
				resultRect.setTo(0.0, 0.0, HELPER_POINT.x, HELPER_POINT.y);
			}
			else if (targetSpace == parent && rotation == 0.0 && isEquivalent(skewX, skewY)) // optimization
			{
				num scaleX = this.scaleX;
				num scaleY = this.scaleY;
				mVertexData.getPosition(3, HELPER_POINT);
				resultRect.setTo(x - pivotX * scaleX,      y - pivotY * scaleY,
						HELPER_POINT.x * scaleX, HELPER_POINT.y * scaleY);
				if (scaleX < 0) { resultRect.width  *= -1; resultRect.x -= resultRect.width;  }
				if (scaleY < 0) { resultRect.height *= -1; resultRect.y -= resultRect.height; }
			}
			else if (is3D != null && stage != null)
			{
				stage.getCameraPosition(targetSpace, HELPER_POINT_3D);
				getTransformationMatrix3D(targetSpace, HELPER_MATRIX_3D);
				mVertexData.getBoundsProjected(HELPER_MATRIX_3D, HELPER_POINT_3D, 0, 4, resultRect);
			}
			else
			{
				getTransformationMatrix(targetSpace, HELPER_MATRIX);
				mVertexData.getBounds(HELPER_MATRIX, 0, 4, resultRect);
			}

			return resultRect;
		}

		 bool isEquivalent(num a,num b,[num epsilon=0.0001])
		{
			return (a - epsilon < b) && (a + epsilon > b);
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

		//--------------------------------------------------------------------------
		//
		//  GETTERS AND SETTERS
		//
		//--------------------------------------------------------------------------

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
		 * Returns current <code>IGAFTexture</code>.
		 * @return current <code>IGAFTexture</code>
		 */
		  IGAFTexture get assetTexture
		{
			return this._assetTexture;
		}

		/** @ */
		  Matrix get pivotMatrix
		{
			HELPER_MATRIX.copyFrom(this._assetTexture.pivotMatrix);

			if (this._pivotChanged)
			{
				HELPER_MATRIX.tx = this.pivotX;
				HELPER_MATRIX.ty = this.pivotY;
			}

			return HELPER_MATRIX;
		}
	}
