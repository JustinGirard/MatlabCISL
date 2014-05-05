function varargout = GMMTest(varargin)
% GMMTEST MATLAB code for GMMTest.fig
%      GMMTEST, by itself, creates a new GMMTEST or raises the existing
%      singleton*.
%
%      H = GMMTEST returns the handle to a new GMMTEST or the handle to
%      the existing singleton*.
%
%      GMMTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GMMTEST.M with the given input arguments.
%
%      GMMTEST('Property','Value',...) creates a new GMMTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GMMTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GMMTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GMMTest

% Last Modified by GUIDE v2.5 30-Apr-2014 15:48:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GMMTest_OpeningFcn, ...
                   'gui_OutputFcn',  @GMMTest_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GMMTest is made visible.
function GMMTest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GMMTest (see VARARGIN)

% Choose default command line output for GMMTest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GMMTest wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GMMTest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse motion over figure - except title and menu.
function figure1_WindowButtonMotionFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in btnRefresh.
function btnRefresh_Callback(hObject, eventdata, handles)
% hObject    handle to btnRefresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Quiver = 1;
        
    obsX =1.575276511987878;
    obsY =1.575276511987878;
    goalX =1;
    goalY =2;
    itemX =-2.076251463602669;
    itemY =-0.576251463602669;
    
    aSelect = get(findobj('Tag', 'lstAction'),'Value');
    qu = get(findobj('Tag', 'btnQuiver'),'Value');
    hi = get(findobj('Tag', 'chkHasItem'),'Value');

    h=findobj('Tag','theplot');
    %clf(h);
    %axes(h);
    maxP = [0 0 0];
    
    hal = HAL();

    if(hi == 1)
        advVec = hal.GetAdvisedVector([goalX goalY obsX obsY]);
    else
        advVec = hal.GetAdvisedVector([itemX itemY obsX obsY]);
    end
    
    
    z = zeros(11,11);
    q = [];
    for x=-5:5
        for y=-5:5
            if(hi == 1)
                [adviceP,directions] = hal.GetAdvice([goalX-x goalY-y obsX-x obsY-y]);
            else
                [adviceP,directions] = hal.GetAdvice([itemX-x itemY-y obsX-x obsY-y]);
            end
            z(x+6,y+6) = adviceP(aSelect); 
            if(maxP(1) < adviceP(aSelect))
                maxP = [adviceP(aSelect) x+6 y+6];
            end
            [amt,ind] = max(adviceP);
            %d = [directions(ind,1) directions(ind,2)];
            d = [directions(:,1)'*adviceP directions(:,2)'*adviceP];
            if(amt > 0.00001)
                q =[q; x+6 y+6 d(1)*amt d(2)*amt];
            end
        end
    end
    
    
    hold on;
    
    if(qu == 1)
        quiver(q(:,1),q(:,2),q(:,3),q(:,4));
    else
        contour(z);
        scatter(11,11,'X');
        scatter(maxP(3),maxP(2),'o');
        X = [maxP(3) maxP(3)+directions(aSelect,2)];
        Y = [maxP(2) maxP(2)+directions(aSelect,1)];
        plot(X,Y,'b','LineWidth',2);     
    end
    boxPoints = GetBox([obsX+6 obsY+6],0.5);
    plot(boxPoints(1,:),boxPoints(2,:),'r');
    boxPoints = GetBox([goalX+6 goalY+6],1);
    plot(boxPoints(1,:),boxPoints(2,:),'b');
    if(hi == 0)
        boxPoints = GetBox([itemX+6 itemY+6],0.25);
        plot(boxPoints(1,:),boxPoints(2,:),'g');
    end
    X = [6 6+advVec(1)];
    Y = [6 6+advVec(2)];
    plot(X,Y,'b','LineWidth',2);     
    
    drawnow;
    %set(h,'axes',pl);    


% --- Executes on selection change in lstAction.
function lstAction_Callback(hObject, eventdata, handles)
% hObject    handle to lstAction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lstAction contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lstAction

function boxPoints = GetBox(point,size)
   ang=0:0.01:2*pi; 
   xp=size*cos(ang);
   yp=size*sin(ang);
   boxPoints = [point(1)+xp; point(2)+yp];


% --- Executes during object creation, after setting all properties.
function lstAction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lstAction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnQuiver.
function btnQuiver_Callback(hObject, eventdata, handles)
% hObject    handle to btnQuiver (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of btnQuiver


% --- Executes on button press in chkHasItem.
function chkHasItem_Callback(hObject, eventdata, handles)
% hObject    handle to chkHasItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chkHasItem
