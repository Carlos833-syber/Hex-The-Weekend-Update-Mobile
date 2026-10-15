package;

/** Tracks fingers independently so releasing one finger never releases another's hold. */
class MobileTouchState
{
	var fingers:Map<Int, Int> = new Map();
	var counts:Map<Int, Int> = new Map();
	var emit:Int->Bool->Void;

	public function new(emit:Int->Bool->Void)
	{
		this.emit = emit;
	}

	public function contains(id:Int):Bool
	{
		return fingers.exists(id);
	}

	public function held(key:Int):Bool
	{
		return counts.exists(key);
	}

	public function move(id:Int, key:Int):Void
	{
		if (fingers.exists(id) && fingers.get(id) == key)
			return;
		end(id);
		fingers.set(id, key);
		if (key < 0)
			return;
		var count = counts.exists(key) ? counts.get(key) : 0;
		counts.set(key, count + 1);
		if (count == 0)
			emit(key, true);
	}

	public function end(id:Int):Void
	{
		if (!fingers.exists(id))
			return;
		var key = fingers.get(id);
		fingers.remove(id);
		if (key < 0)
			return;
		var count = counts.get(key) - 1;
		if (count == 0)
		{
			counts.remove(key);
			emit(key, false);
		}
		else
			counts.set(key, count);
	}

	public function clear():Void
	{
		var keys = [for (key in counts.keys()) key];
		fingers.clear();
		counts.clear();
		for (key in keys)
			emit(key, false);
	}
}
