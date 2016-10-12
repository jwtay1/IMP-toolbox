function IMout = imautoadjust(IMin)

%Get a histogram of the data
[nCnt,xBin] = hist(double(IMin(:)),100);

%Look for the minimum point between the two highest peaks
%(assumption here is that the dstribution is bimodal)
[~,pkLoc] = findpeaks(nCnt,'MinPeakDistance',5,'SortStr','descend');

[~,minLoc] = min(nCnt(pkLoc(1):pkLoc(2)));
minLoc = minLoc + pkLoc(1) - 1;

maxLoc = (pkLoc(2) - minLoc) + pkLoc(2);

minVal = round(xBin(minLoc));
maxVal = round(xBin(maxLoc));

%Adjust the LUT
IMout = adjustimage(IMin,minVal,maxVal);

% % %Debugging plots
% plot(xBin,nCnt)
% hold on
% plot(xBin(pkLoc),nCnt(pkLoc),'go')
% plot(xBin(minLoc),nCnt(minLoc),'rx')
% plot(xBin(maxLoc),nCnt(maxLoc),'rx')
% hold off



end