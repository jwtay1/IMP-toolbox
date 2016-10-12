classdef nd2reader
    %nd2reader    Read and export ND2 images using the Bio-Formats API
    %  The nd2reader is an object which interfaces with the Bio-Formats API
    %  by OpenMicroscopy.org. The object can extract specific image frames
    %  from an ND2 file to the MATLAB workspace.
    %
    %  nd2reader Properties:
    %     filename - File associated with this object
    %     SizeC - Number of channels
    %     SizeT - Number of timepoints (i.e. frames)
    %     SizeZ - Number of z-sections
    %     SeriesCount - Number of series
    %     ImageWidth - Width of image, number of columns in image data
    %     ImageHeight - Height of image, number of rows in image data
    %     TotalImageCount - Total number of images in the ND2 file
    %
    %  nd2reader Methods:
    %     nd2reader - Create a new nd2reader object
    %     getStack - Get the image data at a particular timepoint
    %     getFrame - Get the image specified by index
    %
    %  NOTE: Requires the Bio-Formats library to be found on the MATLAB
    %  path.
    %
    %  ------
    %  Bio-Formats installation guide:
    %
    %  1. Download the MATLAB library at:
    %     http://www.openmicroscopy.org/site/products/bio-formats.
    %
    %  2. Unzip the downloaded file to a suitable directory.
    %
    %  3. Add the path of the 'bfmatlab' directory:
    %      addpath('/path/to/bfmatlab')
    %
    %  *To avoid having to do this every time, you can add this command to
    %  the startup.m file. See http://www.mathworks.com/help/matlab/ref/startup.html
    %  for more info.
    
    properties
        filename        %File associated with this object
    end
    
    properties (SetAccess = private)
        SizeC           %Number of channels
        SizeT           %Number of timepoints (i.e. frames)
        SizeZ           %Number of z-sections
        SeriesCount     %Number of series
        
        ImageWidth      %Width of image, number of columns in image data
        ImageHeight     %Height of image, number of rows in image data
    end
    
    properties (Dependent)
        TotalImageCount     %Total number of images in the ND2 file
    end
    
    properties (Hidden = true, SetAccess = private)
        bfReader            %To store the Bio-Formats reader
        ImagesPerSeries     %SizeC * Size Z * SizeT
        EffectiveSizeC      %This changes if image is rgb (unused atm)
    end
    
    methods
        
        function obj = nd2reader(filename)
            %nd2reader  Create a new nd2reader object
            %    To use nd2reader , you need to first create the object.
            %
            %    R = ND2READER(FILE) will open FILE and return an nd2reader
            %    object to R. Subsequent commands can be used:
            %
            %    Examples:
            %       %Open a file and grab the first image
            %       R = ND2READER('someFile.nd2');  %Create the object
            %       image = R.getFrame(1);  %Get the first image
            %       imshow(image)   %Plot the image in a figure
            %
            %       %Get the whole z-stack
            %       imageStack = R.getStack(1); %Grabs all channels and Z
            %
            %       imshow(imageStack{5})   %Plot z = 5
            %
            %   See also GETFRAME GETSTACK
            
            if nargin > 0
                obj.filename = filename;
            end
        end
        
        %         function exportTIF(obj,mode,range,varargin)
        %
        %             switch lower(mode)
        %                 case 'series'
        %
        %                     if ischar(range)
        %                         if strcmpi(range,'all')
        %                             range = 1:obj.SeriesCount;
        %                         else
        %                             error('nd2reader:exportTIF:unknownRange',...
        %                                 'Unknown range value.')
        %                         end
        %                     end
        %
        %                     %Expect range to contain list of series to export
        %                     if any(range < 0) || any(range > obj.SeriesCount)
        %                         error('nd2reader:exportTIF:indexExceedsSeriesCount',...
        %                             'Index exceeds series count.')
        %                     end
        %
        %                     iZ = 1;
        %                     for iS = range
        %                         %Make the filename
        %                         filename = sprintf('Series_%d',iS);
        %
        %                         for iT = 1:obj.SizeT
        %                             frameOut = zeros(obj.ImageWidth,obj.ImageHeight,3);
        %
        %                             for iC = 1:obj.SizeC
        %                                 frameOut(:,:,iC) = getImage(obj,iS,[iZ,iC,iT]);
        %                             end
        %
        %                             if iT == 1
        %                                 imwrite(frameOut,filename)
        %                             else
        %                                 imwrite(frameOut,filename,'WriteMode','append')
        %                             end
        %                         end
        %                     end
        %             end
        %         end
        %
        %     end
        %
        %
        % end
        
        function imageStack = getStack(obj,tFrame,varargin)
            %GETSTACK  Get the image data at a particular timepoint
            %
            %  IM = GETSTACK(R,T) returns the image stack at timepoint T. The
            %  image stack is will contain the whole z-stack and all channels.
            %
            %  IM = GETSTACK(R,T,ROI) will return only the specified
            %  region-of-interest. ROI should be a 1x4 vector [left top
            %  width height].
            %
            %  If obj.SizeZ is 1 (i.e. no z-stack information) or obj.SizeC is
            %  1 (i.e. the images are greyscale only), then IM will be matrix
            %  and the third dimension will contain the relevant axis.
            %
            %  Examples:
            %
            %  The ND2 file contains multiple z-stack single-channel images.
            %   R = nd2reader('someFile.nd2');  %Create the object
            %   IM = GETSTACK(R,T);
            %   imshow(IM(:,:,3)) %Plots Z = 3
            %
            %  The ND2 file contains multiple three-channel images, but no
            %  z-stack.
            %
            %   IM = GETSTACK(R,T);
            %   imshow(IM) %Plotthe multi-color image
            %
            %   %Alternatively, separate out the channels and plot them as
            %   %individual subplots in a new figure
            %   red = IM(:,:,1);
            %   green = IM(:,:,2);
            %   blue = IM(:,:,3);
            %
            %   figure;
            %   subplot(1,3,1)
            %   imshow(red)
            %   title('Red channel')
            %
            %   subplot(1,3,2)
            %   imshow(green)
            %   title('Green channel')
            %
            %   subplot(1,3,3)
            %   imshow(blue)
            %   title('Blue channel')
            %
            %   See also GETFRAME
            
            iS = fix( (tFrame - 1)/obj.SizeT) + 1;
            iT = tFrame - (iS - 1) * obj.SizeT;
            
            if obj.SizeZ == 1
                for iC = 1:obj.SizeC
                    imageStack(:,:,iC) = obj.getImage(iS,[1, iC, iT],varargin); %#ok<AGROW>
                end
                
            elseif obj.SizeC == 1
                for iZ = 1:obj.SizeZ
                    imageStack(:,:,iZ) = obj.getImage(iS,[iZ, 1, iT],varargin); %#ok<AGROW>
                end
                
            else
                imageStack = cell(1,obj.SizeZ);
                
                for iZ = 1:obj.SizeZ
                    for iC = 1:obj.SizeC
                        imageStack{iZ}(:,:,iC) = obj.getImage(iS,[iZ, iC, iT],varargin);
                    end
                end
            end
            
        end
        
        function IC = getFrame(obj, frameInd, varargin)
            %GETFRAME  Get the image specified by index
            %
            %  IM = GETFRAME(R,IND) returns the image specified by the
            %  index IND.
            %
            %  IM = GETFRAME(R,IND,ROI) will return only the specified
            %  region-of-interest. ROI should be a 1x4 vector [left top
            %  width height].
            %
            %  This function is mostly useful for iterating over multiple
            %  images
            %
            %  Example:
            %  The ND2 file has SizeC = 3, SizeZ = 1, SizeT = 240, and
            %  SeriesCount = 1
            %
            %    R = nd2reader('someFile.nd2');  %Create the object
            %
            %    totalNumberOfImages = R.TotalImageCount;
            %
            %    %Grab one image at a time and do something to them
            %    for iImage = 1:totalNumberOfImages
            %       %Get the next image
            %       image = getFrame(R,iImage);
            %
            %       %Do something with the image
            %     end
            %
            %  The image index numbering depends on the order specified by
            %  the ND2 file. A typical ordering is 'XYCZT'. In that case,
            %  the index increments go as Channel, Z-stack, then Timepoint.
            %
            %  Example:
            %  The ND2 file has SizeC = 3, SizeZ = 1, SizeT = 3, and
            %  SeriesCount = 5
            %
            %    Index - [Channel, Z-Stack, Timepoint, Series]
            %      1   - [1, 1, 1, 1]
            %      2   - [2, 1, 1, 1]
            %      3   - [3, 1, 1, 1]
            %      ...
            %      7   - [1, 1, 3, 1]
            %      10  - [1, 1, 1, 2]
            %
            %  See also GETSTACK
            
            if any(frameInd > obj.TotalImageCount)
                error('nd2reader:getFrame:indexExceedsImageCount',...
                    'Index exceeds total image count');
            end
            
            if ischar(frameInd)
                if strcmpi(frameInd,'all')
                    frameInd = 1:obj.TotalImageCount;
                end
            end
            
            IC = cell(1,numel(frameInd));
            
            for iF = 1:numel(frameInd)
                
                %Get series of current frame
                iS = fix((frameInd-1)/obj.ImagesPerSeries) + 1;
                
                %Remaining indices should be the plane number
                iPlane = frameInd - (iS - 1) * obj.ImagesPerSeries;
                
                IC{iF} = obj.getImage(iS,iPlane,varargin);
            end
            
            if numel(IC) == 1
                IC = IC{1};
            end
        end
        
        function obj = set.filename(obj,newFilename)
            %Set the object filename and opens the file
            
            %Check that the file exists, otherwise return an error
            if ~exist(newFilename,'file')
                error('nd2reader:fileDoesNotExist',...
                    'File does not exist.')
            end
            
            if ~strcmpi(newFilename,obj.filename)
                obj.filename = newFilename;
                obj = obj.getBFReader;    %Update the BF reader
                obj = getImageCounts(obj);
            end
            
        end
        
        function imgcount = get.TotalImageCount(obj)
            %Calculate the total number of images
            %imageCount = EffectiveSizeC * SizeT * SizeZ * SeriesCount
            
            imgcount = obj.EffectiveSizeC * obj.SizeT * obj.SizeZ * obj.SeriesCount;
            
        end
        
    end
    
    methods (Hidden = true)
        function obj = getBFReader(obj)
            %Initialize the Bio-Format API
            
            if ~isempty(obj.filename)
                obj.bfReader = bfGetReader(obj.filename);
            else
                error('nd2reader:noFilename','Specify a file.');
            end
        end
        
        function savedData = saveobj(obj)
            %Save the object
            
            %The only thing we need to save is the filename
            savedData.filename = obj.filename;
        end
        
        function obj = getImageCounts(obj)
            %Update the image counts
            
            if ~isempty(obj.bfReader)
                
                obj.EffectiveSizeC = obj.bfReader.getSizeC;
                obj.SizeC = obj.bfReader.getSizeC;
                obj.SizeT = obj.bfReader.getSizeT;
                obj.SizeZ = obj.bfReader.getSizeZ;
                obj.EffectiveSizeC = obj.bfReader.getEffectiveSizeC;
                obj.SeriesCount  = obj.bfReader.getSeriesCount;
                obj.ImagesPerSeries = obj.bfReader.getImageCount;
                obj.ImageWidth = obj.bfReader.getSizeX;
                obj.ImageHeight = obj.bfReader.getSizeY;
            end
        end
        
        function IC = getSeries(obj,seriesInd,varargin)
            
            if ~isscalar(seriesInd)
                error('nd2reader:getSeries:indexNotScalar',...
                    'Expected a scalar for series index.');
            elseif any(seriesInd > obj.SeriesCount) || any(seriesInd <= 0)
                error('nd2reader:getSeries:exceedSeriesCount',...
                    'Index exceeds series count.');
            end
            
            IC = cell(1,obj.ImagesPerSeries);
            
            ctrImages = 0;
            
            for iZ = 1:obj.SizeZ
                for iT = 1:obj.SizeT
                    for iC = 1:obj.SizeC
                        ctrImages = ctrImages + 1;
                        
                        IC{ctrImages} = obj.readFrame(seriesInd, [iZ, iC, iT],varargin);
                        
                    end
                end
            end
        end
        
        function frameOut = getImage(obj,iS,imageInd,ROI)
            %Use this function to get one specific image from the dataset,
            %but with the coordinates (iS, imageInd). This function handles
            %all the calls to the Bio-formats API, and only returns one
            %image at a time. Write other functions in the main method to
            %loop over images to grab z-stacks etc.
            
            if iS > obj.SeriesCount
                error('nd2reader:readFrame:exceedsSeriesCount',...
                    'Index exceeds series count.')
            end
            
            if ~isscalar(imageInd)
                iZ = imageInd(1);
                iC = imageInd(2);
                iT = imageInd(3);
                
                imageInd = obj.bfReader.getIndex(iZ - 1, iC -1, iT - 1) + 1;
            end
            
            if imageInd > obj.ImagesPerSeries
                error('nd2reader:readFrame:exceedsImageDimensions',...
                    'ROI exceeds image dimensions.');
            end
            
            if ~isempty('ROI')
                ROI = [1 1 obj.ImageWidth obj.ImageHeight];
            else
                if any([ROI(1) ROI(3)] > obj.ImageWidth) || ...
                        any([ROI(2), ROI(4)] > obj.ImageHeight) || ...
                        any(ROI <= 0)
                    error('nd2reader:readFrame:exceedsImageDimensions',...
                        'ROI exceeds image dimensions.');
                end
            end
            
            obj.bfReader.setSeries(iS - 1);
            frameOut = bfGetPlane(obj.bfReader, imageInd, ROI(1),ROI(2), ROI(3),ROI(4));
        end
    end
    
    methods (Static, Hidden = true)
        
        function obj = loadobj(savedData)
            %Load the object
            
            %This triggers set.Filename
            obj = nd2reader(savedData.filename);
        end
        
    end
    
end


%         function coordsOut = resolveInd(obj,indIn)
%
%             %Might be wrong... the order seems to be variable...
%               bfreader has a getZCT function we could use instead if
%               necessary
%
%             if indIn > obj.TotalImageCount
%                 error('nd2reader:resolveInd:indexTooLarge',...
%                     'Index exceeds total number of images.');
%             end
%
%             iS = fix((indIn-1)/obj.ImagesPerSeries) + 1;
%
%             remInd = indIn - (iS - 1) * obj.ImagesPerSeries;
%
%             iT = fix((remInd-1)/ (obj.SizeC * obj.SizeZ)) + 1;
%
%             remInd = remInd - (iT - 1) * (obj.SizeC * obj.SizeZ);
%
%             iZ = fix((remInd-1)/ (obj.SizeC)) + 1;
%
%             remInd = remInd - (iZ - 1) * (obj.SizeC);
%
%             iC = remInd;
%
%             coordsOut = [iS', iZ', iT', iC'];
%
%         end