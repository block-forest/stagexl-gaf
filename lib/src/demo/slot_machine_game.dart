/**
 * Created by Nazar on 27.11.2014.
 */

part of stagexl_gaf;

	 class SlotMachineGame extends Sprite
	{
		 SlotMachine _machine;

		//[Embed(source="../design/slot_machine_design.zip", mimeType="application/octet-stream")]
		 const Type SlotMachineZip;
	 SlotMachineGame()
		{
			ByteList zip = new SlotMachineZip();

			ZipToGAFAssetConverter converter = new ZipToGAFAssetConverter();
			converter.addEventListener(Event.COMPLETE, this.onConverted);
			converter.addEventListener(ErrorEvent.ERROR, this.onError);
			converter.convert(zip);
		}

		  void onConverted(Event event)
		{
			GAFTimeline timeline = (event.target as ZipToGAFAssetConverter).gafBundle.getGAFTimeline("slot_machine_design", "rootTimeline");

			_machine = new SlotMachine(timeline);

			this.addChild(_machine);

			_machine.play();

			_machine.getArm().addEventListener(TouchEvent.TOUCH, onArmTouched);
			_machine.getSwitchMachineBtn().addEventListener(TouchEvent.TOUCH, onSwitchMachineBtnTouched);
		}

		  void onArmTouched(TouchEvent event)
		{
			Touch touch = event.getTouch(_machine.getArm());
			if( touch != null || touch == true)
			{
				if (touch.phase == TouchPhase.ENDED)
				{
					_machine.start();
				}
			}
		}

		  void onSwitchMachineBtnTouched(TouchEvent event)
		{
			Touch touch = event.getTouch(_machine.getSwitchMachineBtn());
			if( touch != null || touch == true)
			{
				if (touch.phase == TouchPhase.HOVER)
				{
					_machine.getSwitchMachineBtn().setSequence("Over");
				}
				else if (touch.phase == TouchPhase.BEGAN)
				{
					_machine.getSwitchMachineBtn().setSequence("Down");
				}
				else if (touch.phase == TouchPhase.ENDED)
				{
					_machine.getSwitchMachineBtn().setSequence("Up");
					_machine.switchType();
				}
				else
				{
					_machine.getSwitchMachineBtn().setSequence("Up");
				}
			}
		}

		  void onError(ErrorEvent event)
		{
			print(event);
		}
	}
