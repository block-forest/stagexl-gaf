/**
 * Created by Nazar on 27.11.2014.
 */

part of stagexl_gaf;

	 class SlotMachine extends GAFMovieClip
	{
		 static final int MACHINE_STATE_INITIAL = 0;
		 static final int MACHINE_STATE_ARM_TOUCHED = 1;
		 static final int MACHINE_STATE_SPIN = 2;
		 static final int MACHINE_STATE_SPIN_END = 3;
		 static final int MACHINE_STATE_WIN = 4;
		 static final int MACHINE_STATE_END = 5;
		 static final int MACHINE_STATE_COUNT = 6;

		 static final int PRIZE_NONE = 0;
		 static final int PRIZE_C1K = 1;
		 static final int PRIZE_C500K = 2;
		 static final int PRIZE_C1000K = 3;
		 static final int PRIZE_COUNT = 4;

		 static final String REWARD_COINS = "coins";
		 static final String REWARD_CHIPS = "chips";
		 static final int FRUIT_COUNT = 5;
		 static final num BAR_TIMEOUT = 0.2;

		 GAFMovieClip _arm;
		 GAFMovieClip _switchMachineBtn;
		 GAFMovieClip _whiteBG;
		 GAFMovieClip _rewardText;
		 GAFMovieClip _bottomCoins;
		 List<GAFMovieClip> _centralCoins;
		 GAFMovieClip _winFrame;
		 GAFMovieClip _spinningRays;
		 List<SlotBar> _bars;

		 int _state;
		 String _rewardType;

		// List<int> _prizeSequence;
		 int _prize;

		 Timer _timer;
	 SlotMachine(GAFTimeline gafTimeline): super(gafTimeline) 
		{
			play(true);

			_state = MACHINE_STATE_INITIAL;
			_rewardType = REWARD_CHIPS;

			//_prizeSequence = new <int>[PRIZE_C1000K, PRIZE_NONE, PRIZE_C1000K, PRIZE_C1K, PRIZE_C1000K, PRIZE_C500K];
			_prize = 0;

			_centralCoins = new List<GAFMovieClip>(3, true);
			_bars = new List<SlotBar>(3, true);

			_timer = new Timer(0, 1);
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);

			// Here we get pointers to inner Gaf objects for quick access
			// We use flash object instance name
			_arm = this.obj.arm;
			_switchMachineBtn = this.obj.swapBtn;
			_switchMachineBtn.stop();
			_switchMachineBtn.touchGroup = true;
			_whiteBG = this.obj.white_exit;
			_bottomCoins = this.obj.wincoins;
			_rewardText = this.obj.wintext;
			_winFrame = this.obj.frame;
			_spinningRays = this.obj.spinning_rays;

			// Sequence "start" will play once and callback SlotMachine::onFinishRaysSequence
			// will be called when last frame of "start" sequence shown
			_spinningRays.setSequence("start");
			_spinningRays.addEventListener(GAFMovieClip.EVENT_TYPE_SEQUENCE_END, onFinishRaysSequence);

			int i;
			int l = this.obj.numChildren;
			for (i = 0; i < l; i++)
			{
				DisplayObject child = this.obj.getChildAt(i);
				if (child != _arm && child != _switchMachineBtn)
				{
					child.touchable = false;
				}
			}

			l = _centralCoins.length;
			for (i = 0; i < l; i++)
			{
				int prize = i + 1;
				_centralCoins[i] = this.obj[getTextByPrize(prize)];
			}

			l = _bars.length;
			String barName;
			for (i = 0; i < l; i++)
			{
				barName = "slot" + (i + 1);

				_bars[i] = new SlotBar(this.obj[barName]);
				_bars[i].randomizeSlots(FRUIT_COUNT, _rewardType);
			}

			defaultPlacing();
		}

		  GAFMovieClip getArm()
		{
			return _arm;
		}

		  GAFMovieClip getSwitchMachineBtn()
		{
			return _switchMachineBtn;
		}

		  void start()
		{
			if (_state == MACHINE_STATE_INITIAL)
			{
				nextState();
			}
		}

		// General callback for sequences
		// Used by Finite-state machine
		// see setAnimationStartedNextLoopDelegate and setAnimationFinishedPlayDelegate
		// for looped and non-looped sequences
		  void onFinishSequence(Event event)
		{
			nextState();
		}

		  void onTimerComplete(TimerEvent event)
		{
			nextState();
		}

		  void onFinishRaysSequence(Event event)
		{
			_spinningRays.removeEventListener(GAFMovieClip.EVENT_TYPE_SEQUENCE_END, onFinishRaysSequence);
			_spinningRays.setSequence("spin", true);
		}

		  void switchType()
		{
			if (_rewardType == REWARD_CHIPS)
			{
				_rewardType = REWARD_COINS;
			}
			else if (_rewardType == REWARD_COINS)
			{
				_rewardType = REWARD_CHIPS;
			}

			int state = _state - 1;
			if (state < 0)
			{
				state = MACHINE_STATE_COUNT - 1;
			}
			_state = state;
			nextState();

			int l = _bars.length;
			for (int i = 0; i < l; i++)
			{
				_bars[i].switchSlotType(FRUIT_COUNT);
			}
		}

		  void defaultPlacing()
		{
			// Here we set default sequences if needed
			// Sequence names are used from flash labels
			_whiteBG.gotoAndStop("whiteenter");
			_winFrame.setSequence("stop");
			_arm.setSequence("stop");
			_bottomCoins.visible = false;
			_bottomCoins.loop = false;
			_rewardText.setSequence("notwin", true);

			int i;
			int l = _centralCoins.length;
			for (i = 0; i < l; i++)
			{
				_centralCoins[i].visible = false;
			}
			l = _bars.length;
			for (i = 0; i < l; i++)
			{
				_bars[i].getBar().setSequence("statics");
			}
		}

		/* This method describes Finite-state machine
		 * state switches in 2 cases: dynamic 1) specific sequence ended playing and callback called
		 * 2) by timer
		 */
		  void nextState()
		{
			++_state;
			if (_state == MACHINE_STATE_COUNT)
			{
				_state = MACHINE_STATE_INITIAL;
			}
			resetCallbacks();

			int i;
			int l;
			SequencePlaybackInfo sequence;
			switch (_state)
			{
				case MACHINE_STATE_INITIAL:
					defaultPlacing();
					break;

				case MACHINE_STATE_ARM_TOUCHED:
					_arm.setSequence("push");
					_arm.addEventListener(GAFMovieClip.EVENT_TYPE_SEQUENCE_END, onFinishSequence);
					break;

				case MACHINE_STATE_SPIN:
					_arm.setSequence("stop");
					_timer.reset();
					_timer.delay = 3000;
					_timer.start();
					l = _bars.length;
					String seqName;
					for (i = 0; i < l; i++)
					{
						seqName = "rotation_" + _rewardType;
						sequence = new SequencePlaybackInfo(seqName, true);
						_bars[i].playSequenceWithTimeout(sequence, BAR_TIMEOUT * i * 1000);
					}
					break;

				case MACHINE_STATE_SPIN_END:
					_timer.reset();
					_timer.delay = BAR_TIMEOUT * 4 * 1000;
					_timer.start();
					/*_prize = */
					generatePrize();
					List<List<int>> spinResult = generateSpinResult(_prize);
					l = _bars.length;
					for (i = 0; i < l; i++)
					{
						_bars[i].setSpinResult(spinResult[i], _rewardType);
						sequence = new SequencePlaybackInfo("stop", false);
						_bars[i].playSequenceWithTimeout(sequence, BAR_TIMEOUT * i * 1000);
					}
					break;

				case MACHINE_STATE_WIN:
					showPrize(_prize);
					break;

				case MACHINE_STATE_END:
					_whiteBG.play();
					_whiteBG.addEventListener(GAFMovieClip.EVENT_TYPE_SEQUENCE_END, onFinishSequence);
					break;

				default:
					break;
			}
		}

		  void resetCallbacks()
		{
			_whiteBG.removeEventListener(GAFMovieClip.EVENT_TYPE_SEQUENCE_END, onFinishSequence);
			_arm.removeEventListener(GAFMovieClip.EVENT_TYPE_SEQUENCE_END, onFinishSequence);
		}

		  int generatePrize()
		{
			++_prize;
			if (_prize == PRIZE_COUNT)
			{
				_prize = 0;
			}

			return _prize;
		}

		/* Method returns machine spin result
		 *        4 3 1
		 *        2 2 2
		 *        1 1 5
		 * where numbers are fruit indexes
		 */
		  List<List<int>> generateSpinResult(int prize)
		{
			int l = 3;
			List<List<int>> result = new List<List<int>>(l, true);
			int i;
			for (i = 0; i < l; i++)
			{
				result[i] = new List<int>(l);
				result[i][0] = (new Random().nextDouble() * FRUIT_COUNT).floor() + 1;
				result[i][2] = (new Random().nextDouble() * FRUIT_COUNT).floor() + 1;
			}

			int centralFruit;
			switch (prize)
			{
				case PRIZE_NONE:
					centralFruit = (new Random().nextDouble() * FRUIT_COUNT).floor() + 1;
					break;
				case PRIZE_C1K:
					centralFruit = (new Random().nextDouble() * (FRUIT_COUNT / 2)).floor() + 1;
					break;
				case PRIZE_C500K:
					centralFruit = (new Random().nextDouble() * (FRUIT_COUNT / 2)).floor() + FRUIT_COUNT / 2 + 1;
					break;
				case PRIZE_C1000K:
					centralFruit = FRUIT_COUNT - 1;
					break;
				default:
					break;
			}

			if (prize == PRIZE_NONE)
			{
				result[0][1] = centralFruit;
				result[1][1] = centralFruit;
				result[2][1] = centralFruit;
				while (result[2][1] == result[1][1])
				{
					result[2][1] = (new Random().nextDouble() * FRUIT_COUNT).floor() + 1; // last fruit should be another
				}
			}
			else
			{
				for (i = 0; i < l; i++)
				{
					result[i][1] = centralFruit;
				}
			}

			return result;
		}

		// Here we switching to win animation
		  void showPrize(int prize)
		{
			String coinsBottomState = getTextByPrize(prize) + "_" + _rewardType;
			_bottomCoins.visible = true;
			_bottomCoins.gotoAndStop(coinsBottomState);

			if (prize == PRIZE_NONE)
			{
				nextState();
				return;
			}

			_winFrame.setSequence("win", true);
			_rewardText.setSequence(getTextByPrize(prize));

			int idx = prize - 1;
			_centralCoins[idx].visible = true;
			_centralCoins[idx].play(true);
			_centralCoins[idx].setSequence(_rewardType);

			_timer.reset();
			_timer.delay = 2000;
			_timer.start();

		}

		  String getTextByPrize(int prize)
		{
			switch (prize)
			{
				case PRIZE_NONE:
					return "notwin";

				case PRIZE_C1K:
					return "win1k";

				case PRIZE_C500K:
					return "win500k";

				case PRIZE_C1000K:
					return "win1000k";

				default:
					return "";
			}
		}
	}
