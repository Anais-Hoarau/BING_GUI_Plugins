---------- README /\ DshowAudio4BIND ----------



--- Introduction



DshowAudio4BIND is a dll that can be used to play audio from an AVI video, or WAV files using DirectShow.
It can play mutliple audio files at the same time.



--- How to use

Add "DshowAudio4BINDheader.m" to a folder that's in your Matlab path. This file is the protoype that you can use to load DshowAudio4BIND.dll in Matlab.


Functions you can call using DshowAudio4BIND 



	int LoadAudio(char* audiofile)


This function will load the audio that path is <audiofile>, and return a <audio_id> that can be used to access this audio with other functions.

Possible errors:

	"DSA4B:NoSeekable", "The input media doesn't have seeking capabilities"
	"DSA4B:InitializingLibraryErr", "Could not initialize COM library"
	"DSA4B:CreateFilterGraphManagerErr", "Could not create the Filter Graph Manager"
	"DSA4B:CantOpenFile", "Could not open the input file"
	


	void SetPosition(int audio_id, float position)


For the audio <audio_id>, this function will set the audio file to the nearest <position>. <position> is exprimed in seconds.
Audio will not automatically play after this call, you must call the Play function to do so.
If audio was currently playing, it will be paused.

Possible errors:

	"DSA4B:WrongID", "The input ID is incorrect"



	void UnloadAudio(int audio_id)


Stop and unload the <audio_id>. This function should be called everytime you stop working with an audio.

Possible errors:

	"DSA4B:WrongID", "The input ID is incorrect"



	bool NoMoreAudio()


Return true if there is no opened audio in the DLL, false else.



	void Play(int audio_id)


Play the <audio_id> from the current position.

Possible errors:

	"DSA4B:WrongID", "The input ID is incorrect"



	void Pause(int audio_id)


Pause the <audio_id> playback.

Possible errors:

	"DSA4B:WrongID", "The input ID is incorrect"



	void SetRate(int audio_id, double rate)


For the <audio_id>, this method will set the playback rate to <rate>.
<rate> is relative to the normal speed rate. 1 is the normal rate, 0.5 is half of the normal playback rate, 2 is twice the normal playback rate, etc...
This functions does not pause the playback.

Possible errors:

	"DSA4B:WrongID", "The input ID is incorrect"
	"DSA4B:WrongRate", "Rate must be > 0"



--- Common error


If you have an error that says "The input media doesn't have seeking capabilities", you might have to check for your codecs. Try opening the file with Windows Media Player. If it doesn't manage to open the file neither, your surely need codecs. If it doesn't have any problem opening it, then it must be that your media actually doesn't have seeking capabilities.