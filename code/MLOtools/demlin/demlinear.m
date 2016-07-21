%
% DEMLINEAR
%
% Demo to show how linear models work and learn.
% Expects some data, labels, and functionality.
% Should not be called independently but by a DEMx function
%
function demlinear(supplieddata,suppliedlabels,functionality)

global hfn hfp harrow hboundary arrowHead
global thresholdSlider numIterationsBox cumulativeIterations
global data labels theta w LAtext toggleErrors

data = supplieddata;
labels = suppliedlabels;

if size(data,2)>2
    warning('More than 2 features cannot be plotted on screen, so just the first two from your dataset will be shown.');
    data = data(:,1:2);
end
if length(unique(labels))>2
    error('Sorry, this only works for 2 classes - try another dataset.');
end

%make sure labels are 0/1
labels = oneofn2label(label2oneofn(labels))-1;

%set the functionality
LOGREG_ENABLE = functionality(1);
PERCEPTRON_ENABLE = functionality(2);
SVM_ENABLE = functionality(3);
MYCODE_ENABLE = functionality(4);


%ensure the first datapoint is positive
%this is a wierd requirement of LIBSVM
if labels(1)~=1
    datatmp = data(1,:);

    posclass = find(labels==1);
    data(1,:) = data(posclass(1),:);
    data(posclass(1),:) = datatmp;
    
    labels(1) = 1;
    labels(posclass(1))=0;
end



%RANDOM PARAMS
w     = (rand(1,2)-0.5)*14;
theta = (rand-0.5)*14;



%set up the axes
close;
height=500; width=750;
figure('Position',[300 300 width height]);
set(gca,'Units','pixels');
set(gca,'Position',[width*.3 50 width*0.8 height*0.8]);

%ensure it fits!
data = rescale_mean0var1(data)*2;

%set axes
axis equal; grid on; hold on;
s = 7;
axis(s*[-1 1 -1 1]);
set(gcf,'Resize', 'off');



%PLOT DATA FOR THE FIRST TIME
plot(data(labels==1,1),data(labels==1,2), 'rx','MarkerSize',7,'LineWidth',2);  
plot(data(labels==0,1),data(labels==0,2), 'bo','MarkerSize',7,'LineWidth',2);
hfp = plot(data); hfn = plot(data); %generate the plot handles


%draw the weight vector
harrow = arrow([0 0], w, 'LineWidth',1);
%draw the decision boundary
x = -s:1:s;
hboundary = plot(x,-(w(1)/(w(2)+.00001))*x+theta/(w(2)+.00001),'k--', 'LineWidth',1);



%BUILD THE GUI
hp = uipanel('Title','','FontSize',12,'BackgroundColor',[.8 .8 .8],...
    'Position',[.05 .1 .26 .8]);

subp = uipanel('Parent',hp,'Title','','FontSize',12,'BackgroundColor',[.8 .8 .8],...
    'Position',[.02 .01 .97 .4]);


cumulativeIterations = uicontrol('Parent',subp,'Style','text','String','0');

%threshold text
uicontrol('Style','text','Position',[240 420 60 20],'String','Threshold','BackgroundColor',[.8 .8 .8],'HorizontalAlignment','left');

%how many epochs text
uicontrol('Parent',subp,'Style','text','Position',[10 130 150 20],'String','How many epochs?','BackgroundColor',[.8 .8 .8],'HorizontalAlignment','left');
numIterationsBox    = uicontrol('Parent',subp,'Style','edit','String','50');
set(numIterationsBox, 'Position',[10 90 100 40],'BackgroundColor',[.8 .8 .8],'FontSize',15);

uicontrol('Parent',subp,'Style','text','Position',[10 210 150 20],'String','Total epochs so far...','BackgroundColor',[.8 .8 .8],'HorizontalAlignment','left');
set(cumulativeIterations,            'Position',[10 190 100 20],'BackgroundColor',[.8 .8 .8],'FontSize',15);

