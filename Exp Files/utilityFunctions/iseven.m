function [bool] = iseven(n)
%isodd(n) = returns true if n is odd, false otherwise. 
if ~isinteger(n)
  warning('non-integer value passed into iseven')
end
bool = mod(n,2) == 0;