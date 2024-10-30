package soundTest;

import flixel.addons.display.FlxBackdrop;

class SoundTestMenu extends MusicBeatState
{
	var fondomierderoxdxdxddxd:FlxBackdrop;
	var soundtestTXT:FlxText;

	override function create()
        {
            fondomierderoxdxdxddxd = new FlxBackdrop(Paths.image('soundTest/grid'));
            fondomierderoxdxdxddxd.scrollFactor.set();
            fondomierderoxdxdxddxd.velocity.set(-40, -40);
            fondomierderoxdxdxddxd.velocity.x = -120;
            add(fondomierderoxdxdxddxd);

            soundtestTXT = new FlxText(0, 650, 0, "SOUND TEST", 32);
            soundtestTXT.setFormat(Paths.font("sonicCD.ttf"), 32, 0x000000, CENTER);
            add(soundtestTXT);

        }
}