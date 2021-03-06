%% Get Subject Info, creatr logfile, and save trial info for this subject.
PsychDefaultSetup(1);
InitializePsychSound;
pah = PsychPortAudio('Open');

ListenChar;


prompt = {'Enter subject number','Enter subject age','Enter subject gender', 'Enter Order', 'Dominant Hand','Load Previous File','Save Subject Info','Start Trial','Use Gamepad'};
def={'99', '0', 'O', '1 8 1 5 6 2 3 4', 'R', 'N','Y','1','Y'};
answer = inputdlg(prompt, 'Experimental setup information',1,def);
[subjnum, subjage, subjgender, subjgroup, domhand, loadprevfile, subjsave, startTrial, useGamepad]  = deal(answer{:});

startTrial = str2double(startTrial);
loadprevfile = ismember(loadprevfile,'Yy');
subjsave = ismember(subjsave,'Yy');
useGamepad = ismember(useGamepad,'Yy');

if strcmpi(domhand, 'L')
  domhand = 'left';
  nondomhand = 'right';
  but1 = 5;
  but2 = 7;
else
  domhand = 'right';
  nondomhand = 'left';
  but1 = 6;
  but2 = 8;
end
buttons = [but1 but2 0];

if isodd(int32(str2double(subjnum)))
  audiostim = 'lettername';
  audiostimCat = 'letters';
  visualstim = 'digitname';
  visualstimCat = 'digits';
else
  audiostim = 'digitname';
  audiostimCat = 'digits';
  visualstim = 'lettername';
  visualstimCat = 'letters';
end

if subjsave
  sbjData = fopen(sbjlog,'a+');
  fprintf(sbjData,'SubNum\tage\tgender\tgroup\thanded\n');
  fprintf(sbjData, '%s\t%s\t%s\t%s\t%s\n', subjnum, subjage, subjgender, subjgroup, domhand);
end

fileName=[subjnum '_PWM_AV_log.txt'];
Data=fopen(fileName,'a+');
fprintf(Data,'\n\ntask\ttrial\tfix1dur\tfix2dur\tfix3dur\ts1dur\ts2dur\ts3dur\tchange\ttarget\tfont\tAstim\tVstim\tnewcolor\tccol1\tccol2\tccol3\tccol4\tcside\tcpos1\tcpos2\tcpos3\tcpos4\trcol1\trcol2\trcol3\trcol4\trside\trpos1\trpos2\trpos3\trpos4\tResp1\tCorAns1\tResp2\tCorAns2\tAcc1\tAcc2\tRT1\tRT2\n');
setupsavename = [subjnum '_PWM_AV_triallist.mat'];

if loadprevfile
  load(setupsavename);
end


%% Screen Setup
Screen('Preference', 'SkipSyncTests', 1);
%HideCursor;
drawsquare = false;
daq = seDAQ();%initialize event code script

screens = Screen('Screens');
screenNumber=max(screens);

%make resolution into a standard res, or as close as we can get it (standardize across monitors)
resolutions = struct2table(Screen('Resolutions',screenNumber)); %gets possible resolutions for monitor

if ismember(resVal(1),resolutions.width(resolutions.height == resVal(2))) %checks if desired resolution is possible on the monitor
  Screen('Resolution', screenNumber, resVal(1), resVal(2)); %sets resolution if possible
  res = Screen('Resolution',screenNumber); %store resolution info
  
else %if not, throw a warning and set to closest value
  resolutions.diff = [resolutions.width-resVal(1) resolutions.height-resVal(2)];%creates a variable with the difference of the resolutions to the desired resolution
  resolutions.norm = nan(height(resolutions),1); %set up another field that will contain the magnitute of the difference
  for ipos = 1:height(resolutions)
    resolutions.norm(ipos) = norm(resolutions.diff(ipos,:)); %populate the new field
  end
  
  resValNew = [resolutions.width(resolutions.norm == min(resolutions.norm)) resolutions.height(resolutions.norm == min(resolutions.norm))]; %set new res value to the resolutions with the least difference
  resValNew = resValNew(1,:); %if multiple resolutions have the min difference, choose the top one
  
  warning('Desired resolution not supported!! Resolution changed to %.f by %.f instead',resValNew(1), resValNew(2));
  
  Screen('Resolution', screenNumber, resValNew(1), resValNew(2)); %sets resolution to new value
  res = Screen('Resolution',screenNumber); %store resolution info
end

[expwin,rect]=PsychImaging('OpenWindow',screenNumber, backgroundColor);
Screen('TextSize', expwin, txtsize);
Screen('TextColor', expwin, white);
[centerX, centerY] = RectCenter(rect);

