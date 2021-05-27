var app = new Avidemux();

if (app.video == null)
    displayError("A video file must be open to use this Configuration");
else
{

//app.clearSegments();

//** Postproc **
app.video.setPostProc(3,3,0);

app.video.fps1000 = 25000;

//** Filters **
app.video.addFilter("resize","w=640","h=480","algo=2");
//** Video Codec conf **
app.video.codecPlugin("075E8A4E-5B3D-47c6-9F70-853D6B855106", "avcodec", "CQ=4", "<?xml version='1.0'?><MjpegConfig><presetConfiguration><name>&lt;default&gt;</name><type>default</type></presetConfiguration><MjpegOptions/></MjpegConfig>");

//** Audio **
app.audio.reset();
app.audio.codec("Lame",128,20,"80 00 00 00 00 00 00 00 01 00 00 00 02 00 00 00 00 00 00 00 ");
app.audio.normalizeMode=0;
app.audio.normalizeValue=0;
app.audio.delay=0;
app.audio.mixer="NONE";
app.setContainer("AVI");
setSuccess(1);
	

}
