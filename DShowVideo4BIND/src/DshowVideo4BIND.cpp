// DshowVideo4BIND.cpp : définit le point d'entrée pour l'application DLL.
//

#include "stdafx.h"
#include "DshowVideo4BIND.h"

// Map storing video objects
static map <int, VideoPlayer*> mVideoPlayers;

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


__declspec(dllexport) int __cdecl LoadVideo(char* videofile, int hide, char* wdw_name)
{
	VideoPlayer *video = new VideoPlayer(videofile, hide, wdw_name);
	// If we can't seek through video ...
	if(video->CanSeek())
	{
		int video_id;
		if(mVideoPlayers.begin() == mVideoPlayers.end())
		{	video_id = 1;	}
		else
		{	video_id = mVideoPlayers.rbegin()->first+1;	}
		mVideoPlayers.insert(pair <int, VideoPlayer*> (video_id, video));
		return video_id;
	}
	// ... we close it
	else
	{
		delete video;
		return -1;
		{mexErrMsgIdAndTxt("DSV4B:NoSeekable", "The input media doesn't have seeking capabilities");}
	}
}

__declspec(dllexport) void __cdecl SetPosition(int video_id, float position)
{
	// Convert position into TimeFormat
	REFERENCE_TIME rt_pos = TIME_RATIO * position;
	// Video exists
	if(mVideoPlayers.find(video_id) != mVideoPlayers.end())
	{	mVideoPlayers[video_id]->SetPosition(rt_pos);	}
	else
	{mexErrMsgIdAndTxt("DSV4B:WrongID", "The input ID is incorrect");}
}

__declspec(dllexport) void __cdecl UnloadVideo(int video_id)
{
	// Video exists
	if(mVideoPlayers.find(video_id) != mVideoPlayers.end())
	{
		delete mVideoPlayers[video_id];
		mVideoPlayers.erase(video_id);
	}
	else
	{mexErrMsgIdAndTxt("DSV4B:WrongID", "The input ID is incorrect");}
}

__declspec(dllexport) float __cdecl GetDuration(int video_id)
{
	// Video exists
	if(mVideoPlayers.find(video_id) != mVideoPlayers.end())
	{	
		float duration = mVideoPlayers[video_id]->GetDuration();
		duration = duration/TIME_RATIO;
		return duration;
	}
	else
	{	
		{mexErrMsgIdAndTxt("DSV4B:WrongID", "The input ID is incorrect");}
		return -1;
	}
}

__declspec(dllexport) bool __cdecl NoMoreVideo()
{
	if(mVideoPlayers.end() == mVideoPlayers.begin())
	{	return true;	}
	else
	{	return false;	}
}

__declspec(dllexport) void __cdecl SetWindowPosition(int video_id, char* wdw_pos)
{
	// Video exists
	if(mVideoPlayers.find(video_id) != mVideoPlayers.end())
	{	mVideoPlayers[video_id]->SetWindowPosition(wdw_pos);	}
	else
	{mexErrMsgIdAndTxt("DSV4B:WrongID", "The input ID is incorrect");}
}

__declspec(dllexport) void OverlayText(int video_id, char* text, char *position, int font_width, int rgb[3])
{
	if(video_id == 0)
	{
		map <int, VideoPlayer*>::iterator it;
		for(it = mVideoPlayers.begin(); it != mVideoPlayers.end(); ++it)
		{	(*it).second->OverlayText(text, position, font_width, rgb[0], rgb[1], rgb[2]);	}
	}
	else
	{
		// Video exists
		if(mVideoPlayers.find(video_id) != mVideoPlayers.end())
		{	mVideoPlayers[video_id]->OverlayText(text, position, font_width, rgb[0], rgb[1], rgb[2]);	}
		else
		{mexErrMsgIdAndTxt("DSV4B:WrongID", "The input ID is incorrect");}
	}
}

__declspec(dllexport) void ScreenCapture(int video_id, char* output)
{
	// Video exists
	if(mVideoPlayers.find(video_id) != mVideoPlayers.end())
	{	mVideoPlayers[video_id]->ScreenCapture(output);	}
	else
	{mexErrMsgIdAndTxt("DSV4B:WrongID", "The input ID is incorrect");}
}

