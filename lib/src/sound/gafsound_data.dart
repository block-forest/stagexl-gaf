 part of stagexl_gaf;

	/** @
	 * @author Ivan Avdeenko
	 * @
	 */
	 class GAFSoundData
	{
		 Function onFail;
		 Function onSuccess;
		 Map _sounds;
		 List<CSound> _soundQueue;

		  Sound getSoundByLinkage(String linkage)
		{
			if (this._sounds != null)
			{
				return this._sounds[linkage];
			}
			return null;
		}

		 void addSound(CSound soundData,String swfName,ByteList soundBytes)
		{
			Sound sound = new Sound();
			if( soundBytes != null || soundBytes == true)
			{
				if (soundBytes.position > 0)
				{
					soundData.sound = this._sounds[soundData.linkageName];
					return;
				}
				else
				{
					sound.loadCompressedDataFromByteArray(soundBytes, soundBytes.length);
				}
			}
			else
			{
		 		this._soundQueue ??= new List<CSound>();
		 		this._soundQueue.add(soundData);
			}

			soundData.sound = sound;

			this._sounds ??= {};
			if (soundData.linkageName.length > 0)
			{
				this._sounds[soundData.linkageName] = sound;
			}
			else
			{
				this._sounds[swfName] ??= {};
				this._sounds[swfName][soundData.soundID] = sound;
			}
		}

		 Sound getSound(int soundID,String swfName)
		{
			if (this._sounds != null)
			{
				return this._sounds[swfName][soundID];
			}
			return null;
		}

		 void loadSounds(Function onSuccess,Function onFail)
		{
			this.onSuccess = onSuccess;
			this.onFail = onFail;
			this.loadSound();
		}

		 void dispose()
		{
			for (Sound sound in this._sounds)
			{
				sound.close();
			}
		}

		  void loadSound()
		{
			CSound soundDataConfig = _soundQueue.pop();
			with (soundDataConfig.sound)
			{
				addEventListener(Event.COMPLETE, onSoundLoaded);
				addEventListener(IOErrorEvent.IO_ERROR, onError);
				load(new URLRequest(soundDataConfig.source));
			}
		}

		  void onSoundLoaded(Event event)
		{
			this.removeListeners(event);

			if (this._soundQueue.length > 0)
			{
				this.loadSound();
			}
			else
			{
				this.onSuccess();
				this.onSuccess = null;
				this.onFail = null;
			}
		}

		  void onError(IOErrorEvent event)
		{
			this.removeListeners(event);
			this.onFail(event);
			this.onFail = null;
			this.onSuccess = null;
		}

		  void removeListeners(Event event)
		{
			Sound sound = event.target as Sound;
			sound.removeEventListener(Event.COMPLETE, onSoundLoaded);
			sound.removeEventListener(IOErrorEvent.IO_ERROR, onError);
		}

		 bool get hasSoundsToLoad
		{
			return this._soundQueue != null && this._soundQueue.length > 0;
		}
	}
