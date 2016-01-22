 part of stagexl_gaf;


	/**
	 * @
	 */
	 class GAFTexture implements IGAFTexture
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

		 String _id;
		 Texture _texture;
		 Matrix _pivotMatrix;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 GAFTexture(String id,Texture texture,Matrix pivotMatrix)
		{
			this._id = id;
			this._texture = texture;
			this._pivotMatrix = pivotMatrix;
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------
		  void copyFrom(IGAFTexture newTexture)
		{
			if (newTexture is GAFTexture)
			{
				this._id = newTexture.id;
				this._texture = newTexture.texture;
				this._pivotMatrix.copyFrom(newTexture.pivotMatrix);
			}
			else
			{
				throw new StateError("Incompatiable types GAFexture and "+getQualifiedTypeName(newTexture));
			}
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

		  Texture get texture
		{
			return this._texture;
		}

		  Matrix get pivotMatrix
		{
			return this._pivotMatrix;
		}

		  String get id
		{
			return this._id;
		}

		  IGAFTexture clone()
		{
			return new GAFTexture(this._id, this._texture, this._pivotMatrix.clone());
		}
	}