__declspec(dllexport) void SetForeground(int video_id)
{
	if(video_id == 0)
	{
		map <int, VideoPlayer*>::iterator it;
		for(it = mVideoPlayers.begin(); it != mVideoPlayers.end(); ++it)
		{	(*it).second->SetForeground();	}
	}
	else
	{
		// Video exists
		if(mVideoPlayers.find(video_id) != mVideoPlayers.end())
		{	mVideoPlayers[video_id]->SetForeground();	}
		else
		{mexErrMsgIdAndTxt("DSV4B:WrongID", "The input ID is incorrect");}
	}
}

// ---------------
// VideoPlayer 
// ---------------


VideoPlayer::VideoPlayer(char* videofile, int hide, char* wdw_name)
{
	pGraph = NULL;
	pControl = NULL;
	pSeek = NULL;
	pVW = NULL;
	pBV = NULL;
	pSource = NULL;
	pVMR9 = NULL;
	pGraph2 = NULL;
	pBmp = NULL;
	pFconf = NULL;

	HRESULT hr;

	// Initialize the COM library
	hr = CoInitialize(NULL);

	if (FAILED(hr))
	{mexErrMsgIdAndTxt("DSV4B:InitializingLibraryErr", "Could not initialize COM library");}
	

	// Create the Filter Graph Manager
	hr = CoCreateInstance(CLSID_FilterGraph, NULL, CLSCTX_INPROC_SERVER, IID_IGraphBuilder, (void **)&pGraph);

	if (FAILED(hr))
	{mexErrMsgIdAndTxt("DSV4B:CreateFilterGraphManagerErr", "Could not create the Filter Graph Manager");}

	// Retrieve pointer to the streaming control object
	pGraph->QueryInterface(IID_IMediaControl, (void **)&pControl);

	// Create Filter Graph 2
	pGraph->QueryInterface(IID_IFilterGraph2, (void**)&pGraph2);

	// Create video controls
	pGraph->QueryInterface(IID_IMediaSeeking, (void **)&pSeek);

	// Create window controls (used in ScreenCapture)
	pGraph->QueryInterface(IID_IBasicVideo, (void **)&pBV);

	// Create window controls
	pGraph->QueryInterface(IID_IVideoWindow, (void **)&pVW);

	// Build the filter graph that renders videofile
	WCHAR* w_videofile = new WCHAR[MAX_PATH_LENGTH];
	mbstowcs(w_videofile, videofile, MAX_PATH_LENGTH);

	hr = pGraph->AddSourceFilter(w_videofile, NULL, &pSource);
	//hr = pGraph->RenderFile(w_videofile, NULL);

	delete(w_videofile);

	if (FAILED(hr))
	{mexErrMsgIdAndTxt("DSV4B:CantOpenFile", "Could not open the input file");}

	// Add AVI Splitter filter
	AddFilterByCLSID(pGraph, CLSID_VideoMixingRenderer9, &pVMR9, L"VMR9");

	// VMR Mixer Interface (used for overlay)
	pVMR9->QueryInterface(IID_IVMRMixerBitmap9, (void **)&pBmp);

	// VMR Filter Config Interface (used for overlay)
	pVMR9->QueryInterface(IID_IVMRFilterConfig9, (void**)&pFconf);

	// Optionnal: set windowed mode
	pFconf->SetRenderingMode(VMR9Mode_Windowed);

	// Set Max number of steams to mix to 2
	pFconf->SetNumberOfStreams(4);

	// Get pins for source
	IEnumPins *pEnum = NULL;

	pSource->EnumPins(&pEnum);

	IPin *pPin = NULL;

	while (S_OK == pEnum->Next(1, &pPin, NULL))
	{			
		// Try to render this pin. 
		// It's OK if we fail some pins, if at least one pin renders.
		hr = pGraph2->RenderEx(pPin, AM_RENDEREX_RENDERTOEXISTINGRENDERERS, NULL);

		pPin->Release();
	}

	pEnum->Release();

	WCHAR* w_wdw_name = new WCHAR[MAX_PATH_LENGTH];
	mbstowcs(w_wdw_name, wdw_name, MAX_PATH_LENGTH);

	this->wdw_name = w_wdw_name;

	// Show window
	if(!hide)
	{
		BSTR bstr_wdw_name = SysAllocString(w_wdw_name);
		pVW->put_Visible(OATRUE);
		pVW->put_WindowStyle(WS_TILEDWINDOW);
		pVW->SetWindowForeground(OATRUE);
		pVW->put_Caption(bstr_wdw_name);
		SysFreeString(bstr_wdw_name);
	}
	// Hide window
	else
	{
		pVW->put_Visible(OAFALSE);
		pVW->put_AutoShow(OAFALSE);
	}

	delete(w_wdw_name);

	// Set time format
	GUID time_format = TIME_FORMAT_MEDIA_TIME;
	pSeek->SetTimeFormat(&time_format);
}

