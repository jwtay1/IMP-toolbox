function imgout = binarizeimage(imagedata,threshold,mode,plotimage)

if ~exist('type','var')
    mode = 'over';
end

thresholdValue = prctile(imagedata(:),threshold);

switch lower(mode)
    case 'over'
        imgout = imagedata > thresholdValue;
        
    case 'under'
        imgout = imagedata < thresholdValue;
        
    otherwise
        error('binarizeimage:UnknownMode','Mode should be "over" or "under".')
end

if exist('plotimage','var')
    if plotimage
        subplot(1,2,1)
        imshow(image,[]);
        title('Original image')
        
        subplot(1,2,2)
        imshow(imgout,[]);
        title('Binarized image')
    end
end

end