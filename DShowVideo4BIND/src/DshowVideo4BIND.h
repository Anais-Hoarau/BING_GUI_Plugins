#ifndef DSHOWVIDEO4BIND_H
#define DSHOWVIDEO4BIND_H
#endif
#include "DShow.h"
#include "d3d9.h"
#include "Vmr9.h"
#include <mex.h>

#include <map>
#include <string>
#include "wchar.h"
#include <iostream>

using namespace std;

// Ratio between time used in BIND and time used in DirectShow
#define TIME_RATIO 10000000

// Maximum length of the path to the videofile
#define MAX_PATH_LENGTH 1000


// ------------
// Interface
// ------------


// Load video, i.e. create the object video and store it in the static map. Return the key to the object
// in the map
extern "C" __declspec(dllexport) int __cdecl LoadVideo(char* videofile, int hide, char* wdw_name);

// Set position of <video_id> to <position>, that is in SECONDS
extern "C" __declspec(dllexport) void __cdecl SetPosition(int video_id, float position);

// Unload video, i.e. delete object and delete it from the map
extern "C" __declspec(dllexport) void __cdecl UnloadVideo(int video_id);

// Return the duration of the video, in SECONDS
extern "C" __declspec(dllexport) float __cdecl GetDuration(int video_id);

// Return true if there are no more video in the map, false else
extern "C" __declspec(dllexport) bool __cdecl NoMoreVideo();

// Set windows position using BIND positionning
extern "C" __declspec(dllexport) void __cdecl SetWindowPosition(int video_id, char* wdw_pos);

// Overlay text on the <video_id>. If text is empty (''), clear the overlay. 
// <font_width> is the width used for the font of the overlayed text, in logical unit.
// If value is 0, default width is used.
// Color can either be "red", "blue" or "green"
extern "C" __declspec(dllexport) void __cdecl OverlayText(int video_id, char* text, char *position, int font_width, int rgb[3]);

// Capture the screen of <video_id> and save it to <output> in the *.bmp format.
extern "C" __declspec(dllexport) void __cdecl ScreenCapture(int video_id, char* output);

// Set video window foreground
extern "C" __declspec(dllexport) void __cdecl SetForeground(int video_id);


// ---------------
// VideoPlayer 
// ---------------


// Class to store the video object
class VideoPlayer
{
public:
	// Constructor
	VideoPlayer(char* videofile, int hide, char* wdw_name);

	// Default constructor, needed for the map storage
	VideoPlayer();

	// Destructor
	~VideoPlayer();

	// Set position for the video, <position> is in TimeFormat
	void SetPosition(REFERENCE_TIME position);

	// Getter for totalTime
	REFERENCE_TIME GetDuration();

	// Return true if we can seek through the video, false else
	bool CanSeek();

	// Set window position using BIND positionning
	void SetWindowPosition(char* position);

	// Capture the screen and save it to <output> in the *.bmp format.
	void ScreenCapture(char* output);

	// Overlay text on the <video_id>. If text is empty (''), clear the overlay. 
	// <font_width> is the width used for the font of the overlayed text, in logical unit.
	// If value is 0, default width is used.
	// Color can either be "red", "blue" or "green"
	void OverlayText(char *text, char *position, int font_width, int r_rgb, int g_rgb, int b_rgb);
	
	// Set video window foreground
	void SetForeground();

private:
	IGraphBuilder *pGraph;
	IFilterGraph2 *pGraph2;

	IMediaControl *pControl;
	IMediaSeeking *pSeek;
	IVideoWindow *pVW;
	IBasicVideo *pBV;

	IBaseFilter *pVMR9;
	IBaseFilter *pSource;

	IVMRMixerBitmap9 *pBmp;
	IVMRFilterConfig9 *pFconf;

	wchar_t* wdw_name;
};


// ---------
// Tools 
// ---------


HRESULT AddFilterByCLSID(
IGraphBuilder *pGraph,      // Pointer to the Filter Graph Manager.
REFGUID clsid,              // CLSID of the filter to create.
IBaseFilter **ppF,          // Receives a pointer to the filter.
LPCWSTR wszName             // A name for the filter (can be NULL).
);