package;

#if android
import flixel.FlxG;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.ui.Multitouch;
import openfl.ui.MultitouchInputMode;

/** Screen-space controls, independent of camera zoom, modcharts and note positions. */
class MobileControls extends Sprite
{
	var touches:MobileTouchState;
	var regions:Array<Rectangle> = [];
	var keyCodes:Array<Int> = [];
	var labels:Array<TextField> = [];
	var gameplay:Bool = false;
	var lastState:FlxState;
	var lastSubState:Dynamic;
	var lastWidth:Int = 0;
	var lastHeight:Int = 0;
	var showHitboxes:Bool = true;
	var dirty:Bool = true;

	public function new()
	{
		super();
		mouseEnabled = false;
		mouseChildren = false;
		touches = new MobileTouchState(sendKey);
		addEventListener(Event.ADDED_TO_STAGE, onAdded);
	}

	function onAdded(event:Event):Void
	{
		removeEventListener(Event.ADDED_TO_STAGE, onAdded);
		Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		stage.addEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
		stage.addEventListener(TouchEvent.TOUCH_MOVE, onMove);
		stage.addEventListener(TouchEvent.TOUCH_END, onEnd);
		stage.addEventListener(Event.DEACTIVATE, onDeactivate);
		FlxG.signals.postUpdate.add(refresh);
		addEventListener(Event.REMOVED_FROM_STAGE, onRemoved);
	}

	function onRemoved(event:Event):Void
	{
		touches.clear();
		// REMOVED_FROM_STAGE is dispatched before the stage reference is cleared.
		if (stage != null)
		{
			stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onBegin);
			stage.removeEventListener(TouchEvent.TOUCH_MOVE, onMove);
			stage.removeEventListener(TouchEvent.TOUCH_END, onEnd);
			stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
		}
		FlxG.signals.postUpdate.remove(refresh);
	}

	function sendKey(code:Int, down:Bool):Void
	{
		// Equal character/key codes bypass Flixel native keyboard-layout corrections.
		if (stage != null)
			stage.dispatchEvent(new KeyboardEvent(down ? KeyboardEvent.KEY_DOWN : KeyboardEvent.KEY_UP, true, false, code, code));
		dirty = true;
	}

	function onDeactivate(event:Event):Void
	{
		touches.clear();
	}

	function onBegin(event:TouchEvent):Void
	{
		refresh();
		touches.move(event.touchPointID, keyAt(event.stageX, event.stageY));
	}

	function onMove(event:TouchEvent):Void
	{
		if (!touches.contains(event.touchPointID))
			return;
		// Slide between gameplay lanes. Menu buttons require a deliberate new tap.
		if (gameplay)
		{
			var key = keyAt(event.stageX, event.stageY);
			if (key == keyCodes[4])
				key = -1;
			touches.move(event.touchPointID, key);
		}
	}

	function onEnd(event:TouchEvent):Void
	{
		touches.end(event.touchPointID);
	}

	function keyAt(x:Float, y:Float):Int
	{
		for (i in 0...regions.length)
			if (regions[i].contains(x, y))
				return keyCodes[i];
		return -1;
	}

	function binding(name:String, fallback:Int):Int
	{
		var value:String = Reflect.field(FlxG.save.data, name);
		if (value == null)
			return fallback;
		var code:Int = FlxKey.fromString(value);
		return code > 0 ? code : fallback;
	}

	function refresh():Void
	{
		if (stage == null || FlxG.state == null)
			return;
		var playing = Std.isOfType(FlxG.state, PlayState) && FlxG.state.subState == null;
		if (playing)
		{
			var playState:PlayState = cast FlxG.state;
			playing = !playState.inCutscene;
		}
		var width = stage.stageWidth;
		var height = stage.stageHeight;
		if (lastState != FlxG.state || lastSubState != FlxG.state.subState || playing != gameplay || width != lastWidth || height != lastHeight)
		{
			touches.clear();
			lastState = FlxG.state;
			lastSubState = FlxG.state.subState;
			gameplay = playing;
			lastWidth = width;
			lastHeight = height;
			buildLayout();
		}
		var show = FlxG.save.data.hitboxVisible != false;
		if (show != showHitboxes)
		{
			showHitboxes = show;
			dirty = true;
		}
		if (dirty)
			drawControls();
	}

	function buildLayout():Void
	{
		for (label in labels)
			removeChild(label);
		labels = [];
		regions = [];
		keyCodes = [];
		var bar = Math.max(48, lastHeight * 0.12);
		if (gameplay)
		{
			var names = ["leftBind", "downBind", "upBind", "rightBind"];
			var codes = [37, 40, 38, 39];
			var text = ["LEFT", "DOWN", "UP", "RIGHT"];
			for (i in 0...4)
				addRegion(new Rectangle(i * lastWidth / 4, bar, lastWidth / 4, lastHeight - bar), binding(names[i], codes[i]), text[i]);
			addRegion(new Rectangle(lastWidth - bar * 2, 0, bar * 2, bar), binding("pauseBind", 13), "PAUSE");
		}
		else
		{
			var codes = [37, 40, 38, 39, 27, 13];
			var text = ["LEFT", "DOWN", "UP", "RIGHT", "BACK", "OK"];
			for (i in 0...6)
				addRegion(new Rectangle(i * lastWidth / 6, lastHeight - bar, lastWidth / 6, bar), codes[i], text[i]);
		}
		dirty = true;
	}

	function addRegion(rect:Rectangle, code:Int, text:String):Void
	{
		regions.push(rect);
		keyCodes.push(code);
		var label = new TextField();
		label.defaultTextFormat = new TextFormat("_sans", Std.int(Math.max(14, lastHeight * 0.026)), 0xFFFFFF, true, null, null, null, null, "center");
		label.text = text;
		label.selectable = false;
		label.mouseEnabled = false;
		label.x = rect.x;
		label.width = rect.width;
		label.height = lastHeight * 0.05;
		label.y = gameplay && regions.length <= 4 ? lastHeight - label.height - 12 : rect.y + (rect.height - label.height) / 2;
		labels.push(label);
		addChild(label);
	}

	function drawControls():Void
	{
		graphics.clear();
		var colors = [0xC24B99, 0x00FFFF, 0x12FA05, 0xF9393F];
		for (i in 0...regions.length)
		{
			var lane = gameplay && i < 4;
			var visible = !lane || showHitboxes;
			labels[i].visible = visible;
			if (!visible)
				continue;
			var rect = regions[i];
			var color = lane ? colors[i] : 0x303050;
			graphics.lineStyle(1, lane ? color : 0xFFFFFF, 0.45);
			graphics.beginFill(color, touches.held(keyCodes[i]) ? 0.4 : (lane ? 0.08 : 0.65));
			graphics.drawRect(rect.x + 1, rect.y + 1, rect.width - 2, rect.height - 2);
			graphics.endFill();
		}
		dirty = false;
	}
}
#end
