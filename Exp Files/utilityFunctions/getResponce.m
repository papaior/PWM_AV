function [responces, responceTime] = getResponce(buttonset,usegamepad,maxtime,daq)
responces = 0;
responceTime = nan;
buttonStateResponces = zeros(1,size(buttonset,2));

if nargin < 4
  daq = seDAQ;
end

if nargin < 3 %if no maxtime is specified, default to infinity (this will wait for a responce infinitely if usegamepad = true 
  maxtime = inf;
end

if nargin < 2
  usegamepad = false;
end

if usegamepad
  while ~responces && GetSecs < maxtime
    for button = 1:size(buttonset,2)
      buttonStateResponces(button) = Gamepad('GetButton', 1, buttonset(button));
    end
    responces = sum(buttonStateResponces.*buttonset);
    
    if responces && isa(daq,'seDAQ')
      daq.sendEventCode(sum(buttonStateResponces.*buttonset));
      responceTime = GetSecs;
    end
    
  end
end