VideoPlayer::VideoPlayer()
{
	pGraph = NULL;
	pGraph2 = NULL;

	pControl = NULL;
	pSeek = NULL;
	pVW = NULL;
	pBV = NULL;

	pSource = NULL;
	pVMR9 = NULL;

	pBmp = NULL;
	pFconf = NULL;
}

void VideoPlayer::SetPosition(REFERENCE_TIME position)
{
	pControl->Pause();
	pSeek->SetPositions(&position, AM_SEEKING_AbsolutePositioning, NULL, AM_SEEKING_NoPositioning);
}

bool VideoPlayer::CanSeek()
{
	DWORD dwCaps = AM_SEEKING_CanSeekAbsolute;
	HRESULT hr = pSeek->CheckCapabilities(&dwCaps);
	if(FAILED(hr))
	{	return false;	}
	else
	{	return true;	}
}

REFERENCE_TIME VideoPlayer::GetDuration()
{
	REFERENCE_TIME totalTime = 0;
	pSeek->GetDuration(&totalTime);
	return totalTime;
}


void VideoPlayer::OverlayText(char *text, char *position, int font_width, int r_rgb, int g_rgb, int b_rgb)
{
	string s_text = string(text);
	VMR9AlphaBitmap alpha_bitmap;
	// text is empty: clear overlay
	if(s_text.empty())
	{
		alpha_bitmap.dwFlags = VMR9AlphaBitmap_Disable;
		pBmp->SetAlphaBitmap(&alpha_bitmap); 
	}
	// text is not empty: overlay
	else
	{
		HDC hdc, hdcBmp;
		HBITMAP hbmp, hbmpold;
		RECT r;
		SIZE sz;

		// Create font for the overlay
		HFONT overlayFont = CreateFont(
		font_width*16/9,		//nHeight
		font_width,				//nWidth
		0,						//nEscapement
		0,						//nOrientation
		600,					//fnWeight
		0,						//fdwItalic
		0,						//fdwUnderline
		0,						//fdwStrikeOut
		ANSI_CHARSET,			//fdwCharSet
		OUT_DEFAULT_PRECIS,		//fdwOutputPrecision
		CLIP_DEFAULT_PRECIS,	//fdwClipPrecision
		ANTIALIASED_QUALITY,	//fdwQuality
		FIXED_PITCH | FF_MODERN,//fdwPitchAndFamily
		L"Arial");		//lpszFace

		// Get video resolution
		long left, top, width, height;
		pVW->GetWindowPosition(&left, &top, &width, &height);

//		if(string(text).length()*9 > width)
//		{mexErrMsgIdAndTxt("DSV4B:TooManyChars", "Too many characters to overlay");}

		// Convert text to display to wchar_t
		wchar_t *wstr = new wchar_t[100];
		mbstowcs(wstr, text, 100);

		//pVW->SetWindowForeground(OATRUE);
		//HWND hwndApp = GetForegroundWindow();
		HWND hwndApp = FindWindow(NULL, wdw_name);
		
		// Get the handle to the GDI device
		hdc = GetDC(hwndApp);
		hdcBmp = CreateCompatibleDC(hdc);

		// Bitmap building
		SelectFont(hdcBmp, overlayFont);
		GetTextExtentPoint32(hdcBmp, wstr, wcslen(wstr), &sz);
		hbmp = CreateCompatibleBitmap(hdc, sz.cx, sz.cy);

		ReleaseDC(hwndApp, hdc);

		// Associate bitmap with HDC
		hbmpold = (HBITMAP)SelectObject(hdcBmp, hbmp);

		SetRect(&r, 0, 0, sz.cx, sz.cy);

		// Set colors
		SetBkColor(hdcBmp, RGB(255, 255, 255));
		if(r_rgb == 255 && b_rgb == 255 && g_rgb == 255)
		{mexErrMsgIdAndTxt("DSV4B:WrongColor", "White can't be used as font color");}
		SetTextColor(hdcBmp, RGB(r_rgb, g_rgb, b_rgb));

		// Write text
		DrawText(hdcBmp, wstr, lstrlen(wstr), &r, /*DT_NOCLIP | */DT_LEFT/* | DT_SINGLELINE | DT_NOPREFIX*/);

		// Initialize the VMR9AlphaBitmap
		ZeroMemory(&alpha_bitmap, sizeof(alpha_bitmap));

		alpha_bitmap.dwFlags = VMR9AlphaBitmap_hDC | VMR9AlphaBitmap_SrcColorKey;

		alpha_bitmap.hdc = hdcBmp;
		alpha_bitmap.rSrc = r;

		float width_ratio = sz.cx;
		width_ratio = width_ratio/width > 1 ? 1 : width_ratio/width;

		float height_ratio = sz.cy;
		height_ratio = height_ratio/height > 1 ? 1 : height_ratio/height;

		alpha_bitmap.rDest.left = 0.0f;
		alpha_bitmap.rDest.right = width_ratio*1.0f;

		// If position is top
		if(!string(position).compare("top"))
		{
			alpha_bitmap.rDest.top = 0.0f;
			alpha_bitmap.rDest.bottom = height_ratio*1.0f;
		}

		// Else it's bottom
		else
		{
			alpha_bitmap.rDest.top = 1.0f - height_ratio*1.0f;
			alpha_bitmap.rDest.bottom = 1.0f;
		}		

		alpha_bitmap.fAlpha = 1.0f;

		alpha_bitmap.clrSrcKey = RGB(255, 255, 255);

		// Set Bitmap
		pBmp->SetAlphaBitmap(&alpha_bitmap); 

		// Delete what we don't need anymore
		DeleteObject(hbmp);
		DeleteObject(hbmpold);
		DeleteObject(SelectObject(hdcBmp, hbmpold));
		DeleteDC(hdcBmp);
		DeleteDC(hdc);
		delete(wstr);
	}
}

