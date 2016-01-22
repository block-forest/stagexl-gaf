 part of stagexl_gaf;


	/**
	 * @author Ivan Avdeenko
	 */

	/**
	 * The <code>GAFSoundManager</code> provides an abstract class to control GAF sound playback.
	 * All adjustments made through <code>GAFSoundManager</code> affects all GAF sounds.
	 */
	 class GAFSoundManager
	{
		 num volume = 1;
		 Map soundChannels;
		 static GAFSoundManager _getInstance;

		/**
		 * @
		 * @param singleton
		 */
	 GAFSoundManager(Singleton singleton)
		{
			if( singleton == null || singleton == false)
			{
				throw new StateError("GAFSoundManager is Singleton. Use GAFSoundManager.instance or GAF.soundManager instead");
			}
		}

		/**
		 * The volume of the GAF sounds, ranging from 0 (to as silent) 1 (full volume).
		 * @param volume the volume of the sound
		 */
		  void setVolume(num volume)
		{
			this.volume = volume;

			List<GAFSoundChannel> channels;
			for (String swfName in soundChannels)
			{
				for (String soundID in soundChannels[swfName])
				{
					channels = soundChannels[swfName][soundID];
					for (int i = 0; i < channels.length; i++)
					{
						channels[i].soundChannel.soundTransform = new SoundTransform(volume);
					}
				}
			}
		}

		/**
		 * Stops all GAF sounds currently playing
		 */
		  void stopAll()
		{
			List<GAFSoundChannel> channels;
			for (String swfName in soundChannels)
			{
				for (String soundID in soundChannels[swfName])
				{
					channels = soundChannels[swfName][soundID];
					for (int i = 0; i < channels.length; i++)
					{
						channels[i].stop();
					}
				}
			}
			soundChannels = null;
		}

		/**
		 * @
		 * @param sound
		 * @param soundID
		 * @param soundOptions
		 * @param swfName
		 */
		 void play(Sound sound,int soundID,Object soundOptions,String swfName)
		{
			if (soundOptions["continue"]
			&&  soundChannels
			&&  soundChannels[swfName]
			&&  soundChannels[swfName][soundID])
			{
				return; //sound already in play - no need to launch it again
			}
			GAFSoundChannel soundData = new GAFSoundChannel(swfName, soundID);
			soundData.soundChannel = sound.play(0, soundOptions["repeatCount"], new SoundTransform(this.volume));
			soundData.addEventListener(Event.SOUND_COMPLETE, onSoundPlayEnded);
			(soundChannels != null) ? soundChannels :soundChannels =  {};
			soundChannels[swfName] ??= {};
			soundChannels[swfName][soundID] ??= new <GAFSoundChannel>[];
			List<GAFSoundChannel>(soundChannels[swfName][soundID]).add(soundData);
		}

		/**
		 * @
		 * @param soundID
		 * @param swfName
		 */
		 void stop(int soundID,String swfName)
		{
			if (soundChannels
			&&  soundChannels[swfName]
			&&  soundChannels[swfName][soundID])
			{
				List<GAFSoundChannel> channels = soundChannels[swfName][soundID];
				for (int i = 0; i < channels.length; i++)
				{
					channels[i].stop();
				}
				soundChannels[swfName][soundID] = null;
				delete soundChannels[swfName][soundID];
			}
		}

		/**
		 * @
		 * @param event
		 */
		  void onSoundPlayEnded(Event event)
		{
			GAFSoundChannel soundChannel = event.target as GAFSoundChannel;
			soundChannel.removeEventListener(Event.SOUND_COMPLETE, onSoundPlayEnded);

			soundChannels[soundChannel.swfName][soundChannel.soundID] = null;
			delete soundChannels[soundChannel.swfName][soundChannel.soundID];
		}

		/**
		 * The instance of the <code>GAFSoundManager</code> (singleton)
		 * @return The instance of the <code>GAFSoundManager</code>
		 */
		 static  GAFSoundManager getInstance()
		{
			(_getInstance != null) ? _getInstance :_getInstance =  new GAFSoundManager(new Singleton());
			return _getInstance;
		}
	}
}
/** @ */
internal class Singleton
{
