/**
 * Created by Nazar on 27.11.2014.
 */
/****************************************************************************
 This is the helper class for Slot Machine reel

  / \
 | A |
 |---|
 | B |
 |---|
 | C |
  \ /

 http://gafmedia.com/
 ****************************************************************************/

part of stagexl_gaf;

	 class SlotBar
	{
		 GAFMovieClip _bar;
		 List<GAFMovieClip> _slots;
		 List<int> _spinResult;
		 String _machineType;

		 SequencePlaybackInfo _sequence;
		 Timer _timer;

		 SlotBar(GAFMovieClip slotBarMC)
		{
			if( slotBarMC == null || slotBarMC == false) throw new ArgumentError("Error: slotBarMC cannot be null");

			_bar = slotBarMC;
			_slots = new List<GAFMovieClip>(3, true);
			_timer = new Timer(0, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);

			String name;
			int l = _slots.length;
			for (int i = 0; i < l; i++)
			{
				name = "fruit" + (i + 1);
				//_slots[i] = _bar.getChildByName(as as name) GAFMovieClip;
				_slots[i] = _bar[name];

				if (!_slots[i])
					throw new Error("Cannot find slot movie.");
			}
		}

		  void playSequenceWithTimeout(SequencePlaybackInfo sequence,num timeout)
		{
			_sequence = sequence;
			_timer.reset();
			_timer.delay = timeout;
			_timer.start();
		}

		  void onTimerComplete(TimerEvent event)
		{
			_bar.loop = _sequence.looped;
			_bar.setSequence(_sequence.name);

			if (_sequence.name == "stop")
			{
				showSpinResult();
			}
		}

		  void randomizeSlots(int maxTypes,String machineType)
		{
			int l = _slots.length;
			int slotImagePos;
			String seqName;
			for (int i = 0; i < l; i++)
			{
				slotImagePos = (new Random().nextDouble() * maxTypes).floor() + 1;
				seqName = slotImagePos + "_" + machineType;
				_slots[i].setSequence(seqName, false);
			}
		}

		  void setSpinResult(List<int> fruits,String machineType)
		{
			_spinResult = fruits;
			_machineType = machineType;
		}

		  void showSpinResult()
		{
			int l = _slots.length;
			String seqName;
			for (int i = 0; i < l; i++)
			{
				seqName = (_spinResult[i]) + "_" + _machineType;
				_slots[i].setSequence(seqName, false);
			}
		}

		  void switchSlotType(int maxSlots)
		{
			int l = _slots.length;
			int curFrame;
			int maxFrame;
			for (int i = 0; i < l; i++)
			{
				curFrame = _slots[i].currentFrame - 1;
				maxFrame = _slots[i].totalFrames;
				curFrame += maxSlots;
				if (curFrame >= maxFrame)
				{
					curFrame = curFrame % maxSlots;
				}

				_slots[i].gotoAndStop(curFrame + 1);
			}
		}

		  GAFMovieClip getBar()
		{
			return _bar;
		}
	}
