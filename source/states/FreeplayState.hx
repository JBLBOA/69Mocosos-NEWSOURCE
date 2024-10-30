package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import objects.HealthIcon;
import objects.FlxFbutton;
import objects.MusicPlayer;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

import flixel.math.FlxMath;

#if !flash 
import flixel.addons.display.FlxRuntimeShader;
import openfl.filters.ShaderFilter;
#end

import openfl.utils.Assets;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];

	var selector:FlxText;
	private static var curSelected:Int = 0;
	var lerpSelected:Float = 0;
	var curDifficulty:Int = -1;
	private static var lastDifficultyName:String = Difficulty.getDefault();

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var enterText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var player:MusicPlayer;

	var freewea1:FlxSprite;
	var freewea2:FlxSprite;
	var freewea3:FlxSprite;

	var yesButton:FlxSprite;
	var noButton:FlxSprite;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length) {
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push(leWeek.songs[j][1]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if(colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				//addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}

		addSong("anti_drop", 0, "", FlxColor.fromRGB(0,0,0));
		addSong("evil-blow", 0, "", FlxColor.fromRGB(0,0,0));
		addSong("gian.ogg", 0, "", FlxColor.fromRGB(0,0,0));

		Mods.loadTopMod();

		bg = new FlxSprite().loadGraphic(Paths.image('freeplay/sonifbackgrubd'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(90, 320, songs[i].songName, true);
			songText.targetY = i;
			grpSongs.add(songText);

			songText.scaleX = Math.min(1, 980 / songText.width);
			songText.snapToPosition();

			Mods.currentModDirectory = songs[i].folder;
			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			
			// too laggy with a lot of songs, so i had to recode the logic for it
			songText.visible = songText.active = songText.isMenuItem = false;
			icon.visible = icon.active = false;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 300, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		scoreText.alpha = 0.0;
		scoreText.screenCenter(Y);

		enterText = new FlxText(FlxG.width * 0.7, 300, 0, "", 32);
		enterText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		enterText.alpha = 0.0;
		enterText.screenCenter(Y);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		//add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		//add(diffText);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		lerpSelected = curSelected;

		curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(lastDifficultyName)));

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		//add(bottomBG);

		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		//add(bottomText);

		black = new FlxSprite(0,0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		black.alpha = 0.0;
		add(black);

		var freeplai:FlxSprite = new FlxSprite(0,100).loadGraphic(Paths.image("freeplay/freeplaiting"));
		freeplai.screenCenter(X);
		add(freeplai);

		add(scoreText);

		freewea1 = new FlxSprite(250,500);
		freewea1.frames = Paths.getSparrowAtlas('freeplay/sonifreplai1');
		freewea1.animation.addByPrefix('idle', "antibrop instancia 1", 24);
		freewea1.animation.play('idle');
		add(freewea1);

		freewea2 = new FlxSprite(250,250);
		freewea2.frames = Paths.getSparrowAtlas('freeplay/sonifreplai2');
		freewea2.animation.addByPrefix('idle', "gian.ogg instancia 1", 24);
		freewea2.animation.play('idle');
		freewea2.screenCenter(X);
		add(freewea2);

		freewea3 = new FlxSprite(700,500);
		freewea3.frames = Paths.getSparrowAtlas('freeplay/sonifreplai3');
		freewea3.animation.addByPrefix('idle', "Símbolo 6 instancia 1", 24);
		freewea3.animation.play('idle');
		add(freewea3);

		yesButton = new FlxSprite(200, 540);
		yesButton.frames = Paths.getSparrowAtlas("buttonsSelects");
		yesButton.animation.addByPrefix('idle', "YESUNSELECTED", 24);
		yesButton.animation.addByPrefix('select', "YESSELECTED", 24);
		yesButton.animation.play('idle');
		yesButton.scale.x = 0.6;
		yesButton.scale.y = 0.6;
		yesButton.alpha = 0.0;
		yesButton.visible = false;
		add(yesButton);

		noButton = new FlxSprite(600, 540);
		noButton.frames = Paths.getSparrowAtlas("buttonsSelects");
		noButton.animation.addByPrefix('idle', "NOUNSELECTED", 24);
		noButton.animation.addByPrefix('select', "NOSELECTED", 24);
		noButton.animation.play('idle');
		noButton.scale.x = 0.6;
		noButton.scale.y = 0.6;
		noButton.alpha = 0.0;
		noButton.visible = false;
		add(noButton);

		var negro1 = new FlxSprite(0, 0).makeGraphic(200, FlxG.height, FlxColor.BLACK);
		negro1.scrollFactor.set(0, 0);
		add(negro1);

		var negro2 = new FlxSprite(1090, 0).makeGraphic(200, FlxG.height, FlxColor.BLACK);
		negro2.scrollFactor.set(0, 0);
		add(negro2);

		player = new MusicPlayer(this);
		add(player);
		
		changeSelection();
		updateTexts();
		super.create();
	}

	override function closeSubState() {
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	var holdTime:Float = 0;

	var selectedShit:String = "";
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, FlxMath.bound(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, FlxMath.bound(elapsed * 12, 0, 1));

		FlxG.mouse.visible = true;

		if (FlxG.mouse.overlaps(yesButton) && FlxG.mouse.justPressed)
			{
				if (yesButton.visible)
					{
						enterSong();
					}
			}



		if (FlxG.mouse.overlaps(noButton) && FlxG.mouse.justPressed)
			{
				if (noButton.visible)
					{
						FlxG.sound.music.stop();
						FlxG.sound.music.volume = 0;
					
						player.playingMusic = false;
						player.switchPlayMusic();
						
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			
							back();
					}
				
			}


		if (selectedShit == "")
			{
				if (FlxG.mouse.overlaps(freewea1) && FlxG.mouse.justPressed)
					{
						selectedShit = "antidrop";
						loadsong();
						antidrop();
					}
		
				if (FlxG.mouse.overlaps(freewea2) && FlxG.mouse.justPressed)
					{
						selectedShit = "gian.ogg";
						loadsong();
						gian();
					}
		
				if (FlxG.mouse.overlaps(freewea3) && FlxG.mouse.justPressed)
					{
						selectedShit = "evil-blow";
						loadsong();
						funkin();
					}
			}

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) { //No decimals, add an empty space
			ratingSplit.push('');
		}
		
		while(ratingSplit[1].length < 2) { //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var shiftMult:Int = 1;
		if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

		if (!player.playingMusic)
		{
			scoreText.text = 'PERSONAL BEST: \n'  + lerpScore + ' (' + ratingSplit.join('.') + '%)';
			positionHighscore();
			
			if(songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
			}

			if (controls.UI_LEFT_P)
			{
				changeDiff(-1);
				_updateSongLastDifficulty();
			}
			else if (controls.UI_RIGHT_P)
			{
				changeDiff(1);
				_updateSongLastDifficulty();
			}
		}

		if (controls.BACK)
		{
			MusicBeatState.switchState(new MainMenuState());
		}

		if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}
		else if(FlxG.keys.justPressed.SPACE)
		{
			if(instPlaying != curSelected && !player.playingMusic && selectedShit != "")
			{
				
		}
		else if (true == false)
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				updateTexts(elapsed);
				super.update(elapsed);
				return;
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
			#if (MODS_ALLOWED && cpp)
			DiscordClient.loadModRPC();
			#end
		}
		else if(controls.RESET && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		updateTexts(elapsed);
		super.update(elapsed);
	}
	}

	function enterSong()
		{
			persistentUpdate = false;
			var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
			var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
			/*#if MODS_ALLOWED
			if(!FileSystem.exists(Paths.modsJson(songLowercase + '/' + poop)) && !FileSystem.exists(Paths.json(songLowercase + '/' + poop))) {
			#else
			if(!OpenFlAssets.exists(Paths.json(songLowercase + '/' + poop))) {
			#end
				poop = songLowercase;
				curDifficulty = 1;
				trace('Couldnt find file');
			}*/
			trace(poop);

			try
			{
				PlayState.SONG = Song.loadFromJson(poop, songLowercase);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;

				trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
				if(colorTween != null) {
					colorTween.cancel();
				}
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');

				var errorStr:String = e.toString();
				if(errorStr.startsWith('[file_contents,assets/data/')) errorStr = 'Missing file: ' + errorStr.substring(34, errorStr.length-1); //Missing chart
				missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
				missingText.screenCenter(Y);
				missingText.visible = true;
				missingTextBG.visible = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));

				return;
			}
			LoadingState.loadAndSwitchState(new PlayState());

			FlxG.sound.music.volume = 0;
					
			destroyFreeplayVocals();
			#if (MODS_ALLOWED && cpp)
			DiscordClient.loadModRPC();
			#end
		}
	var black:FlxSprite;
	function back()
		{ 
			FlxTween.tween(freewea1.scale, { x: 1.0, y: 1.0 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea2.scale, { x: 1.0, y: 1.0 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea3.scale, { x: 1.0, y: 1.0 }, 1.0, {ease: FlxEase.cubeOut});

			FlxTween.tween(freewea1, { alpha: 1.0 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea2, { alpha: 1.0 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea3, { alpha: 1.0 }, 1.0, {ease: FlxEase.cubeOut});

			FlxTween.tween(freewea1, { x: 250, y: 500 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea2, { x: (FlxG.width / 2) - (freewea2.width / 2), y: 250 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea3, { x: 700, y:500 }, 1.0, {ease: FlxEase.cubeOut});

			FlxTween.tween(black, { alpha: 0.0 }, 1.3, {ease: FlxEase.cubeOut});
			FlxTween.tween(scoreText, { alpha: 0.0 }, 0.5);
			FlxTween.tween(noButton, { alpha: 0.0 }, 0.5);
			FlxTween.tween(yesButton, { alpha: 0.0 }, 0.5);

			yesButton.y = 540;
			noButton.y = 540;

			noButton.visible = false;
			yesButton.visible = false;

			new FlxTimer().start(1.5, function(tmr:FlxTimer)
				{
					selectedShit = "";
					trace(selectedShit);
				});
		}

	function antidrop()
		{
			FlxG.sound.playMusic(Paths.inst("anti_drop"), 1, true);
			FlxTween.tween(freewea1, { x: 600, y: 350 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea1.scale, { x: 1.3, y: 1.3 }, 0.2, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea2, { alpha: 0.0 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea3, { alpha: 0.0 }, 1.0, {ease: FlxEase.cubeOut});
			curSelected = 0;
		}
	function gian()
		{
			yesButton.y = 600;
			noButton.y = 600;

			FlxG.sound.playMusic(Paths.inst("test"), 1, true);
			FlxTween.tween(freewea2, { x: 600, y: 350 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea2.scale, { x: 1.3, y: 1.3 }, 0.2, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea1, { alpha: 0.0 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea3, { alpha: 0.0 }, 1.0, {ease: FlxEase.cubeOut});
			curSelected = 2;
		}
	function funkin()
		{
			FlxG.sound.playMusic(Paths.inst("test"), 1, true);
			FlxTween.tween(freewea3, { x: 600, y: 350 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea3.scale, { x: 1.3, y: 1.3 }, 0.2, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea1, { alpha: 0.0 }, 1.0, {ease: FlxEase.cubeOut});
			FlxTween.tween(freewea2, { alpha: 0.0 }, 1.0, {ease: FlxEase.cubeOut});
			curSelected = 1;
		}
	function loadsong()
		{
			FlxTween.tween(black, { alpha: 0.5 }, 0.5);
			FlxTween.tween(scoreText, { alpha: 1.0 }, 0.5);
			noButton.visible = true;
			yesButton.visible = true;
			FlxTween.tween(noButton, { alpha: 1.0 }, 0.5);
			FlxTween.tween(yesButton, { alpha: 1.0 }, 0.5);

			trace(songs[curSelected].songName);
		}

	public static function destroyFreeplayVocals() {
		if(vocals != null) {
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		if (player.playingMusic)
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = Difficulty.list.length-1;
		if (curDifficulty >= Difficulty.list.length)
			curDifficulty = 0;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		lastDifficultyName = Difficulty.getString(curDifficulty);
		if (Difficulty.list.length > 1)
			diffText.text = '< ' + lastDifficultyName.toUpperCase() + ' >';
		else
			diffText.text = lastDifficultyName.toUpperCase();

		positionHighscore();
		missingText.visible = false;
		missingTextBG.visible = false;
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		_updateSongLastDifficulty();
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		var lastList:Array<String> = Difficulty.list;
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
			
		var newColor:Int = songs[curSelected].color;
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
		}

		// selector.y = (70 * curSelected) + 30;

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.0;
		}

		iconArray[curSelected].alpha = 0.0;

		for (item in grpSongs.members)
		{
			bullShit++;
			item.alpha = 0.0;
			if (item.targetY == curSelected)
				item.alpha = 0.0;
		}
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
		Difficulty.loadFromWeek();
		
		var savedDiff:String = songs[curSelected].lastDifficulty;
		var lastDiff:Int = Difficulty.list.indexOf(lastDifficultyName);
		if(savedDiff != null && !lastList.contains(savedDiff) && Difficulty.list.contains(savedDiff))
			curDifficulty = Math.round(Math.max(0, Difficulty.list.indexOf(savedDiff)));
		else if(lastDiff > -1)
			curDifficulty = lastDiff;
		else if(Difficulty.list.contains(Difficulty.getDefault()))
			curDifficulty = Math.round(Math.max(0, Difficulty.defaultList.indexOf(Difficulty.getDefault())));
		else
			curDifficulty = 0;

		changeDiff();
		_updateSongLastDifficulty();
	}

	inline private function _updateSongLastDifficulty()
	{
		songs[curSelected].lastDifficulty = Difficulty.getString(curDifficulty);
	}

	private function positionHighscore() {
		scoreText.x = 200;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(lerpSelected, curSelected, FlxMath.bound(elapsed * 9.6, 0, 1));
		for (i in _lastVisibles)
		{
			grpSongs.members[i].visible = grpSongs.members[i].active = false;
			iconArray[i].visible = iconArray[i].active = false;
		}
		_lastVisibles = [];

		var min:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(songs.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:Alphabet = grpSongs.members[i];
			item.visible = item.active = true;
			item.x = ((item.targetY - lerpSelected) * item.distancePerItem.x) + item.startPosition.x;
			item.y = ((item.targetY - lerpSelected) * 1.3 * item.distancePerItem.y) + item.startPosition.y;

			var icon:HealthIcon = iconArray[i];
			icon.visible = icon.active = true;
			_lastVisibles.push(i);
		}
	}

	override function destroy():Void
	{
		super.destroy();

		FlxG.autoPause = ClientPrefs.data.autoPause;
		if (!FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
	}	
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";
	public var lastDifficulty:String = null;

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}