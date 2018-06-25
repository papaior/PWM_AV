function [bool] = isodd(n)
%isodd(n) = returns true if n is odd, false otherwise. 
if ~isinteger(n)
  warning('non-integer value passed into isodd')
end
bool = mod(n,2) == 1;