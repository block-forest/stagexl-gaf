 part of stagexl_gaf;
	/**
	 * @
	 */
	 class CAnimationSequences
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

		 List<CAnimationSequence> _sequences;

		 Map _sequencesStartMap;
		 Map _sequencesEndMap;

		//--------------------------------------------------------------------------
		//
		//  CONSTRUCTOR
		//
		//--------------------------------------------------------------------------
	 CAnimationSequences()
		{
			this._sequences = new List<CAnimationSequence>();

			this._sequencesStartMap = {};
			this._sequencesEndMap = {};
		}

		//--------------------------------------------------------------------------
		//
		//  PUBLIC METHODS
		//
		//--------------------------------------------------------------------------

		  void addSequence(CAnimationSequence sequence)
		{
			this._sequences.add(sequence);

			if (!this._sequencesStartMap[sequence.startFrameNo])
			{
				this._sequencesStartMap[sequence.startFrameNo] = sequence;
			}

			if (!this._sequencesEndMap[sequence.endFrameNo])
			{
				this._sequencesEndMap[sequence.endFrameNo] = sequence;
			}
		}

		  CAnimationSequence getSequenceStart(int frameNo)
		{
			return this._sequencesStartMap[frameNo];
		}

		  CAnimationSequence getSequenceEnd(int frameNo)
		{
			return this._sequencesEndMap[frameNo];
		}

		  int getStartFrameNo(String sequenceID)
		{
			int result = 0;

			for(CAnimationSequence sequence in this._sequences)
			{
				if (sequence.id == sequenceID)
				{
					return sequence.startFrameNo;
				}
			}

			return result;
		}

		  CAnimationSequence getSequenceByID(String id)
		{
			for(CAnimationSequence sequence in this._sequences)
			{
				if (sequence.id == id)
				{
					return sequence;
				}
			}

			return null;
		}

		  CAnimationSequence getSequenceByFrame(int frameNo)
		{
			for (int i = 0; i < this._sequences.length; i++)
			{
				if (this._sequences[i].isSequenceFrame(frameNo))
				{
					return this._sequences[i];
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

		  List<CAnimationSequence> get sequences
		{
			return this._sequences;
		}

	}
