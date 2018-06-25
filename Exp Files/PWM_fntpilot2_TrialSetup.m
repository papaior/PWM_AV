load('PWM_fntpilot2.2_Setup.mat');
rng('shuffle')

numtrials = numfonts*numwords;
numtotal = numtrials + numblanks;
numtasks = 8; %practice 1 & 2 (rects & circles), dualtask 1 & 2, singletask 1&2 , wordtask
practicetasks = [1:2 8];
dualtasks = 3:4;
singletasks = 5:6;
wordtasks = 7:8;
breaks = [numtotal/5 2*numtotal/5 3*numtotal/5 4*numtotal/5];
numpractice = 20;

numpos = 2;
numobjs = 4;


triallist = struct();
for task = 1:numtasks
  changevec = [Shuffle(1:numw) Shuffle(1:numc) Shuffle(1:numblanks)] ;%NOTE: this is not optimized and automated for other font/wordcat combos
  sidevec = [Shuffle(1:numw) Shuffle(1:numc) Shuffle(1:numblanks)]; %NOTE: this is not optimized and automated for other font/wordcat combos

  trial=0;
  %set up trials
  for fnt = 1:numfonts
    for wrd = 1:numwords
      trial = trial+1;
      triallist(task,trial).wordcat = wordcats(1+(wrd>numw&wrd<=numw+numc));%W if first numw trials in rep, C otherwise
      triallist(task,trial).wordname = wordlist(wrd);%pick a word
      triallist(task,trial).font = fonts(fnt);%pick a font
      triallist(task,trial).shapepos = [1+rem(sidevec(wrd),2) 1+~rem(sidevec(wrd),2)];%determines whether circles/rects are left or right. 1st value is circles, 2nd rects
      triallist(task,trial).targobj = Sample(1:numobjs); %picks which obj will change if change
      triallist(task,trial).stimposx = nan(numpos,numobjs);
      triallist(task,trial).stimposy = nan(numpos,numobjs);
      triallist(task,trial).colormat = cell(numpos,numobjs+1);%creates the colormatrix for this trial. The +1 is the newcolor used in case a change happens
      triallist(task,trial).change = rem(changevec(wrd),2);%this means 50% of trials will have a change.
      for pos = 1:numpos
        cols = rgbcolors(:,randsample(length(rgbcolors),numobjs+1));
        for obj = 1:numobjs+1
          triallist(task,trial).colormat{pos,obj} = cols(:,obj);
        end
        posv = positions(pos,:);
        obj = 1;
        while obj <= numobjs
          rx = randi(posv(2)-posv(1))+posv(1);
          triallist(task,trial).stimposx(pos,obj)= rx;
          ry = randi(posv(4)-posv(3))+posv(3);
          triallist(task,trial).stimposy(pos,obj)= ry;
          pastobj=1;
          while pastobj < obj
            if  sqrt(abs(triallist(task,trial).stimposx(pos,obj)-triallist(task,trial).stimposx(pos,pastobj))^2+abs(triallist(task,trial).stimposy(pos,obj)-triallist(task,trial).stimposy(pos,pastobj))^2)< 30/25*ppd
              triallist(task,trial).stimposx(pos,obj)= randi(posv(2)-posv(1))+posv(1);
              triallist(task,trial).stimposy(pos,obj)= randi(posv(4)-posv(3))+posv(3);
              pastobj=1;
            else
              pastobj=pastobj+1;
            end
          end
          if sqrt((triallist(task,trial).stimposx(pos,obj)-centerX)^2 + (triallist(task,trial).stimposy(pos,obj)-centerY)^2)<=80/25*ppd%makes sure position is within the circle of the original exeriment
            obj = obj+1;
          end
        end
      end
    end
    
    for bln = numwords+1:numwords+numblanks
      trial = trial+1;
      triallist(task,trial).wordcat = {'B'};%B for blanks
      triallist(task,trial).wordname = {'     '};%empty string (there to mimic timing etc
      triallist(task,trial).font = fonts(fnt);%pick a font
      triallist(task,trial).shapepos = [1+rem(sidevec(bln),2) 1+~rem(sidevec(bln),2)];%determines whether circles/rects are left or right. 1st value is circles, 2nd rects
      triallist(task,trial).targobj = Sample(1:numobjs); %picks which obj will change if change
      triallist(task,trial).stimposx = nan(numpos,numobjs);
      triallist(task,trial).stimposy = nan(numpos,numobjs);
      triallist(task,trial).colormat = cell(numpos,numobjs+1);%creates the colormatrix for this trial. The +1 is the newcolor used in case a change happens
      triallist(task,trial).change = rem(changevec(bln),2);%this means 50% of trials will have a change.
      for pos = 1:numpos
        cols = rgbcolors(:,randsample(length(rgbcolors),numobjs+1));
        for obj = 1:numobjs+1
          triallist(task,trial).colormat{pos,obj} = cols(:,obj);
        end
        posv = positions(pos,:);
        obj = 1;
        while obj <= numobjs
          rx = randi(posv(2)-posv(1))+posv(1);
          triallist(task,trial).stimposx(pos,obj)= rx;
          ry = randi(posv(4)-posv(3))+posv(3);
          triallist(task,trial).stimposy(pos,obj)= ry;
          pastobj=1;
          while pastobj < obj
            if  sqrt(abs(triallist(task,trial).stimposx(pos,obj)-triallist(task,trial).stimposx(pos,pastobj))^2+abs(triallist(task,trial).stimposy(pos,obj)-triallist(task,trial).stimposy(pos,pastobj))^2)< 30/25*ppd
              triallist(task,trial).stimposx(pos,obj)= randi(posv(2)-posv(1))+posv(1);
              triallist(task,trial).stimposy(pos,obj)= randi(posv(4)-posv(3))+posv(3);
              pastobj=1;
            else
              pastobj=pastobj+1;
            end
          end
          if sqrt((triallist(task,trial).stimposx(pos,obj)-centerX)^2 + (triallist(task,trial).stimposy(pos,obj)-centerY)^2)<=80/25*ppd%makes sure position is within the circle of the original exeriment
            obj = obj+1;
          end
        end
      end
    end
  end
  
  
 
 
  %shuffle trials
  if ismember(task,wordtasks)
    triallist(task,1:numtrials)=Shuffle(triallist(task,1:numtrials));
  else
    triallist(task,:)=Shuffle(triallist(task,:));
  end
  
end



instructions = cell(numtasks,1);
instructions{1} = 'Let''s try some practice rounds!\nMake sure to focus on the rectangles.';
instructions{2} = 'Let''s try some practice rounds!\nMake sure to focus on the circles';
instructions{3} = 'Focus on the rectangles.\nPress the top button if any of them changed color, or the bottom button if none of them did\n\nPress the top button if a pseudoword appeared , or the bottom button if a consonant string appeared\nIf nothing comes up, do not respond';
instructions{4} = 'Focus on the circles.\nPress the top button if any of them changed color, or the bottom button if none of them did\n\nPress the top button if a pseudoword appeared , or the bottom button if a consonant string appeared\nIf nothing comes up, do not respond';
instructions{5} = 'Focus on the rectangles.\nPress the top button if any of them changed color, or the bottom button if none of them did\n\nDisregard the intervening words';
instructions{6} = 'Focus on the circles.\nPress top the button if any of them changed color, or the bottom button if none of them did\n\nDisregard the intervening words';
instructions{7} = 'Press the top button for pseudowords,\nand the bottom button for consonant strings';
instructions{8} = 'Press the top button for pseudowords,\nand the bottom button for consonant strings';


save('PWM_fntpilot2.2_TrialSetup.mat')
