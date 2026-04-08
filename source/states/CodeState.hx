package states;

import backend.Mods;
import backend.Song;
import backend.Highscore;

import flixel.FlxObject;

import haxe.Json;

import flixel.util.FlxSpriteUtil;
import flixel.graphics.FlxGraphic;
import flash.geom.Rectangle;

import flixel.text.FlxText;
import flixel.util.FlxColor;

using StringTools;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxTimer;

class CodeState extends MusicBeatState
{

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var bigBG:FlxSprite;
	var enterCodeText:Alphabet;
	var inputBoxBG:FlxSprite;
	public var inputBox:FlxInputText;

	var invalid:FlxText;
	var scoreAndAcc:FlxText;
	var canType = true;
	
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

    override function create()
	{
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Typing a Code", null);
		#end

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = 0.25;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.antialiasing = ClientPrefs.data.antialiasing;
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFfd719b;
		add(magenta);

		
		bigBG = FlxSpriteUtil.drawRoundRect(new FlxSprite(0, 40).makeGraphic(600, 220, FlxColor.TRANSPARENT), 0, 0, 600, 220, 15, 15, FlxColor.BLACK);
		bigBG.alpha = 0.6;
		bigBG.updateHitbox();
		bigBG.screenCenter();
		add(bigBG);

		enterCodeText = new Alphabet(300, 200, "Enter Code", true);
		enterCodeText.setScale(0.6);
		add(enterCodeText);

		inputBoxBG = FlxSpriteUtil.drawRoundRect(new FlxSprite(375,305).makeGraphic(525, 64, FlxColor.TRANSPARENT), 0, 0, 525, 64, 15, 15, FlxColor.BLACK);
		inputBoxBG.alpha = 0.8;
		inputBoxBG.updateHitbox();
		add(inputBoxBG);

        inputBox = new FlxInputText(475, 325, 500, "", 64, FlxColor.WHITE, FlxColor.TRANSPARENT, true);
		inputBox.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, FlxTextBorderStyle.NONE,FlxColor.WHITE);
		inputBox.scrollFactor.set();
		inputBox.updateHitbox();
		inputBox.screenCenter();
		inputBox.hasFocus = true;
		inputBox.maxLength = 27;
		inputBox.borderSize = 0.1;
		add(inputBox);

        inputBox.callback = function(text, action){
			if (action == 'enter')
			{
				if(controls.ACCEPT && canType) {
					canType = false;
					switch(text.toLowerCase())
					{
						case "":
							startSongThing('');
						default:
							invalidLOL();
					}
					new FlxTimer().start(1, function(tmr:FlxTimer) {
						canType = true;
					});
				}
			}
		}
        invalid = new FlxText(0, 0, 0, "Invalid Code", 32);
    	invalid.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.RED, CENTER, SHADOW,FlxColor.BLACK);
    	invalid.shadowOffset.set(2,2);
    	invalid.screenCenter();
    	invalid.y += 50;

        scoreAndAcc = new FlxText(0, 0, 0, "", 32);
    	scoreAndAcc.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, SHADOW,FlxColor.BLACK);
    	scoreAndAcc.shadowOffset.set(2,2);
    	scoreAndAcc.screenCenter();
    	scoreAndAcc.x -= 250;
    	scoreAndAcc.y += 50;

		Difficulty.list = ["Hard"];
    }

	override function update(elapsed:Float)
    {
		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.mouse.visible = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new MainMenuState());
		}
		
		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		scoreAndAcc.text = Language.getPhrase('personal_best', 'Personal Best: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
    }

	function invalidLOL() {
		FlxG.camera.shake(0.0075, 0.50);
		new FlxTimer().start(0.5, function(tmr:FlxTimer) {
			add(invalid);
			new FlxTimer().start(5, function(tmr:FlxTimer) {
				remove(invalid);
			});
		});
	}
	
	function startSongThing(songName:String = '') {
		intendedScore = Highscore.getScore(songName, 0);
		intendedRating = Highscore.getRating(songName, 0);

		add(scoreAndAcc);
		new FlxTimer().start(2, function(tmr:FlxTimer) {
			Song.loadFromJson(songName + "-hard", songName);
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 0;
			LoadingState.prepareToSong();
			LoadingState.loadAndSwitchState(new PlayState());
		});
    }
}
