class MobileTouchStateTest
{
	static function main()
	{
		var events:Array<String> = [];
		var state = new MobileTouchState((key, down) -> events.push(key + ":" + down));
		function expect(want:String)
		{
			var actual = events.join(",");
			if (actual != want)
				throw 'Expected $want, got $actual';
			events = [];
		}
		state.move(1, 37);
		state.move(2, 37);
		state.move(3, 40);
		expect("37:true,40:true"); // chord + two fingers sharing a lane
		state.end(1);
		expect(""); // second finger must keep the sustain held
		state.move(2, 38);
		expect("37:false,38:true"); // slide releases old lane before pressing new
		state.move(2, 38);
		expect(""); // movement within a lane cannot generate repeated hits
		state.end(3);
		expect("40:false");
		state.move(2, -1);
		expect("38:false"); // sliding outside active area
		state.move(2, 39);
		expect("39:true");
		state.clear();
		expect("39:false"); // pause, focus loss and screen changes release all keys
		if (state.contains(2) || state.held(39))
			throw "Clear left a held touch";
		state.end(2);
		expect(""); // stale end after state transition is harmless
		state.move(4, -1);
		state.end(4);
		expect("");
		Sys.println("MobileTouchState: all tests passed");
	}
}
