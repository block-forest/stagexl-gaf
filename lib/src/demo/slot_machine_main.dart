/**
 * Created by Nazar on 27.11.2014.
 */

part of stagexl_gaf;

	//[SWF(backgroundColor="#FFFFFF", frameRate="60", width="432", height="768")]
	 class SlotMachineMain extends Sprite
	{
		 Starling _starling;
	 SlotMachineMain()
		{
			_starling = new Starling(SlotMachineGame, stage, new Rectangle(0, 0, 432, 768));
			_starling.showStats = true;
       		_starling.start();
		}
	}
