%% Add PTB
addpath('/Users/Shared/toolboxes/ptb_3012/Psychtoolbox');
addpath ('./utilityFunctions');

%Speak('2','Samantha');
%WaitSecs(0.1);
%Speak('9','Samantha');
%WaitSecs(0.1);
%Speak('k','Samantha');
%WaitSecs(0.1);
%Speak('o','Samantha');
%WaitSecs(0.1);
%Speak(' ','Samantha');
%% Get words
path = '/Users/orestispapaioannou/Box Sync/MATLAB/PWM Pilot/PWM_AV/Exp Files/';
<<<<<<< HEAD
sbjlog = './SubjectLog.txt';

digits = {'2','9',' '};%last element reserved for blank trial character
numdigits = length(digits)-1;
letters = {'k','o',' '};%last element reserved for blank trial character
numletters = length(letters)-1;

=======
sbjlog = [path 'SubjectLog.txt'];

digits = {'2','9',' '};%last element reserved for blank trial character
numdigits = length(digits)-1;
letters = {'k','o',' '};%last element reserved for blank trial character
numletters = length(letters)-1;

>>>>>>> bed097b3e58e22ded3755d8d0d8bb5b748cb03b5
soundclips = struct();
for ith = 1:length(digits)
[soundclips.digits.audio{ith}, soundclips.digits.SR{ith}] = audioread(['./audio/' digits{ith} '.wav']);
soundclips.digits.text{ith} = digits{ith};
end
for ith = 1:length(letters)
[soundclips.letters.audio{ith}, soundclips.letters.SR{ith}] = audioread(['./audio/' letters{ith} '.wav']);
soundclips.letters.text{ith} = letters{ith};
end

fonts = {'Calibri'};
numfonts = length(fonts);


%% Task parameter

numtotal = 160;
numblank = div(numtotal,2);
numtasks = 8; %practice 1 & 2 (rects & circles), Auditory task 1 & 2, Visualtask 1 & 2, interposed task
practicetasks = 1:2;
Atasks = [1 3:4];
Vtasks = [2 5:6];
interposedtasks = [7 8];
breaks = [numtotal/4 2*numtotal/4 3*numtotal/4];
numpractice = 20;

numpos = 2;
numobjs = 4;
%% colors
red = [255 0 0];
green = [0 255 0];
blue = [0 0 255];
yellow = [255 255 0];
purple = [102 0 255];
cyan = [0 255 255];
pink = [204 0 102];
gray = [100 100 100];
black = [0 0 0];
white = [255 255 255];
orange = [255 100 0];
magenta = [255 0 255];
rgbcolors = [red;green;blue;yellow; purple;cyan;pink;gray;black;white;orange;magenta]';
rgbnames = table(rgbcolors', 'VariableNames',{'value'});
names = {'red';'green';'blue';'yellow';'purple';'cyan';'pink';'gray';'black';'white';'orange';'magenta'};
rgbnames.name = names;
 
backgroundColor = [50 50 50];

%% stimulus info
if ~exist('useTrueRes','var')
    useTrueRes = false;
end
if useTrueRes
  resVal = [resolution.width resolution.height]; %#ok<UNRCH>
else
  resVal = [1280 800];
end

monitorWidth = 53.113;
viewingDistance = 100;
ppd = round(pi * resVal(1) / atan(monitorWidth/2/viewingDistance) / 360);

lineWidth = 2;
chipOffset = 0.15*ppd;

[centerX, centerY] = RectCenter([0 0 resVal]);
margindeg = 80/25;
eccentdeg = 30/25;
leftsideX = [round(centerX-margindeg*ppd), round(centerX-eccentdeg*ppd)];
rightsideX = [round(centerX+eccentdeg*ppd),round(centerX+margindeg*ppd)];
leftsideY = [round(centerY-margindeg*ppd), round(centerY+margindeg*ppd)];
rightsideY = [round(centerY-margindeg*ppd), round(centerY+margindeg*ppd)];
positions = [leftsideX leftsideY; rightsideX rightsideY];

baserect = [0 0 (8/25*ppd) (23/25*ppd)];
basecrcl = [0 0 (18/25*ppd) (18/25*ppd)];

baseimgrect = [0 0 8*ppd 8*ppd];
photocellrect = [0 0 1/2*ppd 1/2*ppd];

%% Default screen info
fixcolor = [180 30 30];
fixfont = 'Arial';
fixstyle = 1;
fixsize = round(0.4*ppd);
txtcolor = white;
txtsize = round(0.5*ppd);
stimfontsize = round(0.8*ppd);

%% White sync Rect properties
syncRectHeight = 35;
syncRectWidth = 35;
syncRect = [0, centerY-round(syncRectHeight/2), syncRectWidth, centerY+round(syncRectHeight/2)];


%% Trial Properties
fudgefactor = 4;
fix1minisi= 100-fudgefactor; %in ms
fix1maxisi = 200-fudgefactor;
screen1dur = 200-fudgefactor;
fix2minisi= 350-fudgefactor;
fix2maxisi = 350-fudgefactor;
screen2dur = 400-fudgefactor;
fix3minisi= 500-fudgefactor;
fix3maxisi = 500-fudgefactor;
screen3dur = 2000-fudgefactor;
iti = 1000;
countdowndelay = 800; %determines how fast the countdown moves (in ms)

responseFudgeFactor = 17;


%% Save setup
save('PWM_AV_Setup.mat');