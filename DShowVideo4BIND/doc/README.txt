---------- README /\ DshowVideo4BIND ----------



--- Introduction



DshowVideo4BIND is a dll that can be used to play videos frame by frame using DirectShow.
It can play multiple videos at the same time, but it doesn't support sound output.



--- How to use

Add "DshowVideo4BINDheader.m" to a folder that's in your Matlab path. This file is the protoype that you can use to load DshowVideo4BIND.dll in Matlab.


Functions you can call using DshowVideo4BIND



	int LoadVideo(char* videofile, int hide, char* wdw_name)


This function will load the video that path is <videofile>, and return a <video_id> that can be used to access this video with other functions. 
If the <hide> value is 0, it will open a video window where frames will be diplayed. If the <hide> value is 1, no window will be opened. This last use is for the ScreenCapture function.
<wdw_name> is the title that will be given to the video window.

Possible errors:

"DSV4B:NoSeekable", "The input media doesn't have seeking capabilities"
"DSV4B:InitializingLibraryErr", "Could not initialize COM library"
"DSV4B:CreateFilterGraphManagerErr", "Could not create the Filter Graph Manager"
"DSV4B:CantOpenFile", "Could not open the input file"



	void SetPosition(int video_id, float position)


For the video <video_id>, this function will display the frame that is at the nearest <position> in the video. <position> is in seconds.

Possible errors:

"DSV4B:WrongID", "The input ID is incorrect"



	void UnloadVideo(int video_id)


Unload the <video_id>. This function should be called everytime you stop working with a video.

Possible errors:

"DSV4B:WrongID", "The input ID is incorrect"



	float GetDuration(int video_id)


For the <video_id>, return the duration of the video in seconds.

Possible errors:

"DSV4B:WrongID", "The input ID is incorrect"



	bool NoMoreVideo()


Return true if there is no opened video in the DLL, false else.



	void SetWindowPosition(int video_id, char* wdw_pos)


Set the window position for the video <video_id> to <wdw_pos>. <wdw_pos> is a value of BIND positionning system, i.e. {'north', 'south', 'east', 'west', 'northeast', 'northwest', 'southeast', 'southwest', 'center'}.

Possible errors:

"DSV4B:WrongID", "The input ID is incorrect"



	void OverlayText(int video_id, char* text, char *position, int font_width, int rgb[3])


For the <video_id>, <text> will be overlayed. The text will appear after the next call of "SetPosition".
If text is empty (''), the displayed text will be removed. The removal will also be in effect after the next call of "SetPosition".
<position> can either be "top" or "bottom", that's where the <text> will be displayed on the video. By default, position is bottom.
<font_width> is the width of the font used to display text, in logical unit. 0 is the default value (which corresponds to 9 units). Values under 10 are most of the time not readable. Great values are between 10 and 20.
<rgb[3]> is an array containing 3 values defining RGB color of the text. Note that white (255, 255, 255) CAN NOT be used.
If <video_id> is 0, then text will be overlayed on every opened video.
You have to be aware that if your text is too long for the video, it will be "compressed" and will become unreadable.
Every call to the function will erase the previously overlayed text.

Possible errors:

"DSV4B:WrongID", "The input ID is incorrect"
"DSV4B:WrongColor", "White can't be used as font color"



	void ScreenCapture(int video_id, char* output)


This method saves the currently displayed image if <video_id> as a *.bmp file. <output> is the path to the file you want to save the image to. Obviously, this file doesn't have to already exist.
If you have some text overlayed on the video due to a call of OverlayText, it will be saved on the <output> *.bmp file.
If you want to ScreenCapture an image without having to display the video, you can use LoadVideo with the <hide> value set to 1.

Possible errors:

"DSV4B:WrongID", "The input ID is incorrect"



	void SetForeground(int video_id)


For the <video_id>, set the windows foreground. If <video_id> is 0, all windows will be placed foreground.

Possible errors:

"DSV4B:WrongID", "The input ID is incorrect"