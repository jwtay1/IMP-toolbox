classdef nd2reader
    
    properties
        filename
    end
    
    properties (SetAccess = private)
        SizeC    %Number of channels
        SizeT    %Number of timepoints
        SizeZ    %Number of z-sections
        SeriesCount  %Number of series
        
        ImageWidth
        ImageHeight
    end
    
    properties (Dependent)
        TotalImageCount
    end
    
    properties (Hidden = true, SetAccess = private)
        bfReader
        ImagesPerSeries
        EffectiveSizeC
    end
    
    methods
        
        function obj = nd2reader(filename)
            %ND2READER    Class file to read Nikon ND2 images
            %
            %  R = ND2READER(FILE) will create an object R
            
            if nargin > 0
                obj.filename = filename;
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
                for iC = 1:obj.SizeC
                    for iT = 1:obj.SizeT
                        
                        ctrImages = ctrImages + 1;
                        
                        IC{ctrImages} = obj.readFrame(seriesInd, [iZ, iC, iT],varargin);
                        
                    end
                end
            end
        end
        
        function imageStack = getStack(obj,tFrame,varargin)
        %GETSTACK  Get the image data at a particular timepoint
        %
        %  IM = GETSTACK(obj,T) returns the image stack at timepoint T. The
        %  image stack is will contain the whole z-stack and all channels.
            
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
            %GETFRAME  Gets the specified image frame
            
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
        end
        
        function frameOut = getImage(obj,iS,imageInd,ROI)
            %Use this function to get one specific image from the dataset
            
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
        
        function obj = set.filename(obj,newFilename)
            
            if ~strcmpi(newFilename,obj.filename)
                obj.filename = newFilename;
                obj = obj.getBFReader;    %Update the BF reader
                obj = getImageCounts(obj);
            end
            
        end
        
        function obj = getBFReader(obj)
            
            if ~isempty(obj.filename)
                obj.bfReader = bfGetReader(obj.filename);
            else
                error('nd2reader:noFilename','Specify a file.');
            end
            
        end
        
        function obj = getImageCounts(obj)
            
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
        
        function imgcount = get.TotalImageCount(obj)
            
            imgcount = obj.EffectiveSizeC * obj.SizeT * obj.SizeZ * obj.SeriesCount;
            
        end
        
        function savedData = saveobj(obj)
            %The only thing we need to save is the filename
            savedData.filename = obj.filename;
        end
        
    end
    
    methods (Static)
        
        function obj = loadobj(savedData)
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