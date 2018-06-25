function outMat = recursivePermutation(permVec,inMat)
if nargin < 2
  inMat = [];
end

outMat = [];
if ~isempty(permVec)
  for ith = 1:permVec(1)
    tempMat = [inMat repmat(ith,max(1,size(inMat,1)),1)];
    outMat = [outMat; tempMat];
  end
  outMat = recursivePermutation(permVec(2:end),outMat);
else
  outMat = inMat;
end