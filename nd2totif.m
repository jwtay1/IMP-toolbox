function nd2totif(filename,outputdir,varargin)
%ND2TOTIF  Helper for converting ND2 file to TIFF
%
%  ND2TOTIF(ND2FILE,OUTPUTDIR) will export the image stack in
%  ND2FILE to a series of TIFF files to the directory specified in
%  OUTPUTDIR. Each channel in the series will be exported as an
%  individual file. 
%
%  In this usage, the user will be prompted to enter names for each
%  channel. If this is declined, the channels will be named 'Channel_Y'
%  where Y is the channel number by default.
%
%  ND2TOTIF(ND2FILE,'') will output the files to the current directory.  
%
%  ND2TOTIF(ND2FILE,OUTPUTDIR,{'CH1_', 'CH2_', ...}) will name the files
%  corresponding to individual channels with the respective prefix. For 
%  example, if there are two channels in the image data, the function will 
%  label the two channels 'CH1_X.tif' and 'CH2_X.tif' where X is the series
%  number.
%
%  NOTE: This helper function requires the Bio-Formats library to be found
%  on the MATLAB path.
%
%  ------
%  Bio-Formats installation guide:
%
%  1. Download the MATLAB library at:
%     http://www.openmicroscopy.org/site/products/bio-formats.
%
%  2. Unzip the downloaded file to a suitable directory.
%
%  3. Add the path by using addpath('/path/to/bfmatlab')

%Check that bfopen exists. If not, remind user to download the Bio-Formats
%library
if ~exist('bfopen','file')
    error('ND2TOTIF:bfopenNotFound',...
        'Could not find the bfopen function. Make sure the Bio-Formats library is installed and on the search path. See HELP for more details.');
end    


%Get file information
reader = bgGetReader(filename);

nImages = reader.getImageCount;
nSeries = reader.getSeriesCount;
nChannels = reader.getSizeC;
nPlanes = reader.getSizeT;

imgnRows = reader.getSizeY;     %height
imgnCols = reader.getSizeX;     %width

nZstack = reader.getSizeZ;      %depth


%data = bfopen(filename);    %Open the ND2 file

%Extract the raw data
nSeries = size(data,1);

%Assume that there is at least one series
nChans = size(data{1,1},1);

%If the output filenames have not been specified, get the user to specify
%them. Otherwise, specify a default naming convention (Channel_x)
output_filenames = (varargin);

if numel(output_filenames) < nChans
    %Prompt for filename
    fprintf('Found %d channels but %d filenames \n',nChans,numel(output_filenames));
    renamefile = input('Would you like to specify filenames (y-yes)? ','s');
    
    if any(strcmpi(renamefile,{'y','yes'}))
        for iF = (numel(output_filenames) + 1):nChans
            currfn = input(sprintf('Enter prefix for channel %d: ',iF),'s');
            
            if isempty(currfn)
                error('Filename cannot be empty');
            end
            
            output_filenames{iF} = currfn;
        end
    else
        for iF = (numel(output_filenames) + 1):nChans
            output_filenames{iF} = sprintf('Channel_%d ',iF);
        end
    end
end

%Check if output directory exists, if not create it
if ~exist(outputdir,'dir')
    mkdir(outputdir);
end

%Append the output directory
for ii = 1:numel(output_filenames)
    output_filenames{ii} = fullfile(outputdir,output_filenames{ii});
end

for ii = 1:numel(output_filenames)
    %Check if file exists
    if ~isempty(dir([output_filenames{ii},'*.tif']))
        button = questdlg('Overwrite existing files?','Overwrite',...
            'Yes','No','No');
        if strcmp(button,'No')
            error('Files with the same name already exist.')
        else
            break
        end
    end
end

for iS = 1:nSeries
    
    for iC = 1:nChans
        
        imagedata = data{iS,1}{iC,1};
        
        imwrite(imagedata,sprintf('%s%d.tif',output_filenames{iC},iS),'tif');
        
    end
    
end

end