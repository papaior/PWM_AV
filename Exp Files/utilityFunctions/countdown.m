function countdown(screen,startingValue,delay,endingString)
savedScreen = Screen('OpenOffscreenWindow',screen);
Screen('CopyWindow',screen,savedScreen);

if nargin < 4
  endingString = 'Go!';
end

if nargin < 3
  delay = 1;
else
  delay = delay/1000;
end

if nargin < 2
  startingValue = 5;
end

for count = startingValue:-1:0
  if count~=0
    text = num2str(count);
  else
    text = endingString;
  end
  DrawFormattedText(screen,text,'center','center');
  Screen('Flip',screen);
  WaitSecs(delay);
  
end
Screen('DrawTexture',screen,savedScreen);
Screen('Flip',screen);