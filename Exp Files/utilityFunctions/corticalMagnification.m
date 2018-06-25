function [magnification] = corticalMagnification(temporalAngle,superiorAngle,rads)
%Computes the cortical magnification factor (relative to fixation) for a point along the
%nasal/temporal axis and inferior/superior axis. Positive values mean
%temporal or inferior anfles respectively, with negative or zero values for nasal
%or inferior angles
if nargin<3
  rads = false;
end
if rads
  temporalAngle = temporalAngle *pi/180;
  superiorAngle = superiorAngle *pi/180;
end

if temporalAngle>0
  temporalMagnification = (1+0.29*abs(temporalAngle)+0.000012*abs(temporalAngle)^3);
elseif temporalAngle<=0
  temporalMagnification = (1+0.33*abs(temporalAngle)+0.00007*abs(temporalAngle)^3);
end

if superiorAngle>0
  superiorMagnification = (1+0.42*abs(superiorAngle)+0.00012*abs(superiorAngle)^3);
elseif superiorAngle<=0
  superiorMagnification = (1+0.42*abs(superiorAngle)+0.000055*abs(superiorAngle)^3);
end


magnification = temporalMagnification*superiorMagnification;

