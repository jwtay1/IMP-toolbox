function nd2toavi(file, varargin)
%ND2TOAVI  Convert an ND2 movie into an AVI file
%
%  ND2TOAVI(filename) will convert the ND2 file specified into an AVI
%  movie.
%
%  Currently only monochromatic ND2 files are supported.

if ~isempty(varargin)
    channel = varargin{1};
else
    channel = 1;
end



bfr = BioformatsImage(file);

% tempImg = bfr.getPlane(1, channel, bfr.sizeT);
% maxInt = double(max(tempImg(:)));
for iS = 1:bfr.seriesCount
    
    bfr.series = iS;
    
    %Output fn
    fnout = [file(1:end - 4), '_s', int2str(iS), '.avi'];
    vid = VideoWriter(fnout);
    vid.FrameRate = 7;
    open(vid);
    
    for iT = 1:bfr.sizeT
        
        img = double(getPlane(bfr, 1, channel, iT, 'ROI', [764 223 1100 700]));
%         
%         if iT == 1
%             prevImage = img;
%         else
%             pxShift = CyTracker.xcorrreg(prevImage, img);
%             img = CyTracker.shiftimg(img, pxShift);
%             prevImage = img;
%         end
        
        img = img ./ max(img(:));
        
        img = imresize(img, 2, 'nearest');
        
        writeVideo(vid, img);
    end
end
close(vid);

end