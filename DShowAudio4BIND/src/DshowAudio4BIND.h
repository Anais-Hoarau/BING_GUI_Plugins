#ifndef DSHOWAUDIO4BIND_H
#define DSHOWAUDIO4BIND_H
#endif

// Ratio between time used in BIND and time used in DirectShow
#define TIME_RATIO 10000 //000
// Maximum length of the path to the videofile
#define MAX_PATH_LENGTH 1000


// ------------
// Interface
// ------------


// Load audio, i.e. create the object audio and store it in the static map. Return the key to the object
// in the map
extern "C" __declspec(dllexport) int __cdecl LoadAudio(char* audiofile);

// Play <audio_id>
extern "C" __declspec(dllexport) void __cdecl Play(int audio_id);

// Pause <audio_id>
extern "C" __declspec(dllexport) void __cdecl Pause(int audio_id);

// Set position of <audio_id> to <position>, that is in SECONDS
extern "C" __declspec(dllexport) void __cdecl SetPosition(int audio_id, long long position);

// Unload audio, i.e. delete object and delete it from the map
extern "C" __declspec(dllexport) void __cdecl UnloadAudio(int audio_id);

// Return true if there are no more audio in the map, false else
extern "C" __declspec(dllexport) bool __cdecl NoMoreAudio();

// Set audio playback rate
extern "C" __declspec(dllexport) void __cdecl SetRate(int audio_id, double rate);


// ---------------
// AudioPlayer 
// ---------------


class AudioPlayer
{
public:
	// Constructor
	AudioPlayer(char* audiofile);

	// Default constructor, needed for the map storage
	AudioPlayer();

	// Destructor
	~AudioPlayer();

	// Play audio
	void Play();

	// Pause audio
	void Pause();

	// Set position for the audio, <position> is in TimeFormat
	void SetPosition(REFERENCE_TIME position);

	// Return true if we can seek through the audio, false else
	bool CanSeek();

	// Set audio playback rate
	void SetRate(double rate);

private:
	IGraphBuilder *pGraph;
	IFilterGraph2 *pGraph2;
	IMediaControl *pControl;
	IMediaSeeking *pSeek;

	IBaseFilter *pSource;
	IBaseFilter *pAviSplitter;
	IBaseFilter *pAudioRenderer;
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