function varargout = imcomposite(imagedata,varargin)

%---Start function code---%

%Get image data
img_size = size(imagedata);

varargin = {imagedata, varargin{:}};

%Make the rgb matrix
rgb = ones([img_size,3]);

mask = false(img_size);

mask_color = zeros([img_size,3]);

%Parse the inputs
for ii = 1:numel(varargin)
    
    %Process the input if it's numeric
    if isnumeric(varargin{ii})
        if ~all(varargin{ii}(:) == 1 | varargin{ii}(:) == 0)
            %The input is an image
            color = [1 1 1];
            alpha = 1;
            composite_mode = 'blend';
            
            %First normalize the current image to range [0, 1]
            imdata = double(varargin{ii});
            
            imdata = (imdata - min(imdata(:))) .* (1/(max(imdata(:)) - min(imdata(:))));
            
            %Look at the next input of varargin to see if it contains
            %parameters
            if iscell(varargin{ii + 1})
                
                parameters = varargin{ii + 1};
                
                for iParam = 1:numel(parameters)
                    currParam = parameters{iParam};
                    
                    if isnumeric(currParam)
                        if size(currParam,1) == 1 && size(currParam,2) == 3
                            color = currParam;
                        elseif size(currParam,1) == 1 && size(currParam,2) == 1
                            if alpha > 1
                                error('Value for alpha has to be < 1')
                            end                           
                            
                            alpha = currParam;
                        end
                    else
                        switch lower(currParam)
                            
                            case 'blend'
                                composite_mode = 'blend';
                                
                            case 'divide'
                                composite_mode = 'divide';
                                
                        end
                    end
                    
                end
            end
            
            if ii == 1
                alpha = 1;
                composite_mode = 'blend';
                
            end
                            
            switch lower(composite_mode)
                
                case 'blend'
                    
                    rgb = rgb .* (1 - alpha);
                    
                    rgb(:,:,1) = rgb(:,:,1) + alpha .* imdata .* color(1);
                    rgb(:,:,2) = rgb(:,:,2) + alpha .* imdata .* color(2);
                    rgb(:,:,3) = rgb(:,:,3) + alpha .* imdata .* color(3);
                    
                case 'divide'
                    
                    rgb(:,:,1) = rgb(:,:,1) ./ imdata;
                    rgb(:,:,2) = rgb(:,:,2) ./ imdata;
                    rgb(:,:,3) = rgb(:,:,3) ./ imdata;
                    
            end
            
            
            
            
            
        else
            %The input is a mask
            maskin = logical(varargin{ii});
            
            color = [1 1 1];
            
            %Check for a color parameter
            if iscell(varargin{ii + 1})
                
                for iP = 1:numel(varargin{ii+1})
                    currParameter = varargin{ii + 1}{iP};
                    if isnumeric(currParameter) && size(currParameter,1) == 1 && size(currParameter,2) == 3
                        color = currParameter;
                        break;
                    end
                end
                
            end
            
            mask = mask | maskin;
            
            for iC = 1:3
                currmask = mask_color(:,:,iC);
                
                currmask(maskin) = color(iC);
                
                mask_color(:,:,iC) = currmask;
            end
            
            
        end
        
        
    end
end

%Assemble the final image
for iC = 1:3
    currChannel = rgb(:,:,iC);
    currMaskChannel = mask_color(:,:,iC);
    
    currChannel(mask) = currMaskChannel(mask);
    
    rgb(:,:,iC) = currChannel;
end

%Output
if nargout == 0
    imshow(rgb)
elseif nargout == 1
    varargout{1} = rgb;
end