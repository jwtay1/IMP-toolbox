function varargout = quickhist(imageIn, varargin)
%QUICKHIST  Quick calculation of image histograms
%
%  QUICKHIST(I) will plot the intensity histogram of image I. This is
%  equivalent to using histcounts(I), then plotting the results.
%
%  [N, C] = QUICKHIST(I) will return the histogram counts N and the bin
%  centers C. 
%
%  Additional parameters which are valid for histcounts can also be passed
%  to the function: QUICKHIST(I, parameters).
%
%  See also: histcounts

[nCnts, binEdges] = histcounts(imageIn(:),varargin{:});
binCenters = diff(binEdges) + binEdges(1:end-1);

if nargout == 0
    plot(binCenters, nCnts)
    xlabel('Greyscale')
    ylabel('Counts')
else
    varargout{1} = nCnts;
    if nargout >= 2
        varargout{2} = binCenters;
    end
end


end