void VideoPlayer::ScreenCapture(char* output)
{
	string s_output = string(output);
	if(s_output.find(".bmp") == -1)
	{	s_output += ".bmp"	;}
	long pBufferSize;
	pBV->GetCurrentImage(&pBufferSize, NULL);

	long *pDIBImage = new long[pBufferSize];
	pBV->GetCurrentImage(&pBufferSize, pDIBImage);

	BITMAPFILEHEADER bmphdr;
	long height, width;

	pBV->get_VideoHeight(&height);
	pBV->get_VideoWidth(&width);

	memset(&bmphdr, 0, sizeof(bmphdr));

	bmphdr.bfType = 0x4D42;
	bmphdr.bfSize = sizeof(bmphdr) + pBufferSize;
	bmphdr.bfOffBits = sizeof(bmphdr);

	int file = _lcreat(s_output.c_str(), 0);
	_lwrite(file, (const char*)&bmphdr, sizeof(bmphdr));
	_lwrite(file, (const char*)pDIBImage, pBufferSize);

	_lclose(file);

	delete(pDIBImage);
}

void VideoPlayer::SetWindowPosition(char* position)
{
	map <string, int> positions;

	positions["north"] = 1;
	positions["south"] = 2;
	positions["east"] = 3;
	positions["west"] = 4;
	positions["northeast"] = 5;
	positions["northwest"] = 6;
	positions["southeast"] = 7;
	positions["southwest"] = 8;
	positions["center"] = 9;

	string s_pos = string(position);
	long left_Pos = 0;
	long top_Pos = 0;

	// Get screen resolution
	RECT screen_res;
	GetWindowRect(GetDesktopWindow(), &screen_res);

	// Get video resolution
	long left, top, width, height;
	pVW->GetWindowPosition(&left, &top, &width, &height);
	
	// If video is smaller than screen
	if(width < screen_res.right && height < screen_res.bottom)
	{
		switch (positions[position])
		{
		// North
		case 1:
			left_Pos = (screen_res.right / 2) - (width / 2);
			if(height < (screen_res.bottom / 3))
			{	top_Pos = (screen_res.bottom / 6) - (height / 2);	}
			else
			{	top_Pos = 0;	}
			break;

		// South
		case 2 :
			left_Pos = (screen_res.right / 2) - (width / 2);
			if(height < (screen_res.bottom / 3))
			{	top_Pos = (screen_res.bottom * 5 / 6) - (height / 2);	}
			else
			{	top_Pos = screen_res.bottom - height;	}
			break;

		// East
		case 3:
			if(width < (screen_res.right / 3))
			{	left_Pos = (screen_res.right * 5 / 6) - (width / 2);	}
			else
			{	left_Pos = screen_res.right - width;	}
			top_Pos = (screen_res.bottom / 2) - (height / 2);
			break;

		// West
		case 4 :
			if(width < (screen_res.right / 3))
			{	left_Pos = (screen_res.right / 6) - (width / 2);	}
			else
			{	left_Pos = 0;	}
			top_Pos = (screen_res.bottom / 2) - (height / 2);
			break;

		// Northeast
		case 5:
			if(width < (screen_res.right / 3))
			{	left_Pos = (screen_res.right * 5 / 6) - (width / 2);	}
			else
			{	left_Pos = screen_res.right - width;	}
			if(height < (screen_res.bottom / 3))
			{	top_Pos = (screen_res.bottom / 6) - (height / 2);	}
			else
			{	top_Pos = 0;	}
			break;

		// Northwest
		case 6 :
			if(width < (screen_res.right / 3))
			{	left_Pos = (screen_res.right / 6) - (width / 2);	}
			else
			{	left_Pos = 0;	}
			if(height < (screen_res.bottom / 3))
			{	top_Pos = (screen_res.bottom / 6) - (height / 2);	}
			else
			{	top_Pos = 0;	}
			break;

		// Southeast
		case 7:
			if(width < (screen_res.right / 3))
			{	left_Pos = (screen_res.right * 5 / 6) - (width / 2);	}
			else
			{	left_Pos = screen_res.right - width;	}
			if(height < (screen_res.bottom / 3))
			{	top_Pos = (screen_res.bottom * 5 / 6) - (height / 2);	}
			else
			{	top_Pos = screen_res.bottom - height;	}
			break;

		// Southwest
		case 8 :
			if(width < (screen_res.right / 3))
			{	left_Pos = (screen_res.right / 6) - (width / 2);	}
			else
			{	left_Pos = 0;	}
			if(height < (screen_res.bottom / 3))
			{	top_Pos = (screen_res.bottom * 5 / 6) - (height / 2);	}
			else
			{	top_Pos = screen_res.bottom - height;	}
			break;

		// Center
		case 9:
			left_Pos = (screen_res.right / 2) - (width / 2);
			top_Pos = (screen_res.bottom / 2) - (height / 2);
			break;

		// Default
		default:
			break;
		}
	}

	pVW->put_Left(left_Pos);
	pVW->put_Top(top_Pos);
}

void VideoPlayer::SetForeground()
{
	long state;
	pVW->get_WindowState(&state);
	if(state == SW_MINIMIZE)
	{	pVW->put_WindowState(SW_RESTORE);	}
	if(state != SW_HIDE)
	{	pVW->SetWindowForeground(OATRUE);	}
}

VideoPlayer::~VideoPlayer()
{
	pGraph->Release();
	pSeek->Release();
	pControl->Release();
	pVW->Release();
	pBV->Release();
	pSource->Release();
	pVMR9->Release();
	pFconf->Release();
	pGraph2->Release();
	pBmp->Release();
	CoUninitialize();
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