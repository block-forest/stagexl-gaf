/**
 * Created by Nazar on 27.11.2014.
 */
part of stagexl_gaf;

	 class SequencePlaybackInfo
	{
		 String _name;
		 bool _looped;

	 SequencePlaybackInfo(String name,bool looped)
		{
			_name = name;
			_looped = looped;
		}

		  String get name
		{
			return _name;
		}

		  bool get looped
		{
			return _looped;
		}
	}
