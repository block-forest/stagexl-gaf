 part of stagexl_gaf;
	/**
	 * @
	 */
	 class MathUtility
	{
		 static final num epsilon = 0.00001;

		 static final num PI_Q = PI / 4.0;

		[Inline]
		 static  bool equals(num a,num b)
		{
			if (isNaN(a) || isNaN(b))
			{
				return false;
			}
			return (a - b).abs() < epsilon;
		}

		 static  int getItemIndex(List<num> source,num target)
		{
			for (int i = 0; i < source.length; i++)
			{
				if (equals(source[i], target))
				{
					return i;
				}
			}
			return -1;
		}
	}
