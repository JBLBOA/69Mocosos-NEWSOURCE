package states.videoState;

#if VIDEOS_ALLOWED 
#if (hxCodec >= "3.0.0") import hxcodec.flixel.FlxVideo as VideoHandler;
#elseif (hxCodec >= "2.6.1") import hxcodec.VideoHandler as VideoHandler;
#elseif (hxCodec == "2.6.0") import VideoHandler;
#else import vlc.MP4Handler as VideoHandler; #end
#end

import openfl.Lib;
import lime.app.Application;
import sys.FileSystem;
import sys.io.File;

class Video extends MusicBeatState
{
    var winame:String = "SECRET UNLOCKED";
    var videoname:String = "screamer";

    override function create()
        {
            #if desktop
            // Updating Discord Rich Presence
            DiscordClient.changePresence(winame, null);
            #end

            Lib.application.window.title = winame.toUpperCase();

            startVideo();
            FlxG.sound.music.volume = 0;
        }
        
    public function startVideo()
        {
            var filepath:String = Paths.video(videoname);
            #if sys
            if(!FileSystem.exists(filepath))
            #else
            if(!OpenFlAssets.exists(filepath))
            #end
            {
                FlxG.log.warn(videoname);
                startAndEnd();
                return;
            }
    
            var video:VideoHandler = new VideoHandler();
                #if (hxCodec >= "3.0.0")
                // Recent versions
                video.play(filepath);
                video.onEndReached.add(function()
                {
                    video.dispose();
                    startAndEnd();
                    return;
                }, true);
                #else
                // Older versions
                video.playVideo(filepath);
                video.finishCallback = function()
                {
                    startAndEnd();
                    return;
                }
                #end
        }
    
        function startAndEnd()
        {
            Sys.exit(0);
        }    
}