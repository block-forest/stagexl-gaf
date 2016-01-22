 part of stagexl_gaf;
	/**
	 * Data object that describe sequence
	 */
	 class CAnimationSequence
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
		 int _startFrameNo;
		 int _endFrameNo;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------

		/**
		 * @
		 */
	 CAnimationSequence(String id,int startFrameNo,int endFrameNo)
		{
			this._id = id;
			this._startFrameNo = startFrameNo;
			this._endFrameNo = endFrameNo;
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		/**
		 * @
		 */
		  bool isSequenceFrame(int frameNo)
		{
			// first frame is "1" !!!

			if (frameNo >= this._startFrameNo && frameNo <= this._endFrameNo)
			{
				return true;
			}
			else
			{
				return false;
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

		/**
		 * Sequence ID
		 * @return Sequence ID
		 */
		  String get id
		{
			return this._id;
		}

		/**
		 * Sequence start frame number
		 * @return Sequence start frame number
		 */
		  int get startFrameNo
		{
			return this._startFrameNo;
		}

		/**
		 * Sequence end frame number
		 * @return Sequence end frame number
		 */
		  int get endFrameNo
		{
			return this._endFrameNo;
		}

	}