%add a little checkbox to toggle the green error markers
uicontrol('Parent',hp,'Style','text','String','Show errors?','Position',[10 248 90 20],'BackgroundColor',[.8 .8 .8]);
toggleErrors = uicontrol('Parent',hp,'Style','checkbox','Position',[120 250 18 18],'Value',1);



if MYCODE_ENABLE
    %"RUN MY CODE" SETUP
    runMyCodeButton = uicontrol('Parent',hp,'Style','pushbutton','String','Run my code!');
    set(runMyCodeButton,     'Position',[10 60 170 30],'Callback',@runmycode);
    changeMyCodeButton = uicontrol('Parent',hp,'Style','pushbutton','String','Choose!');
    set(changeMyCodeButton,  'Position',[10 30 70 30],'Callback',@changeMyCode);

    LAtext = uicontrol('Parent',subp,'Position',[5 5 170 20],'Style','text','String','mylearningalgorithm.m','BackgroundColor',[.8 .8 .8]);
    learningAlgorithm = 'mylearningalgorithm.m';
end


if SVM_ENABLE
    %SVM
    runSvmButton = uicontrol('Parent',hp,'Style','pushbutton','String','Run SVM');
    set(runSvmButton,'Position',[10 295 170 30]);
    set(runSvmButton,'Callback',{@runmodelanswer,'svm'});
    LIBSVMUnavailable = isempty(strfind( which('svmtrain'), 'libsvm' ));
    if LIBSVMUnavailable
        set(runSvmButton,'Enable','off');
        uicontrol('Parent',subp,'Style','text','Position',[10 270 150 20],'FontAngle','oblique','String','LibSVM not found.','BackgroundColor',[.8 .8 .8],'HorizontalAlignment','left');
    end
end

if LOGREG_ENABLE
    %LOGREG
    runLogRegButton = uicontrol('Parent',hp,'Style','pushbutton','String','Run Logistic Regression');
    set(runLogRegButton,     'Position',[10 355 170 30]);
    set(runLogRegButton,     'Callback',{@runmodelanswer,'logreg'});
end

if PERCEPTRON_ENABLE
    %PERCEPTRON
    runPerceptronButton = uicontrol('Parent',hp,'Style','pushbutton','String','Run Perceptron');
    set(runPerceptronButton, 'Position',[10 325 170 30]);
    set(runPerceptronButton, 'Callback',{@runmodelanswer,'perceptron'});
end






%%%%%%%%%%%%%%%%%%%%
%%SET up the controls and callbacks

%set up the draggable point to enable moving the weight vector
arrowHead = impoint(gca,w(1),w(2));
setColor(arrowHead,'k');
api = iptgetapi(arrowHead);
fcn = makeConstrainToRectFcn('impoint',get(gca,'XLim'),get(gca,'YLim'));
api.setPositionConstraintFcn(fcn); %and constrain it to the axes

%THRESHOLD SLIDER
thresholdSlider = uicontrol('Style','slider','Min',-50,'Max',50,'Value',theta);
set(thresholdSlider,     'Position',[280 50 20 350]);
%listen to it
addlistener(thresholdSlider,'Value','PostSet',@thresholdChange );
addlistener(thresholdSlider,'Value','PostSet',@(s,e) updatearrow(harrow, hboundary, getPosition(arrowHead)) );

%set up a callback to update every time the arrow is moved
addNewPositionCallback(arrowHead, @(args)updatearrow(harrow, hboundary, [args(1),args(2)] ));
%update the arrow position for the first time
setPosition(arrowHead,w);


    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function changeMyCode(src,eventData)

global LAtext cumulativeIterations

[filename pathname] = uigetfile('*.m','Choose a learning algorithm...');
%disp(['User selected', fullfile(pathname, filename)])

if filename==0; return;end

set(LAtext,'String',filename);
set(cumulativeIterations,'String','0');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updatearrow(harrow,hboundary,newparams)

global hfn hfp data labels theta w cumulativeIterations toggleErrors

