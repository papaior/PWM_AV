function [int] = div(num, den, asInt)
%[int] = div(numerator,denominator) returns the intiger division output of
%numerator/denominator. Works for non-integers too (outputs an intiger).
%Output is a double unless asInt is set to true. 
%If asInt is set to true, output is int32 if <2^32 and int64 if 2^32 <= output < 2^64  
if nargin < 3
  asInt = false;
end

if num/den >= 0
  int = floor(num/den);
elseif num/den < 0
  int = ceil(num/den);
end

if asInt
  if num/den < 2^32
    int = int32(int);
  elseif num/den < 2^64
    int = int64(int);
    warning('output greater than 2^32. int64 used')
  else
    error('output too large. Cannot be represented by int64')
  end
end


