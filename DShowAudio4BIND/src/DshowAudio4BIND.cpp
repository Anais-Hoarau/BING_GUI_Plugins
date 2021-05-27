// DshowAudio4BIND.cpp : définit le point d'entrée pour l'application DLL.
//

#include "stdafx.h"
#include "DShow.h"
#include "DshowAudio4BIND.h"
#include <map>
#include <string>
#include "wchar.h"
#include <iostream>
#include "mex.h"

using namespace std;

// Map storing audio objects
static map <int, AudioPlayer*> mAudioPlayers;

BOOL APIENTRY DllMain (HINSTANCE hInst, DWORD reason, LPVOID reserved)
{
   switch (reason)
   {
     case DLL_PROCESS_ATTACH:
       break;
     case DLL_PROCESS_DETACH:
       break;
     case DLL_THREAD_ATTACH:
       break;
     case DLL_THREAD_DETACH:
       break;
   }
   return TRUE;
}


// ------------
// Interface
// ------------


__declspec(dllexport) int __cdecl LoadAudio(char* audiofile)
{
	AudioPlayer *audio = new AudioPlayer(audiofile);
	// If we can't seek through video ...
	if(audio->CanSeek())
	{
		int audio_id;
		if(mAudioPlayers.begin() == mAudioPlayers.end())
		{	audio_id = 1;	}
		else
		{	audio_id = mAudioPlayers.rbegin()->first+1;	}
		mAudioPlayers.insert(pair <int, AudioPlayer*> (audio_id, audio));
		return audio_id;
	}
	// ... we close it
	else
	{
		{mexErrMsgIdAndTxt("DSA4B:NoSeekable", "The input media doesn't have seeking capabilities");}
		delete audio;
		return -1;
	}
}

__declspec(dllexport) void __cdecl UnloadAudio(int audio_id)
{
	// Audio exists
	if(mAudioPlayers.find(audio_id) != mAudioPlayers.end())
	{
		delete mAudioPlayers[audio_id];
		mAudioPlayers.erase(audio_id);
	}
	else
	{mexErrMsgIdAndTxt("DSA4B:WrongID", "The input ID is incorrect");}
}

__declspec(dllexport) void __cdecl Play(int audio_id)
{
	// Audio exists
	if(mAudioPlayers.find(audio_id) != mAudioPlayers.end())
	{
		mAudioPlayers[audio_id]->Play();
	}
	else
	{mexErrMsgIdAndTxt("DSA4B:WrongID", "The input ID is incorrect");}
}


__declspec(dllexport) void __cdecl Pause(int audio_id)
{
	// Audio exists
	if(mAudioPlayers.find(audio_id) != mAudioPlayers.end())
	{
		mAudioPlayers[audio_id]->Pause();
	}
	else
	{mexErrMsgIdAndTxt("DSA4B:WrongID", "The input ID is incorrect");}
}

__declspec(dllexport) void __cdecl SetPosition(int audio_id, long long position)
{
	// Convert position into TimeFormat
	REFERENCE_TIME rt_pos = TIME_RATIO * position;
	// Audio exists
	if(mAudioPlayers.find(audio_id) != mAudioPlayers.end())
	{	mAudioPlayers[audio_id]->SetPosition(rt_pos);	}
	else
	{mexErrMsgIdAndTxt("DSA4B:WrongID", "The input ID is incorrect");}
}

__declspec(dllexport) bool __cdecl NoMoreAudio()
{
	if(mAudioPlayers.end() == mAudioPlayers.begin())
	{	return true;	}
	else
	{	return false;	}
}

__declspec(dllexport) void __cdecl SetRate(int audio_id, double rate)
{
	if(rate <= 0)
	{mexErrMsgIdAndTxt("DSA4B:WrongRate", "Rate must be > 0");}

	// Audio exists
	if(mAudioPlayers.find(audio_id) != mAudioPlayers.end())
	{
		mAudioPlayers[audio_id]->SetRate(rate);
	}
	else
	{mexErrMsgIdAndTxt("DSA4B:WrongID", "The input ID is incorrect");}
}

// ---------------
// AudioPlayer 
// ---------------


