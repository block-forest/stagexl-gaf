 part of stagexl_gaf;

	/**
	 * @
	 */
	 class CAnimationFrameInstance
	{
		// --------------------------------------------------------------------------
		//
		// PUBLIC VARIABLES
		//
		// --------------------------------------------------------------------------
		// --------------------------------------------------------------------------
		//
		// PRIVATE VARIABLES
		//
		// --------------------------------------------------------------------------
		 String _id;
		 int _zIndex;
		 Matrix _matrix;
		 num _alpha;
		 String _maskID;
		 CFilter _filter;

		 static num tx, ty;

		// --------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		// --------------------------------------------------------------------------
	 CAnimationFrameInstance(String id)
		{
			this._id = id;
		}

		// --------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		// --------------------------------------------------------------------------
		  CAnimationFrameInstance clone()
		{
			CAnimationFrameInstance result = new CAnimationFrameInstance(this._id);

			CFilter filterCopy = null;

			if (this._filter)
			{
				filterCopy = this._filter.clone();
			}

			result.update(this._zIndex, this._matrix.clone(), this._alpha, this._maskID, filterCopy);

			return result;
		}

		  void update(int zIndex,Matrix matrix,num alpha,String maskID,CFilter filter)
		{
			this._zIndex = zIndex;
			this._matrix = matrix;
			this._alpha = alpha;
			this._maskID = maskID;
			this._filter = filter;
		}

		  Matrix getTransformMatrix(Matrix pivotMatrix,num scale)
		{
			Matrix result = pivotMatrix.clone();
			tx = this._matrix.tx;
			ty = this._matrix.ty;
			this._matrix.tx *= scale;
			this._matrix.ty *= scale;
			result.concat(this._matrix);
			this._matrix.tx = tx;
			this._matrix.ty = ty;

			return result;
		}

		  void applyTransformMatrix(Matrix transformationMatrix,Matrix pivotMatrix,num scale)
		{
			transformationMatrix.copyFrom(pivotMatrix);
			tx = this._matrix.tx;
			ty = this._matrix.ty;
			this._matrix.tx *= scale;
			this._matrix.ty *= scale;
			transformationMatrix.concat(this._matrix);
			this._matrix.tx = tx;
			this._matrix.ty = ty;
		}

		  Matrix calculateTransformMatrix(Matrix transformationMatrix,Matrix pivotMatrix,num scale)
		{
			applyTransformMatrix(transformationMatrix, pivotMatrix, scale);
			return transformationMatrix;
		}

		// --------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		// --------------------------------------------------------------------------
		// --------------------------------------------------------------------------
		//
		// OVERRIDDEN METHODS
		//
		// --------------------------------------------------------------------------
		// --------------------------------------------------------------------------
		//
		// EVENT HANDLERS
		//
		// --------------------------------------------------------------------------
		// --------------------------------------------------------------------------
		//
		// GETTERS AND SETTERS
		//
		// --------------------------------------------------------------------------
		  String get id
		{
			return this._id;
		}

		  Matrix get matrix
		{
			return this._matrix;
		}

		  num get alpha
		{
			return this._alpha;
		}

		  String get maskID
		{
			return this._maskID;
		}

		  CFilter get filter
		{
			return this._filter;
		}

		  int get zIndex
		{
			return this._zIndex;
		}
	}