%delete the old points
delete(hfp); delete(hfn);

%redraw the arrow
w = newparams;
arrow(harrow,'Stop', w, 'LineWidth', 1);

%redraw the decision boundary
x = -7:1:7;
set(hboundary,'Y',-(w(1)/(w(2)+.00001)).*x+theta/(w(2)+.00001));

%apply the classifier
guess = double(w*data' > theta)';

%plot the data and mistakes of the classifier
fp = (labels==0&guess==1);
fn = (labels==1&guess==0);

mistakes = sum(fp)+sum(fn);

if get(toggleErrors,'Value')==0
    fp(fp==1)=0;
    fn(fn==1)=0;
end

hfn = plot(data(fn,1),data(fn,2), 'go', 'MarkerSize', 10,'LineWidth',2);
hfp = plot(data(fp,1),data(fp,2), 'go', 'MarkerSize', 10,'LineWidth',2);

%update the title
title( ['Error: ' num2str(mistakes) ' / ' num2str(length(labels)) ', '...
        'w = [' num2str(dp(w(1),2)) ' ' num2str(dp(w(2),2)) '], ' ...
        '\theta = ' num2str(theta) '' ],...
        'FontSize',15);

%assume the user has moved it
%so reset the iterations counter
set(cumulativeIterations,'String','0');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function thresholdChange(src,eventData)

global thresholdSlider theta cumulativeIterations
theta = get(thresholdSlider,'Value');
set(cumulativeIterations,'String','0');

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function runmycode(src,eventData)

global data labels theta w
global harrow hboundary thresholdSlider arrowHead numIterationsBox
global cumulativeIterations learningAlgorithm LAtext

global currentAlgorithm
if strcmp(currentAlgorithm,'mine')==0; set(cumulativeIterations,'String','0'); end
currentAlgorithm = 'mine';

currentIteration = str2double(get(cumulativeIterations,'String'));


howmany = str2double(get(numIterationsBox,'String'));
for epoch = 1:howmany
    
    learningAlgorithm = get(LAtext,'String');  
    [wnew thetanew] = feval(learningAlgorithm(1:end-2),data,labels,w',theta);
    %[wnew thetanew] = mylearningalgorithm(data,labels,w',theta);
    
    %if the weights/theta have not changed, terminate the loop
    if sum(abs(w'-wnew))+abs(theta-thetanew) == 0; continue; end
    
    %otherwise store the new ones
    w = wnew'; theta = thetanew;
    
    %and update the GUI
    updatearrow(harrow,hboundary,w);
    setPosition(arrowHead,w);
    set(thresholdSlider,'Value',theta);
    
    set(cumulativeIterations,'String',currentIteration+epoch);
    
    refresh;
    pause(0.001);
    
end


end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function runmodelanswer(src,eventData,whichalgorithm)

global data labels theta w
global harrow hboundary thresholdSlider arrowHead numIterationsBox
global cumulativeIterations

global currentAlgorithm
if strcmp(currentAlgorithm,whichalgorithm)==0; set(cumulativeIterations,'String','0'); end
currentAlgorithm = whichalgorithm;

howmany = str2double(get(numIterationsBox,'String'));
currentIteration = str2double(get(cumulativeIterations,'String'));

for epoch = 1:howmany
    
    [wnew thetanew] = modelanswer(data,labels,w',theta,whichalgorithm);
    
    %if the weights/theta have not changed, terminate the loop
    if sum(abs(w'-wnew))+abs(theta-thetanew) == 0; continue; end
    
    %otherwise store the new ones
    w = wnew'; theta = thetanew;
    
    %and update the GUI
    updatearrow(harrow,hboundary,w);
    setPosition(arrowHead,w);
    set(thresholdSlider,'Value',theta);
    
    set(cumulativeIterations,'String',currentIteration+epoch);
    
    refresh;
    pause(0.001);
    
end

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function d = dp(v,numdp)
d = round((v-floor(v))*10^numdp)/10^numdp + floor(v);
end




