 part of stagexl_gaf;
	/**
	 * @
	 */
	 class CAnimationObjects
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

		 Map _animationObjectsMap;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 CAnimationObjects()
		{
			this._animationObjectsMap = {};
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		  void addAnimationObject(CAnimationObject animationObject)
		{
			if (!this._animationObjectsMap[animationObject.instanceID])
			{
				this._animationObjectsMap[animationObject.instanceID] = animationObject;
			}
		}

		  CAnimationObject getAnimationObject(String instanceID)
		{
			if (this._animationObjectsMap[instanceID])
			{
				return this._animationObjectsMap[instanceID];
			}
			else
			{
				return null;
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

		  Map get animationObjectsMap
		{
			return this._animationObjectsMap;
		}

	}
