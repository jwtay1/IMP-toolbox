function output_images = readnd2(filename,varargin)
%READND2  Opens ND2 files and puts images in the workspace
%
%  IC = READND2(FILENAME) opens the ND2 file specified and extracts the
%  raw images into the cell IC. Images are inserted into consecutive cells.
%
%  IC = READND2(FILENAME,ID) returns the image specified by the index ID.
%  Images are numbered
%
%  IC = READND2(FILENAME,
%
%  **Requires the Bio-Formats package to work.**

%Series 1
%  Size T = 3
%  Size C = 3
% Then index should go [C,T,S]

%Turn the low memory warning off
warning('off','BF:lowJavaMemory');

bfreader = bfGetReader(filename);

%Count number of images
nImagePerSeries = bfreader.getImageCount;
nChannels = bfreader.getEffectiveSizeC;
nPlanes = bfreader.getSizeT;
nZStack = bfreader.getSizeZ;
nSeries = bfreader.getSeriesCount;

totalNumberOfImages = nSeries * nImagePerSeries;

output_images = cell(1,totalNumberOfImages);

ctrImage = 1;

for iSeries = 1:nSeries
    bfreader.setSeries(iSeries - 1);
    
    for iZ = 1:nZStack
        
        for iT = 1:nPlanes
            for iC = 1:nChannels
                %Get the image plane index
                iPlane = bfreader.getIndex(iZ - 1, iC -1, iT - 1) + 1;
                
                %The the image
                currI = bfGetPlane(bfreader, iPlane);
                
                %Store the image in the output cell
                output_images{ctrImage} = currI;
                
                %Increment the image counter
                ctrImage = ctrImage + 1;
            end
        end
    end
end

if numel(output_images) == 1
    output_images = output_images{1};
    fprintf('Read 1 image.\n');
else
    fprintf('Read %d images.\n',numel(output_images));
end
%Turn the low memory warning back on
warning('on','BF:lowJavaMemory');
end
%
% function [iC, iT, iS] = idxToCTS(idxIn)
%
%
%
%
%
% end
