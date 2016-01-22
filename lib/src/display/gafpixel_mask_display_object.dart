 part of stagexl_gaf;



	/**
	 * @
	 */
	 class GAFPixelMaskDisplayObject extends DisplayObjectContainer
	{
		 static final String MASK_MODE = "mask";

		 static final int PADDING = 1;

		 static final Rectangle sHelperRect = new Rectangle();

		 DisplayObject _mask;

		 RenderTexture _renderTexture;
		 RenderTexture _maskRenderTexture;

		 Image _image;
		 Image _maskImage;

		 bool _superRenderFlag = false;

		 Point _maskSize;
		 bool _staticMaskSize;
		 num _scaleFactor;

		 bool _mustReorder;
	 GAFPixelMaskDisplayObject([num scaleFactor=-1])
		{
			this._scaleFactor = scaleFactor;
			this._maskSize = new Point(0,0);

			BlendMode.register(MASK_MODE, Context3DBlendFactor.ZERO, Context3DBlendFactor.SOURCE_ALPHA);

			// Handle lost context. By using the conventional event, we can make a weak listener.
			// This avoids memory leaks when people forget to call "dispose" on the object.
			Starling.current.stage3D.addEventListener(Event.CONTEXT3D_CREATE,
					this.onContextCreated, false, 0, true);
		}

		@override 
		  void dispose()
		{
			this.clearRenderTextures();
			Starling.current.stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			super.dispose();
		}

		  void onContextCreated(Object event)
		{
			this.refreshRenderTextures();
		}

		  void set pixelMask(DisplayObject value)
		{
			// clean up existing mask if there is one
			if (this._mask)
			{
				this._mask = null;
				this._maskSize.setTo(0, 0);
			}

			if( value != null || value == true)
			{
				this._mask = value;

				if (this._mask.width == 0 || this._mask.height == 0)
				{
					throw new StateError("Mask must have dimensions. Current dimensions are " + this._mask.width + "x" + this._mask.height + ".");
				}

				IMaxSize objectWithMaxSize = this._mask as IMaxSize;
				if (objectWithMaxSize && objectWithMaxSize.maxSize)
				{
					this._maskSize.copyFrom(objectWithMaxSize.maxSize);
					this._staticMaskSize = true;
				}
				else
				{
					this._mask.getBounds(null, sHelperRect);
					this._maskSize.setTo(sHelperRect.width, sHelperRect.height);
					this._staticMaskSize = false;
				}

				this.refreshRenderTextures(null);
			}
			else
			{
				this.clearRenderTextures();
			}
		}

		  DisplayObject get pixelMask
		{
			return this._mask;
		}

		  void clearRenderTextures()
		{
			// clean up old render textures and images
			if (this._maskRenderTexture)
			{
				this._maskRenderTexture.dispose();
			}

			if (this._renderTexture)
			{
				this._renderTexture.dispose();
			}

			if (this._image)
			{
				this._image.dispose();
			}

			if (this._maskImage)
			{
				this._maskImage.dispose();
			}
		}

		  void refreshRenderTextures([Event event=null])
		{
			if (Starling.current.contextValid)
			{
				if (this._mask)
				{
					this.clearRenderTextures();

					this._renderTexture = new RenderTexture(this._maskSize.x, this._maskSize.y, false, this._scaleFactor);
					this._maskRenderTexture = new RenderTexture(this._maskSize.x + PADDING * 2, this._maskSize.y + PADDING * 2, false, this._scaleFactor);

					// create image with the new render texture
					this._image = new Image(this._renderTexture);
					// create image to blit the mask onto
					this._maskImage = new Image(this._maskRenderTexture);
					this._maskImage.x = this._maskImage.y = -PADDING;
					// set the blending mode to MASK (ZERO, SRC_ALPHA)
					this._maskImage.blendMode = MASK_MODE;
				}
			}
		}

		@override 
		  void render(RenderSupport support,num parentAlpha)
		{
			if (this._superRenderFlag || !this._mask)
			{
				super.render(support, parentAlpha);
			}
			else if (this._mask != null)
			{
				int previousStencilRefValue = support.stencilReferenceValue;
				if (previousStencilRefValue != null) support.stencilReferenceValue = 0;

				_tx = this._mask.transformationMatrix.tx;
				_ty = this._mask.transformationMatrix.ty;

				this._mask.getBounds(null, sHelperRect);

				if (!this._staticMaskSize
							//&& (sHelperRect.width > this._maskSize.x || sHelperRect.height > this._maskSize.y)
						&& (sHelperRect.width != this._maskSize.x || sHelperRect.height != this._maskSize.y))
				{
					this._maskSize.setTo(sHelperRect.width, sHelperRect.height);
					this.refreshRenderTextures();
				}

				this._mask.transformationMatrix.tx = _tx - sHelperRect.x + PADDING;
				this._mask.transformationMatrix.ty = _ty - sHelperRect.y + PADDING;
				this._maskRenderTexture.draw(this._mask);
				this._image.transformationMatrix.tx = sHelperRect.x;
				this._image.transformationMatrix.ty = sHelperRect.y;
				this._mask.transformationMatrix.tx = _tx;
				this._mask.transformationMatrix.ty = _ty;

				this._renderTexture.drawBundled(this.drawRenderTextures);

				if (previousStencilRefValue != null) support.stencilReferenceValue = previousStencilRefValue;

				support.addMatrix();
				support.transformMatrix(this._image);
				this._image.render(support, parentAlpha);
				support.popMatrix();
			}
		}

		 static num _a;
		 static num _b;
		 static num _c;
		 static num _d;
		 static num _tx;
		 static num _ty;

		  void drawRenderTextures([DisplayObject object=null, Matrix matrix=null, num alpha=1.0])
		{
			_a = this.transformationMatrix.a;
			_b = this.transformationMatrix.b;
			_c = this.transformationMatrix.c;
			_d = this.transformationMatrix.d;
			_tx = this.transformationMatrix.tx;
			_ty = this.transformationMatrix.ty;

			this.transformationMatrix.copyFrom(this._image.transformationMatrix);
			this.transformationMatrix.invert();

			this._superRenderFlag = true;
			this._renderTexture.draw(this);
			this._superRenderFlag = false;

			this.transformationMatrix.a = _a;
			this.transformationMatrix.b = _b;
			this.transformationMatrix.c = _c;
			this.transformationMatrix.d = _d;
			this.transformationMatrix.tx = _tx;
			this.transformationMatrix.ty = _ty;

			//-----------------------------------------------------------------------------------------------------------------

			this._renderTexture.draw(this._maskImage);
		}

		  bool get mustReorder
		{
			return this._mustReorder;
		}

		  void set mustReorder(bool value)
		{
			this._mustReorder = value;
		}
	}