AudioPlayer::AudioPlayer(char* audiofile)
{
	pGraph = NULL;
	pGraph2 = NULL;
	pControl = NULL;
	pSeek = NULL;

	pSource = NULL;
	pAviSplitter = NULL;
	pAudioRenderer = NULL;

	HRESULT hr;

	// Initialize the COM library
	hr = CoInitialize(NULL);

	if (FAILED(hr))
	{mexErrMsgIdAndTxt("DSA4B:InitializingLibraryErr", "Could not initialize COM library");}

	// Create the Filter Graph Manager
	hr = CoCreateInstance(CLSID_FilterGraph, NULL, CLSCTX_INPROC_SERVER, IID_IGraphBuilder, (void **)&pGraph);

	if (FAILED(hr))
	{mexErrMsgIdAndTxt("DSA4B:CreateFilterGraphManagerErr", "Could not create the Filter Graph Manager");}

	// Retrieve pointer to the streaming control object
	pGraph->QueryInterface(IID_IMediaControl, (void **)&pControl);

	// Create Filter Graph 2
	pGraph->QueryInterface(IID_IFilterGraph2, (void**)&pGraph2);

	// Create video controls
	pGraph->QueryInterface(IID_IMediaSeeking, (void **)&pSeek);

	// Set time format
	GUID time_format = TIME_FORMAT_MEDIA_TIME;

	pSeek->SetTimeFormat(&time_format);

	// Build the filter graph that renders videofile
	WCHAR* w_audiofile = new WCHAR[MAX_PATH_LENGTH];
	size_t outSize;
	mbstowcs_s(&outSize, w_audiofile, MAX_PATH_LENGTH, audiofile, MAX_PATH_LENGTH - 1);

	// If it's wav
	if(!string(audiofile).find(".wav"))
	{
		hr = pGraph->RenderFile(w_audiofile, NULL);

		if (FAILED(hr))
		{mexErrMsgIdAndTxt("DSA4B:CantOpenFile", "Could not open the input file");}
	}
	// If it's avi
	{
		hr = pGraph->AddSourceFilter(w_audiofile, NULL, &pSource);

		if (FAILED(hr))
		{mexErrMsgIdAndTxt("DSA4B:CantOpenFile", "Could not open the input file");}

		// Add AVI Splitter filter
		AddFilterByCLSID(pGraph, CLSID_AviSplitter, &pAviSplitter, L"AVI Splitter");

		// Add Audio Renderer filter
		AddFilterByCLSID(pGraph, CLSID_DSoundRender, &pAudioRenderer, L"Audio Renderer");

		// Get pins for source
		IEnumPins *pEnum = NULL;

		pSource->EnumPins(&pEnum);

		IPin *pPin = NULL;

		while (S_OK == pEnum->Next(1, &pPin, NULL))
		{			
			// Try to render this pin. 
			// It's OK if we fail some pins, if at least one pin renders.
			pGraph2->RenderEx(pPin, AM_RENDEREX_RENDERTOEXISTINGRENDERERS, NULL);

			pPin->Release();
		}

		pEnum->Release();
	}
	// pControl->Run();

	delete(w_audiofile);
}

AudioPlayer::AudioPlayer()
{
	pGraph = NULL;
	pGraph2 = NULL;
	pControl = NULL;
	pSeek = NULL;

	pSource = NULL;
	pAviSplitter = NULL;
	pAudioRenderer = NULL;
}


AudioPlayer::~AudioPlayer()
{
	pControl->Stop();

	pAudioRenderer->Release();
	pAviSplitter->Release();
	pSource->Release();

	pSeek->Release();
	pControl->Release();
	pGraph2->Release();
	pGraph->Release();

	CoUninitialize();
}

void AudioPlayer::Play()
{
	pControl->Run();
}

void AudioPlayer::Pause()
{
	pControl->Pause();
}

void AudioPlayer::SetPosition(REFERENCE_TIME position)
{
	pControl->Pause();
	pSeek->SetPositions(&position, AM_SEEKING_AbsolutePositioning, NULL, AM_SEEKING_NoPositioning);
}

bool AudioPlayer::CanSeek()
{
	DWORD dwCaps = AM_SEEKING_CanSeekAbsolute;
	HRESULT hr = pSeek->CheckCapabilities(&dwCaps);
	if(FAILED(hr))
	{	return false;	}
	else
	{	return true;	}
}

void AudioPlayer::SetRate(double rate)
{
	pSeek->SetRate(rate);
}


// ---------
// Tools 
// ---------

HRESULT AddFilterByCLSID(IGraphBuilder *pGraph, REFGUID clsid, IBaseFilter **ppF, LPCWSTR wszName)
{
    *ppF = 0;

    IBaseFilter *pFilter = NULL;
    
    HRESULT hr = CoCreateInstance(clsid, NULL, CLSCTX_INPROC_SERVER, 
        IID_PPV_ARGS(&pFilter));
    if (FAILED(hr))
    {
        goto done;
    }

    hr = pGraph->AddFilter(pFilter, wszName);
    if (FAILED(hr))
    {
        goto done;
    }

    *ppF = pFilter;
    (*ppF)->AddRef();

done:
    pFilter->Release();
    return hr;
}