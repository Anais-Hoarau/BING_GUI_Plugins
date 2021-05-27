function hline = vcursor(hAxes,pos,callback, style,color)

% HLINE Create Vertical cursor in axes
%
% hline = vcursor(hAxes,pos,callback)
pos=pos(1);
xlimits = get(hAxes(1),'Xlim');
ylimits = get(hAxes(1),'Ylim');
hline(1) = line([pos pos], ylimits,...
    'EraseMode','normal',...
    'ButtonDownFcn',@buttondn,...
    'UserData',callback,...
    'Parent',hAxes(1),...
    'LineStyle',style,...
    'Color',color);

if (length(hAxes) > 1)
    hline(2) = line([pos pos], ylimits,...
        'EraseMode','normal',...
        'Parent',hAxes(2),...
        'LineStyle',style,...
        'Color',color);
end

function buttondn(h,events)

ud = get(gcf,'UserData');
store = get([gcf gca],'Units');

set([gcf gca],'Units','pixels');
FigurePos = get(gcf,'Position');

ud.AxesPos = get(gca,'Position') + [FigurePos(1:2) 0 0];
ud.hline = h;
ud.xlimits = xlim;
ud.ylimits = ylim;

set(gcf,'UserData',ud,...
    'WindowButtonMotionFcn',@buttonmotion,...
    'WindowButtonUpFcn',@buttonup);

set([gcf gca],{'Units'},store);


function buttonup(h,events)
set(gcf,'WindowButtonMotionFcn','','WindowButtonUpFcn','')
ud = get(gcf,'UserData');
feval(get(ud.hline,'UserData'),gcf);

function buttonmotion(h,events)

ud = get(gcf,'UserData');
PointerLocation = get(0,'PointerLocation');
PointerLocation = PointerLocation - ud.AxesPos(1:2);
PointerLocation = PointerLocation ./ ud.AxesPos(3:4);
PointerLocation = PointerLocation.*[diff(ud.xlimits) diff(ud.ylimits)] + [ud.xlimits(1) ud.ylimits(1)];

set(ud.hline,'XData',repmat(PointerLocation(1),1,2));
feval(get(ud.hline,'UserData'),gcf);

