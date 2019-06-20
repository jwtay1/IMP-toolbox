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

vid = VideoWriter([file(1:end-4), '.avi']);
vid.FrameRate = 7;
open(vid);

bfr = BioformatsImage(file);

% tempImg = bfr.getPlane(1, channel, bfr.sizeT);
% maxInt = double(max(tempImg(:)));

for iT = 1:bfr.sizeT
    img = double(bfr.getPlane(1, channel, iT));
    img = img ./ max(img(:));
    
    writeVideo(vid, img);
end

close(vid);

end