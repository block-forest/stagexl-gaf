 part of stagexl_gaf;
	/**
	 * @
	 */
	 class CAnimationFrame
	{
		// --------------------------------------------------------------------------
		//
		// PUBLIC VARIABLES
		//
		// --------------------------------------------------------------------------
		// --------------------------------------------------------------------------
		//
		// PRIVATE VARIABLES
		//
		// --------------------------------------------------------------------------
		 Map _instancesMap;
		 List<CAnimationFrameInstance> _instances;
		 List<CFrameAction> _actions;

		 int _framenum;

		// --------------------------------------------------------------------------
		//
		// CONSTRUCTOR
		//
		// --------------------------------------------------------------------------
	 CAnimationFrame(int framenum)
		{
			this._framenum = framenum;

			this._instancesMap = {};
			this._instances = new List<CAnimationFrameInstance>();
		}

		// --------------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		// --------------------------------------------------------------------------
		  CAnimationFrame clone(int framenum)
		{
			CAnimationFrame result = new CAnimationFrame(framenum);

			for (CAnimationFrameInstance instance in this._instances)
			{
				result.addInstance(instance);
				// .clone());
			}

			return result;
		}

		  void addInstance(CAnimationFrameInstance instance)
		{
			if (this._instancesMap[instance.id])
			{
				if (instance.alpha)
				{
					this._instances[this._instances.indexOf(this._instancesMap[instance.id])] = instance;

					this._instancesMap[instance.id] = instance;
				}
				else
				{
					// Poping the last element and set it as the removed element
					int index = this._instances.indexOf(this._instancesMap[instance.id]);
					// If index is last element, just pop
					if (index == (this._instances.length - 1))
					{
						this._instances.pop();
					}
					else
					{
						this._instances[index] = this._instances.pop();
					}

					this._instancesMap.remove(instance.id);
				}
			}
			else
			{
				this._instances.add(instance);

				this._instancesMap[instance.id] = instance;
			}
		}

		  void addAction(CFrameAction action)
		{
			(_actions != null) ? _actions :_actions =  new List<CFrameAction>();
			_actions.add(action);
		}

		  void sortInstances()
		{
			this._instances.sort(this.sortByZIndex);
		}

		  CAnimationFrameInstance getInstanceByID(String id)
		{
			return this._instancesMap[id];
		}

		// --------------------------------------------------------------------------
		//
		// PRIVATE METHODS
		//
		// --------------------------------------------------------------------------
		  num sortByZIndex(CAnimationFrameInstance instance1,CAnimationFrameInstance instance2)
		{
			if (instance1.zIndex < instance2.zIndex)
			{
				return -1;
			}
			else if (instance1.zIndex > instance2.zIndex)
			{
				return 1;
			}
			else
			{
				return 0;
			}
		}

		// --------------------------------------------------------------------------
		//
		// OVERRIDDEN METHODS
		//
		// --------------------------------------------------------------------------
		// --------------------------------------------------------------------------
		//
		// EVENT HANDLERS
		//
		// --------------------------------------------------------------------------
		// --------------------------------------------------------------------------
		//
		// GETTERS AND SETTERS
		//
		// --------------------------------------------------------------------------
		  List<CAnimationFrameInstance> get instances
		{
			return this._instances;
		}

		  int get framenum
		{
			return this._framenum;
		}
		  List<CFrameAction> get actions
		{
			return this._actions;
		}
	}