imgrect = CenterRectOnPointd(baseimgrect,centerX,centerY);
defaultfont = Screen('TextFont',expwin,'Calibri');

save(setupsavename, 'triallist');
%% draw offscreen windows
fixcross=Screen('OpenOffscreenWindow',screenNumber, backgroundColor, rect);
Screen('TextFont',fixcross,fixfont);
Screen('TextStyle',fixcross,fixstyle);
Screen('TextSize',fixcross,fixsize);
DrawFormattedText(fixcross,'+','center','center',fixcolor);
blankscreen=Screen('OpenOffscreenWindow',screenNumber,backgroundColor, rect);
picscreen=Screen('OpenOffscreenWindow',screenNumber,backgroundColor, baseimgrect);
testscreen1 = Screen('OpenOffscreenWindow',screenNumber,backgroundColor, rect);
testscreen2 = Screen('OpenOffscreenWindow',screenNumber,backgroundColor, rect);
testscreen3 = Screen('OpenOffscreenWindow',screenNumber,backgroundColor, rect);

%% Present Trials
taskvec = str2num(subjgroup); %determines, depending on input and counterbalance
for task = taskvec
  %reset accuracy metrics
  storeAcc1 = nan(1,numtotal);
  storeAcc2 = nan(1,numtotal);
  missCount = 0;
  
  %determine target shape
  recttarg = rem(task,2)==1; %false for circle task, true for rect task
  
  %Show instructions
  Screen('DrawTexture',expwin,blankscreen);
  DrawFormattedText(expwin,instructions{task,1+isodd(int32(str2double(subjnum)))},'center','center',txtcolor);
  Screen('Flip',expwin);
  RestrictKeysForKbCheck([]);
  KbWait;
  
  
  %start countdown
  DrawFormattedText(expwin, '5','center', 'center', txtcolor);
  Screen('Flip', expwin);
  WaitSecs(countdowndelay/1000);
  DrawFormattedText(expwin, '4' ,'center', 'center', txtcolor);
  Screen('Flip', expwin);
  WaitSecs(countdowndelay/1000);
  DrawFormattedText(expwin, '3' ,'center', 'center', txtcolor);
  Screen('Flip', expwin);
  WaitSecs(countdowndelay/1000);
  DrawFormattedText(expwin, '2' ,'center', 'center', txtcolor);
  Screen('Flip', expwin);
  WaitSecs(countdowndelay/1000)
  DrawFormattedText(expwin, '1' ,'center', 'center', txtcolor)
  Screen('Flip', expwin);
  WaitSecs(countdowndelay/1000);
  DrawFormattedText(expwin, 'Go!' ,'center', 'center', txtcolor);
  Screen('Flip', expwin);
  WaitSecs(countdowndelay/1000*1.5);
  
  if ismember(task,practicetasks)
    numtrials2 = numpractice;
  else
    numtrials2 = numtotal;
  end
  
  for trial = startTrial:numtrials2
    curtrial = triallist(task,trial);
    if ~ismember(task,interposedtasks) || ~strcmp(curtrial.lettername, letters(end))
      
      %redraw background
      Screen('DrawTexture', testscreen1, fixcross);
      Screen('DrawTexture', testscreen2, fixcross);
      Screen('DrawTexture', testscreen3, fixcross);
      
      %draw screen 1
      pos = curtrial.shapepos;
      allrects = cell(1,numpos);
      somerects = nan(4,numobjs);
      for ipos=1:numpos
        curpos = pos(ipos);
        allrects{curpos} = somerects;
        if ipos == 1
          for jobj = 1:numobjs
            somerects(:,jobj) = CenterRectOnPointd(basecrcl,curtrial.stimposx(curpos,jobj),curtrial.stimposy(curpos,jobj));
          end%forjth
          allrects{curpos} = somerects;
          Screen('FillOval',testscreen1,[curtrial.colormat{curpos,1:numobjs}],allrects{curpos});
        else
          for jobj = 1:numobjs
            somerects(:,jobj) = CenterRectOnPointd(baserect,curtrial.stimposx(curpos,jobj),curtrial.stimposy(curpos,jobj));
          end%forjth
          allrects{curpos} = somerects;
          Screen('FillRect',testscreen1,[curtrial.colormat{curpos,1:numobjs}],allrects{curpos});
        end%ifipos
      end%fori
      
      if drawsquare
        Screen('FillRect',testscreen1,white,[rect(3:4)-photocellrect(3:4) rect(3:4)])
      end
      
      %draw screen 2
      Screen('DrawTexture',testscreen2,blankscreen);
      %redraw fixcross
      Screen('TextFont',testscreen2,fixfont);
      Screen('TextStyle',testscreen2,fixstyle);
      Screen('TextSize',testscreen2,fixsize);
      DrawFormattedText(testscreen2,'+','center','center',fixcolor);
      %draw the words
      Screen('TextFont',testscreen2,curtrial.font{:});
      Screen('TextStyle',testscreen2,0);
      Screen('TextSize',testscreen2,stimfontsize);
      DrawFormattedText(testscreen2,curtrial.(visualstim){:},'center','center',txtcolor)
      soundData = soundclips.(audiostimCat).audio{strcmp(curtrial.(audiostim){:},eval(audiostimCat))};
      soundData = [soundData';soundData'];
      PsychPortAudio('FillBuffer',pah,soundData);
      
      if drawsquare
        Screen('FillRect',testscreen2,white,[rect(3:4)-photocellrect(3:4) rect(3:4)]);
      end
      
      %draw screen 3
      %copy screen 1
      Screen('DrawTexture',testscreen3,testscreen1);
      %if change, change target obj, and determine correct response
      if curtrial.change
        %change targobj
        targside = pos(1+recttarg); %determines which side is the target shape
        if recttarg
          targrect = CenterRectOnPointd(baserect,curtrial.stimposx(targside,curtrial.targobj),curtrial.stimposy(targside,curtrial.targobj));
          Screen('FillRect',testscreen3,curtrial.colormat{targside,5},targrect);
        else
          targrect = CenterRectOnPointd(basecrcl,curtrial.stimposx(targside,curtrial.targobj),curtrial.stimposy(targside,curtrial.targobj));
          Screen('FillOval',testscreen3,curtrial.colormat{targside,5},targrect);
        end
        %set correct response 2 to top
        curtrial.corresp2 = but1;
        
      else
        %If no change set correct response to bot
        curtrial.corresp2 = but2;
      end
      
      if ismember(task, Atasks)
        %If an auditory task set correct response
        curtrial.corresp1 = 0+buttons(strcmp(curtrial.(audiostim){:},letters)|strcmp(curtrial.(audiostim){:},digits));
      elseif ismember(task, Vtasks)
        %If a visual task task set correct response
        curtrial.corresp1 = 0+buttons(strcmp(curtrial.(visualstim){:},letters)|strcmp(curtrial.(visualstim){:},digits));
      else
        curtrial.corresp1 = 0;
      end
      
      if isempty(curtrial.corresp1)%sets accuracy to 0 if a blank trial
        curtrial.corresp1 = 0;
      end
      
      
      %presentstuff
      %present normally if not wordtask
      Screen('DrawTexture', expwin, fixcross);
      fix1ontime = Screen('Flip', expwin);
      Screen('DrawTexture', expwin, testscreen1);
      
      s1ontime = Screen('Flip', expwin, fix1ontime + randi([fix1minisi fix1maxisi])/1000);
      daq.sendEventCode(task*10 + 1 + strcmp(curtrial.lettername,' ')*6); %*1, *4 or *7, where first digit is task and second is wordcat (e.g 41 is task 4, s1, valid word)
      
      Screen('DrawTexture', expwin, fixcross);
      fix2ontime = Screen('Flip', expwin, s1ontime + screen1dur/1000);
      Screen('DrawTexture', expwin, testscreen2);
      
      s2ontime = Screen('Flip', expwin, fix2ontime + randi([fix2minisi fix2maxisi])/1000);
      daq.sendEventCode(task*10 + 2 + strcmp(curtrial.lettername,' ')*6); %*2,*5,*8
      PsychPortAudio('Start',pah,1,s2ontime+0.030);
      Screen('DrawTexture', expwin, fixcross);
      
      [curtrial.resp1,curtrial.RT1] = getResponce(buttons,useGamepad,s2ontime+ms2s(screen2dur-responseFudgeFactor),daq);
      
      fix3ontime = Screen('Flip', expwin, s2ontime + screen2dur/1000);
      Screen('DrawTexture', expwin, testscreen3);
      jitter = randi([fix3minisi fix3maxisi]);
      [curtrial.resp1,curtrial.RT1] = getResponce(buttons,useGamepad,fix3ontime+ms2s(jitter-responseFudgeFactor),daq);
      
      curtrial.Acc1 = curtrial.resp1 == curtrial.corresp1;
      storeAcc1(trial) = curtrial.Acc1;
      
      s3ontime = Screen('Flip', expwin, fix3ontime + jitter/1000);
      daq.sendEventCode(task*10 + 3 + strcmp(curtrial.lettername,' ')*6); %*3,*6,*9
      daq.sendEventCode(curtrial.shapepos(2)+90);%denotes which shape was on the left (91 for square, 92 for circle)
      daq.sendEventCode((curtrial.change+1)); %denotes change (1 = no change or 2  change)
      %daq.sendEventCode(110+find(ismember(fonts,curtrial.font)));%Denotes which font we used. 111 for cambria
      
      
      %flip to fix on response, or after max duration
      sumResp=0;
      Screen('DrawTexture', expwin, fixcross);%prepare next screen
      [curtrial.resp2,curtrial.RT2] = getResponce(buttons,useGamepad,s3ontime+ms2s(screen3dur-responseFudgeFactor),daq);
      
      while (GetSecs < (s3ontime + screen3dur/1000))
        endsecs = GetSecs;
      end%whilesumResp
      daq.sendEventCode(200+curtrial.corresp1);
      WaitSecs(0.01);
      daq.sendEventCode(curtrial.corresp2);
      
      %flip off stimulus
      offtime = Screen('Flip', expwin, GetSecs);
      WaitSecs(iti/1000);
      if curtrial.resp2 > 0
        curtrial.Acc2 = curtrial.resp2 == curtrial.corresp2;
      else
        curtrial.RT2 = NaN;
        curtrial.Acc2 = NaN; curtrial.RespMade = 'NON';
        missCount = missCount+1;
      end
      storeAcc2(trial) = curtrial.Acc2;
      
      %print to experimenter screen
      disp(['Trial = ' num2str(trial)]);
      disp(['Responce1 = ' num2str(curtrial.resp1)]);
      disp(['Correct Responce1 = ' num2str(curtrial.corresp1)]);
      disp(['taskACC1 = ' num2str(curtrial.Acc1-s2ontime)]);
      disp(['RT1 = ' num2str(curtrial.RT1) ' ms']);
      disp(['TaskAcc1 = ' num2str(nanmean(storeAcc1*100)) '%']);
      disp('...')
      disp(['Responce2 = ' num2str(curtrial.resp2)]);
      disp(['Correct Responce2 = ' num2str(curtrial.corresp2)]);
      disp(['trialACC2 = ' num2str(curtrial.Acc2)]);
      disp(['RT2 = ' num2str(curtrial.RT2-s3ontime) ' ms']);
      disp(['TaskAcc2 = ' num2str(nanmean(storeAcc2*100)) '%']);
      disp('...');
      disp('...');
      
      %print to data file
      %task trial fix1dur fix2dur fix3dur s1dur s2dur s3dur change target font Astim Vstim newcolor ccol1 ccol2 ccol3 ccol4 cpos1 cpos2 cpos3 cpos4 rcol1 rcol2 rcol3 rcol4 rpos1 rpos2 rpos3 rpos4 Resp1 CorAns1 Resp2 CorAns2 Acc1 Acc2 RT1 RT2
      fprintf(Data,'%s\t%s\t%3d\t%3d\t%3d\t%3d\t%3d\t%3d\t%c\t%c\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n', ...
        num2str(task),num2str(trial),...
        (s1ontime-fix1ontime),(s2ontime-fix2ontime),(s3ontime-fix3ontime),(fix2ontime-s1ontime),(fix3ontime-s2ontime),(offtime-s3ontime),... task trial fix1dur fix2dur fix3dur s1dur s2dur s3dur
        num2str(curtrial.change),num2str(curtrial.targobj),curtrial.font{:} , curtrial.(audiostim){:}, curtrial.(visualstim){:},... change target font Astim Vstim
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{1,5}','rows'))),... newcolor
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{1,1}','rows'))),... ccol1
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{1,2}','rows'))),... ccol2
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{1,3}','rows'))),... ccol3
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{1,4}','rows'))),... ccol4
        num2str(curtrial.shapepos(1)),... circle side
        [num2str(curtrial.stimposx(pos(1),1)) ' ' num2str(curtrial.stimposy(pos(1),1))],... cpos1
        [num2str(curtrial.stimposx(pos(1),2)) ' ' num2str(curtrial.stimposy(pos(1),2))],... cpos2
        [num2str(curtrial.stimposx(pos(1),3)) ' ' num2str(curtrial.stimposy(pos(1),3))],... cpos3
        [num2str(curtrial.stimposx(pos(1),4)) ' ' num2str(curtrial.stimposy(pos(1),4))],... cpos4
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{2,1}','rows'))),... rcol1
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{2,2}','rows'))),... rcol2
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{2,3}','rows'))),... rcol3
        strjoin(rgbnames.name(ismember(rgbnames.value,curtrial.colormat{2,4}','rows'))),... rcol4
        num2str(curtrial.shapepos(1)),... rect side
        [num2str(curtrial.stimposx(pos(2),1)) ' ' num2str(curtrial.stimposy(pos(2),1))],... rpos1
        [num2str(curtrial.stimposx(pos(2),2)) ' ' num2str(curtrial.stimposy(pos(2),2))],... rpos2
        [num2str(curtrial.stimposx(pos(2),3)) ' ' num2str(curtrial.stimposy(pos(2),3))],... rpos3
        [num2str(curtrial.stimposx(pos(2),4)) ' ' num2str(curtrial.stimposy(pos(2),4))],... rpos4
        num2str(curtrial.resp1),num2str(curtrial.corresp1),num2str(curtrial.resp2),num2str(curtrial.corresp2),... %Resp1 CorAns1 Resp2 CorAns2
        num2str(curtrial.Acc1),num2str(curtrial.Acc2),num2str(curtrial.RT1*1000),num2str(curtrial.RT2*1000)); %Acc1 Acc2 RT1 RT2
      
    end
    % check for pause
    pause = KbName('p');
    resume = KbName('q');
    RestrictKeysForKbCheck([pause resume]);
    [keydown, time, keyvec]= KbCheck;
    if keyvec(pause)
      fprintf(Data,'Pause\n');
      while ~keyvec(resume)
        [keydown, time, keyvec]= KbCheck;
      end
      fprintf(Data,'Unpause\n');
    end
    
    RestrictKeysForKbCheck([]);
    %break if it's time
    if ismember(trial,breaks)
      Screen('DrawTexture',expwin,blankscreen);
      DrawFormattedText(expwin,sprintf('Alright!\nTake a short break now.\n\n\nPress any button to continue.'),'center','center',txtcolor);
      Screen('Flip',expwin);
      
      WaitSecs(0.5)
      sumResp=0;
      Screen('DrawTexture', expwin, fixcross);%prepre next screen
      getResponce(buttons(1:end-1),useGamepad);
      if ~useGamepad
        KbWait
      end
      [keydown, time, keyvec]= KbCheck;
      %check for pause
      if keyvec(pause)
        fprintf('Pause\n');
        while ~keyvec(resume)
          [keydown, time, keyvec]= KbCheck;
        end
        fprintf('Unpause\n');
      end
      
      Screen('Flip',expwin);
      
      %start countdown
      DrawFormattedText(expwin, '5','center', 'center', txtcolor);
      Screen('Flip', expwin);
      WaitSecs(countdowndelay/1000);
      DrawFormattedText(expwin, '4' ,'center', 'center', txtcolor);
      Screen('Flip', expwin);
      WaitSecs(countdowndelay/1000);
      DrawFormattedText(expwin, '3' ,'center', 'center', txtcolor);
      Screen('Flip', expwin);
      WaitSecs(countdowndelay/1000);
      DrawFormattedText(expwin, '2' ,'center', 'center', txtcolor);
      Screen('Flip', expwin);
      WaitSecs(countdowndelay/1000)
      DrawFormattedText(expwin, '1' ,'center', 'center', txtcolor)
      Screen('Flip', expwin);
      WaitSecs(countdowndelay/1000);
      DrawFormattedText(expwin, 'Go!' ,'center', 'center', txtcolor);
      Screen('Flip', expwin);
      WaitSecs(countdowndelay/1000*1.5);
    end
  end
  
  %longbreak
  if task ~= taskvec(end)
    Screen('DrawTexture',expwin,blankscreen);
    DrawFormattedText(expwin,sprintf('Sweet!\nYou''re done with this part!\n\n\nPlease wait for the experimenter.'),'center','center',txtcolor);
    Screen('Flip',expwin);
    sumResp=0;
    Screen('DrawTexture', expwin, fixcross);%prepre next screen
    KbWait
    WaitSecs(1)
    Screen('Flip',expwin);
  else
    Screen('DrawTexture',expwin,blankscreen);
    DrawFormattedText(expwin,sprintf('Awesome!\nYou''re done!\n\n\nPlease wait for the experimenter.'),'center','center',txtcolor);
    Screen('Flip',expwin);
    KbWait;
  end
  startTrial = 1;
  
end
sca;