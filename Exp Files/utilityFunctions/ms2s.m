function [sValue] = ms2s(msValue,fudge,fudgeValue)
%Turns the value from milliseconds to seconds
if nargin<3
  fudgeValue = 4;
end
if nargin<2
  fudge = false;
end
sValue = double(msValue-fudgeValue*fudge)/1000;

