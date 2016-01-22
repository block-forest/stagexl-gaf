 part of stagexl_gaf;

	/**
	 * @author Ivan Avdeenko
	 * @
	 */
	 class GAFSoundChannel extends EventDispatcher
	{
		 SoundChannel _soundChannel;
		 int _soundID;
		 String _swfName;
	 GAFSoundChannel(String swfName,int soundID)
		{
			this._swfName = swfName;
			this._soundID = soundID;
		}

		  void stop()
		{
			this._soundChannel.stop();
		}

		  SoundChannel get soundChannel
		{
			return this._soundChannel;
		}

		  void set soundChannel(SoundChannel soundChannel)
		{
			if (this._soundChannel)
			{
				this._soundChannel.removeEventListener(Event.SOUND_COMPLETE, onComplete);
			}
			this._soundChannel = soundChannel;
			this._soundChannel.addEventListener(Event.SOUND_COMPLETE, onComplete);
		}

		  void onComplete(Event event)
		{
			this.dispatchEvent(event);
		}

		  int get soundID
		{
			return this._soundID;
		}

		  String get swfName
		{
			return this._swfName;
		}
	}
