function imageArray = removeBackground(imageArray, varargin)
%removeBackground Remove background from an image array
%
%   imageArray = removeBackground(imageArray) removes background from an
%   image array. The background is computed using gaussian smoothing and
%   the subtracted from the original array.
%
%   imageArray = removeBackground(imageArray, Name, Value) removes the
%   background from the image array using specified options.
%
%   Optional name/value pairs:
%
%   SpatialFilterSize : "Size" (standard deviation/sigma) of the gaussian kernel
   
    
    assert( ndims(imageArray) == 3, 'Image array must be 3D')
    assert(isa(imageArray, 'single') | isa(imageArray, 'double'), ...
        'Image array must be single or double')
    
    params = struct();
    params.SpatialFilterType = 'gaussian'; % todo...
    params.SpatialFilterSize = 20;
    
    params = utility.parsenvpairs(params, [], varargin{:});
    
    % Smooth using a big gaussian kernel, to wash out cell-sized objects
    switch params.SpatialFilterType
        case 'gaussian'
            sigma = params.SpatialFilterSize;
            bgArray = stack.process.filter2.gauss2d(imageArray, sigma);
        otherwise
            error('Filter type "%s" is not implemented', params.SpatialFilterType)
            
    end

    % Subtract background (smoothed version)
    imageArray = imageArray - bgArray;
    
end