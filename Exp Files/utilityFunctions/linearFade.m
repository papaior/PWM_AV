function [] = linearFade(screen,shape,rect,originCol,finalCol,steps,stepWidth)
%create a FrameRect or FrameOval object that fades from originalCol to
%finalCol linearly in steps steps. 

if nargin<7 %set default stepWidth
  stepWidth = 1;
end

if nargin<6 %set default steps
  steps = 5;
end

steps = round(steps);

if rect(3)-rect(1)<2*steps*stepWidth
  error('rect not big enough for the number of steps')
end

shiftMat = [stepWidth stepWidth -stepWidth -stepWidth];
shiftColMat = (originCol - finalCol)/(steps-1);

for step = 1:steps
  shift = step-1;
  stepRect = rect+shift*shiftMat;
  stepCol = finalCol+shift*shiftColMat;
  
  if strcmp(shape,'Oval')
    Screen('FillOval',screen,stepCol,stepRect);
  elseif strcmp(shape,'Rect')
    Screen('FillRect',screen,stepCol,stepRect);
  else
    %error('Invalid shape. Function only accepts ''Oval'' or ''Rect''.')
  end
end