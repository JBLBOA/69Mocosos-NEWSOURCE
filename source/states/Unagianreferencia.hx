package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

import flixel.addons.display.FlxBackdrop;

using StringTools;

class Unagianreferencia extends MusicBeatState
{

    //reutilice la galeria de vs mauricio que pedo w

    var fondo11:FlxBackdrop;
    var img:FlxSprite;
    var txt:FlxText;
    var roberto:FlxText;
    var galeryIMG:Array<String> = ['arte no reconocido', 'arte', 'fan art gian', 'gian corrupto', 'gian Fnf', 'gian y don coso', 'gianBG', 'gianDOWN', 'gianFNF', 'gianPVZ', 'gianSans', 'linceDeidad', 'XDDDDDDDDd', 'VS GIAN FNF EN EL MUSLO DEL CODER XDDXXD', 'FELICIDADES HAS INVOCADO A GIAN 3D'];
    var galeryTXT:Array<String> = ['arte no reconocido', 'arte', 'gian fan art', 'gian corrupto', 'Gian FNF', 'gian y donAlgo', 'GIAN EN EL FONDO!!11!!11', 'Gian SingDown', 'GIAN 7QUID', 'GIAN PVZ REAL!!111', 'GIAN SANS UNDERTALE', 'LINCEDEIDAD DIBUJO', 'XDDDDDDDDd', 'VS GIAN FNF EN EL MUSLO DEL CODER XDDXXD', 'FELICIDADES HAS INVOCADO A GIAN 3D'];
    var curSelected:Int = 0;
    var canSelect:Bool = true;

	override function create()
        {
            var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
            bg.antialiasing = ClientPrefs.data.antialiasing;
            bg.setGraphicSize(Std.int(bg.width * 1.175));
            bg.screenCenter();
            add(bg);

            add(fondo11 = new FlxBackdrop(Paths.image('GIAN/1GRID')));
            fondo11.scrollFactor.set();
            fondo11.velocity.set(-10, -20);
    
            fondo11.velocity.x = -120;

            img = new FlxSprite().loadGraphic(Paths.image('GIAN/' + galeryIMG[curSelected]));
            add(img);

            txt = new FlxText(700);
            add(txt);

            changeSelection();

            super.create();
        }

    function changeSelection(dick:Int = 0)
        {
            FlxG.sound.play(Paths.sound('scrollMenu'));
            curSelected += dick;
        
            if (curSelected >= galeryIMG.length)
                curSelected = 0;
            if (curSelected < 0)
                curSelected = galeryIMG.length - 1;
        
            img.loadGraphic(Paths.image('GIAN/' + galeryIMG[curSelected]));
            img.setGraphicSize(0, 520);
            img.updateHitbox();
            img.screenCenter();

            txt.text = galeryTXT[curSelected];
            txt.size = 50;
            txt.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
            txt.screenCenter(X);
        
            trace(('galeria/' + galeryIMG[curSelected]));
            trace(('text = ' + galeryTXT[curSelected]));
        }

    
    override function update(elapsed:Float)
        {
            if (canSelect)
            {
                if (FlxG.mouse.wheel >= 1)
                    {
                        changeSelection(-1);
                    }
        
                    if (FlxG.mouse.wheel <= -1)
                        {
                            changeSelection(1);
                        }
        
                if (controls.UI_LEFT_P)
                {
                    changeSelection(-1);
                }
                else if (controls.UI_RIGHT_P)
                {
                    changeSelection(1);
                }
            
                if (controls.BACK)
                {
                    MusicBeatState.switchState(new MainMenuState());
                    canSelect = false;
                }
            }
            super.update(elapsed);
        }
}