package options;

import backend.Mods;

import flixel.FlxBasic;
import flixel.graphics.FlxGraphic;
import flash.geom.Rectangle;
import haxe.Json;

import flixel.util.FlxSpriteUtil;
import objects.AttachedSprite;

class ChangelogState extends MusicBeatState
{
	var bg:FlxSprite;
	var versionName:Alphabet;
	var versionChangelog:FlxText;

	var bgTitle:FlxSprite;
	var bgChangelog:FlxSprite;
	
	var bgList:FlxSprite;

	var hoveringOnVersions:Bool = true;
	var curSelectedButton:Int = 0;
	var versionNameInitialY:Float = 0;
	
	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		persistentUpdate = false;
		
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Reading Changelogs", null);
		#end


		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFF120996;
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();

		bgList = FlxSpriteUtil.drawRoundRect(new FlxSprite(40, 40).makeGraphic(340, 440, FlxColor.TRANSPARENT), 0, 0, 340, 440, 15, 15, FlxColor.BLACK);
		bgList.alpha = 0.6;

		bgTitle = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite(bgList.x + bgList.width + 20, 40).makeGraphic(840, 180, FlxColor.TRANSPARENT), 0, 0, 840, 180, 15, 15, 0, 0, FlxColor.BLACK);
		bgTitle.alpha = 0.6;
		add(bgTitle);

		versionNameInitialY = bgTitle.y + 80;
		versionName = new Alphabet(bgTitle.x + 165, versionNameInitialY, "", true);
		versionName.scaleY = 0.8;
		add(versionName);

		bgChangelog = FlxSpriteUtil.drawRoundRectComplex(new FlxSprite(bgTitle.x, bgTitle.y + 200).makeGraphic(840, 450, FlxColor.TRANSPARENT), 0, 0, 840, 450, 0, 0, 15, 15, FlxColor.BLACK);
		bgChangelog.alpha = 0.6;
		add(bgChangelog);
		
		versionChangelog = new FlxText(bgChangelog.x + 15, bgChangelog.y + 15, bgChangelog.width - 30, "", 24);
		versionChangelog.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
		add(versionChangelog);
	}
	override public function update(elapsed:Float) 
	{
		if (controls.BACK)
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			MusicBeatState.switchState(new options.OptionsState());
		}
		
	}
}
