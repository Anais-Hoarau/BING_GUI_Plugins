// DshowVideo4BIND.cpp : définit le point d'entrée pour l'application DLL.
//

#include "stdafx.h"
#include "hWnd_DshowVideo4BIND.h"

HBRUSH newBrush = 0;

// Map storing video objects
static map <int, VideoPlayer*> mVideoPlayers;

BOOL APIENTRY DllMain (HINSTANCE hInst, DWORD reason, LPVOID reserved)
{
	hIns = hInst;

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


__declspec(dllexport) int __cdecl LoadVideo(char* videofile, int hide, char* wdwName)
{
	VideoPlayer *video = new VideoPlayer(videofile, hide, wdwName);
	// If we can't seek through video ...
	if(video->CanSeek())
	{
		int video_id;
		if(mVideoPlayers.begin() == mVideoPlayers.end())
		{	video_id = 1;	}
		else
		{	video_id = mVideoPlayers.rbegin()->first+1;	}
		mVideoPlayers.insert(pair <int, VideoPlayer*> (video_id, video));
		mVideoPlayers[video_id]->DisplayVideoWindow();
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

__declspec(dllexport) void __cdecl SetPosition(int video_id, long long position)
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

__declspec(dllexport) long long __cdecl GetDuration(int video_id)
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
		{	(*it).second->OverlayText(text, position, font_width, rgb);	}
	}
	else
	{
		// Video exists
		if(mVideoPlayers.find(video_id) != mVideoPlayers.end())
		{	mVideoPlayers[video_id]->OverlayText(text, position, font_width, rgb);	}
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
	HRESULT hr;

	pGraph = NULL;
	pGraph2 = NULL;

	pControl = NULL;
	pSeek = NULL;

	pBmp = NULL;
	pFconf = NULL;
	pWc = NULL;

	pSource = NULL;
	pVMR9 = NULL;

	for(int i = 0; i < 3; i++)
	{	overlay_text.color[i] = 0;	}
	overlay_text.position = string("top");
	overlay_text.text = string("");
	overlay_text.width = 11;


	// -----------------
	// Window creation 
	// -----------------


	// Class name
	const wchar_t* className = L"DSV4B_wdw";

	// Window name
	WCHAR* w_wdw_name = new WCHAR[MAX_PATH_LENGTH];
	mbstowcs(w_wdw_name, wdw_name, MAX_PATH_LENGTH);
	
	this->wdw_name = w_wdw_name;

	WNDCLASSEX wc;

	// WNDCLASSEX initialization
    wc.cbSize        = sizeof(WNDCLASSEX);
    wc.style         = CS_NOCLOSE;
    wc.lpfnWndProc   = MainWndProc;
    wc.cbClsExtra    = 0;
    wc.cbWndExtra    = 0;
    wc.hInstance     = hIns;
    wc.hIcon         = LoadIcon(NULL, IDI_APPLICATION);
    wc.hCursor       = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
    wc.lpszMenuName  = NULL;
    wc.lpszClassName = className;
    wc.hIconSm       = LoadIcon(NULL, IDI_APPLICATION);

	RegisterClassEx(&wc);

	// Window creation
	hwndApp = CreateWindowEx(
				WS_EX_CLIENTEDGE,
				className,
				w_wdw_name,
				WS_OVERLAPPEDWINDOW,
				CW_USEDEFAULT, CW_USEDEFAULT, 800, 600,
				NULL, NULL, hIns, NULL);

	newBrush = CreateSolidBrush(RGB(0,0,0));
	SetClassLongPtr(hwndApp, GCLP_HBRBACKGROUND, (long)newBrush);


	// ---------------
	// Video loading 
	// ---------------


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

	// Set windowless mode
	pFconf->SetRenderingMode(VMR9Mode_Windowless);

	// Windowsless controls
	pVMR9->QueryInterface(IID_IVMRWindowlessControl9, (void**)&pWc);

	// Set hwndApp as the video window
	pWc->SetVideoClippingWindow(hwndApp); 

	// Set Max number of steams to mix to 2
	//pFconf->SetNumberOfStreams(4);

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

	pBmp = NULL;
	pFconf = NULL;
	pWc = NULL;

	pSource = NULL;
	pVMR9 = NULL;

	wdw_name = L"Video";

	hwndApp = NULL;

	for(int i = 0; i < 3; i++)
	{	overlay_text.color[i] = 0;	}
	overlay_text.position = string("top");
	overlay_text.text = string("");
	overlay_text.width = 11;
}

VideoPlayer::~VideoPlayer()
{
	pGraph->Release();
	pGraph2->Release();

	pSeek->Release();
	pControl->Release();

	pFconf->Release();
	pBmp->Release();
	pWc->Release();

	pSource->Release();
	pVMR9->Release();

	CoUninitialize();
	
	DeleteObject(newBrush);
	DestroyWindow(hwndApp);
}

void VideoPlayer::SetPosition(REFERENCE_TIME position)
{
	pControl->Pause();
	pSeek->SetPositions(&position, AM_SEEKING_AbsolutePositioning, NULL, AM_SEEKING_NoPositioning);
	UpdateWindow(hwndApp);
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


void VideoPlayer::OverlayText(char *text, char *position, int font_width, int rgb[3])
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
		RECT rc;
		GetWindowRect(hwndApp, &rc);

		long left = rc.left;
		long top = rc.top;
		long width = rc.right - rc.left;
		long height = rc.bottom - rc.top;

		// Convert text to display to wchar_t
		wchar_t *wstr = new wchar_t[1000];
		mbstowcs(wstr, text, 1000);
		
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
		if(rgb[0] == 255 && rgb[1] == 255 && rgb[2] == 255)
		{mexErrMsgIdAndTxt("DSV4B:WrongColor", "White can't be used as font color");}
		SetTextColor(hdcBmp, RGB(rgb[0], rgb[1], rgb[2]));

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

		for(int i = 0; i < 3; i++)
		{	overlay_text.color[i] = rgb[i];	}
		overlay_text.position = string(position);
		overlay_text.text = string(text);
		overlay_text.width = font_width;

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

	BYTE *pDIBImage = NULL;
	pWc->GetCurrentImage(&pDIBImage);

	BITMAPINFOHEADER *pBMIH = (BITMAPINFOHEADER*) pDIBImage;
	BITMAPFILEHEADER bmphdr;

//	memset(&bmphdr, 0, sizeof(bmphdr));

	bmphdr.bfType = 0x4D42;
	bmphdr.bfSize = sizeof(bmphdr) + pBMIH->biSizeImage;
	bmphdr.bfOffBits = sizeof(bmphdr);

	int file = _lcreat(s_output.c_str(), 0);
	_lwrite(file, (const char*)&bmphdr, sizeof(bmphdr));
	_lwrite(file, (const char*)pDIBImage, pBMIH->biSizeImage + sizeof(BITMAPINFO));

	_lclose(file);

	CoTaskMemFree(pDIBImage);
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

	long x = 0;
	long y = 0;

	// Get screen resolution
	RECT screen_res;
	GetWindowRect(GetDesktopWindow(), &screen_res);

	// Get video resolution
	RECT rc;
	GetWindowRect(hwndApp, &rc);

	long left = rc.left;
	long top = rc.top;
	long width = rc.right - rc.left;
	long height = rc.bottom - rc.top;
	
	// If video is smaller than screen
	if(width < screen_res.right && height < screen_res.bottom)
	{
		switch (positions[position])
		{
		// North
		case 1:
			x = (screen_res.right / 2) - (width / 2);
			if(height < (screen_res.bottom / 3))
			{	y = (screen_res.bottom / 6) - (height / 2);	}
			else
			{	y = 0;	}
			break;

		// South
		case 2 :
			x = (screen_res.right / 2) - (width / 2);
			if(height < (screen_res.bottom / 3))
			{	y = (screen_res.bottom * 5 / 6) - (height / 2);	}
			else
			{	y = screen_res.bottom - height;	}
			break;

		// East
		case 3:
			if(width < (screen_res.right / 3))
			{	x = (screen_res.right * 5 / 6) - (width / 2);	}
			else
			{	x = screen_res.right - width;	}
			y = (screen_res.bottom / 2) - (height / 2);
			break;

		// West
		case 4 :
			if(width < (screen_res.right / 3))
			{	x = (screen_res.right / 6) - (width / 2);	}
			else
			{	x = 0;	}
			y = (screen_res.bottom / 2) - (height / 2);
			break;

		// Northeast
		case 5:
			if(width < (screen_res.right / 3))
			{	x = (screen_res.right * 5 / 6) - (width / 2);	}
			else
			{	x = screen_res.right - width;	}
			if(height < (screen_res.bottom / 3))
			{	y = (screen_res.bottom / 6) - (height / 2);	}
			else
			{	y = 0;	}
			break;

		// Northwest
		case 6 :
			if(width < (screen_res.right / 3))
			{	x = (screen_res.right / 6) - (width / 2);	}
			else
			{	x = 0;	}
			if(height < (screen_res.bottom / 3))
			{	y = (screen_res.bottom / 6) - (height / 2);	}
			else
			{	y = 0;	}
			break;

		// Southeast
		case 7:
			if(width < (screen_res.right / 3))
			{	x = (screen_res.right * 5 / 6) - (width / 2);	}
			else
			{	x = screen_res.right - width;	}
			if(height < (screen_res.bottom / 3))
			{	y = (screen_res.bottom * 5 / 6) - (height / 2);	}
			else
			{	y = screen_res.bottom - height;	}
			break;

		// Southwest
		case 8 :
			if(width < (screen_res.right / 3))
			{	x = (screen_res.right / 6) - (width / 2);	}
			else
			{	x = 0;	}
			if(height < (screen_res.bottom / 3))
			{	y = (screen_res.bottom * 5 / 6) - (height / 2);	}
			else
			{	y = screen_res.bottom - height;	}
			break;

		// Center
		case 9:
			x = (screen_res.right / 2) - (width / 2);
			y = (screen_res.bottom / 2) - (height / 2);
			break;

		// Default
		default:
			break;
		}
	}

	SetWindowPos(hwndApp, HWND_BOTTOM, x, y, width, height, NULL);
}

void VideoPlayer::SetForeground()
{
	SetForegroundWindow(hwndApp);
}

HWND VideoPlayer::GetHwnd()
{
	return hwndApp;
}

Overlay VideoPlayer::GetOverlay()
{
	return overlay_text;
}

REFERENCE_TIME VideoPlayer::GetDuration()
{	
	REFERENCE_TIME totalTime;
	pSeek->GetDuration(&totalTime);
	return totalTime;
}

void VideoPlayer::AdjustVideoSize()
{
	long lpWidth, lpHeight, lpARWidth, lpARHeight;
	RECT rcSrc, rcDest; 

	// Get the video size
	pWc->GetNativeVideoSize(&lpWidth, &lpHeight, &lpARWidth, &lpARHeight);
	// Set the source rectangle
	SetRect(&rcSrc, 0, 0, lpWidth, lpHeight); 

	// Get the window client area
	GetClientRect(hwndApp, &rcDest); 
	// Set the destination rectangle
	SetRect(&rcDest, 0, 0, rcDest.right, rcDest.bottom); 

	// Set the new position
	pWc->SetVideoPosition(&rcSrc, &rcDest);
}

void VideoPlayer::DisplayVideoWindow()
{
	AdjustVideoSize();
	ShowWindow(hwndApp, SW_SHOW);
	SetForeground();
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

LRESULT CALLBACK MainWndProc(
    HWND hwnd,        // handle to window
    UINT uMsg,        // message identifier
    WPARAM wParam,    // first message parameter
    LPARAM lParam)    // second message parameter
{ 
	map <int, VideoPlayer*>::iterator it;
	Overlay overlay_text;

    switch (uMsg) 
    { 
		case WM_CREATE: 
            return 0; 

		case WM_SIZING:
			return 0;

		case WM_MOVING:
			return 0;

		case WM_ENTERSIZEMOVE:
			return 0;

		case WM_WINDOWPOSCHANGING :
			return 0;
 
        case WM_SIZE: 
            // Set the size and position of the window. 
			for(it = mVideoPlayers.begin(); it != mVideoPlayers.end() && hwnd != (*it).second->GetHwnd(); ++it)
			{}

			if(hwnd == (*it).second->GetHwnd())
			{	
				(*it).second->AdjustVideoSize();
				overlay_text = (*it).second->GetOverlay();
				if(!overlay_text.text.empty())
				{
					(*it).second->OverlayText(	(char*) overlay_text.text.c_str(), 
												(char*) overlay_text.position.c_str(),
												overlay_text.width,
												overlay_text.color);
				}
			}
            return 0; 
 
		default: 
			return DefWindowProc(hwnd, uMsg, wParam, lParam); 
    } 
    return 0; 
} 