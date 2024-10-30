package objects;

class FlxFbutton extends FlxSprite
{
    public var button:FlxSprite;

	public function new(x:Float, y:Float, image:String, prefix:String, callfunction:() -> Void)
        {
            super(x, y, image);

            button = new FlxSprite(x,y);
            button.frames = Paths.getSparrowAtlas(image);
			button.animation.addByPrefix('idle', prefix+"UNSELECTED", 24);
            button.animation.addByPrefix('select', prefix+"SELECTED", 24);
			button.animation.play('idle');
        }
}