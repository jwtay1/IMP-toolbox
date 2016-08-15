function [optimAssign, optimCost, unassigned_cols] = munkres(costMatrix)
%MUNKRES  Munkres (Hungarian) linear assignment
%
%  [I, C] = MUNKRES(M) returns the column indices I assigned to each row,
%  and the minimum cost C based on the assignment. The cost of the
%  assignments are given in matrix M, with workers along the rows and tasks
%  along the columns. The matrix optimizes the assignment by minimizing the
%  total cost.
%
%  The code can deal with partial assignments, i.e. where M is not a square
%  matrix. Unassigned rows (workers) will be given a value of 0 in the 
%  output I. [I, C, U] = MUNKRES(M) will give the index of unassigned 
%  columns (tasks) in vector U.
%
%  The algorithm attempts to speed up the process in the case where values
%  of a row or column are all Inf (i.e. impossible link). In that case, the
%  row or column is excluded from the assignment process; these will be
%  automatically unassigned in the result.  

%This code is based on the algorithm described at:
%http://csclab.murraystate.edu/bob.pilgrim/445/munkres.html

%Get the size of the matrix
[nORows, nOCols] = size(costMatrix);

%Check for rows and cols which are all infinity, then remove them
validRows = ~all(costMatrix == Inf,2);
validCols = ~all(costMatrix == Inf,1);

nRows = sum(validRows);
nCols = sum(validCols);

nn = max(nRows,nCols);

if nn == 0
    error('Invalid cost matrix: Cannot be all Inf.')
elseif any(isnan(costMatrix(:))) || any(costMatrix(:) < 0)
    error('Invalid cost matrix: Expected costs to be all positive numbers.')
end

%Make a new matrix
tempCostMatrix = ones(nn) .* (10 * max(max(costMatrix(costMatrix ~= Inf))));
tempCostMatrix(1:nRows,1:nCols) = costMatrix(validRows,validCols);

tempCostMatrix(tempCostMatrix == Inf) = realmax;

%Get the minimum values of each row
rowMin = min(tempCostMatrix,[],2);

%Subtract the elements in each row with the corresponding minima
redMat = bsxfun(@minus,tempCostMatrix,rowMin);

%Mask matrix (0 = not a zero, 1 = starred, 2 = primed)
mask = zeros(nn);

%Vectors of column and row numbers
rowNum = 1:nn;
colNum = rowNum;

%Row and column covers (1 = covered, 0 = uncovered)
rowCover = zeros(1,nn);
colCover = rowCover;

%Search for unique zeros (i.e. only one starred zero should exist in each
%row and column
for iRow = rowNum(any(redMat,2) == 0)
    for iCol = colNum(any(redMat(iRow,:) == 0))
        if (redMat(iRow,iCol) == 0 && rowCover(iRow) == 0 && colCover(iCol) == 0)
            mask(iRow,iCol) = 1;
            rowCover(iRow) = 1;
            colCover(iCol) = 1;
        end
    end
end

%Clear the row cover
rowCover(:) = 0;

%The termination condition is when each column has a single starred zero
while ~all(colCover)
    
    %---Step 4: Prime an uncovered zero---%
    %Find a non-covered zero and prime it.
    %If there is no starred zero in the row containing this primed zero,
    %proceed to step 5.
    %Otherwise, cover this row and uncover the column contianing the
    %starred zero.
    %Continue until there are no uncovered zeros left. Then get the minimum
    %value and proceed to step 6.
    
    stop = false;
    
    %Find an uncovered zero
    for iRow = rowNum( (any(redMat == 0,2))' & (rowCover == 0) )
        for iCol = colNum(redMat(iRow,:) == 0)
            
            if (redMat(iRow,iCol) == 0) && (rowCover(iRow) == 0) && (colCover(iCol) == 0)
                mask(iRow,iCol) = 2;    %Prime the zero
                
                if any(mask(iRow,:) == 1)
                    rowCover(iRow) = 1;
                    colCover(mask(iRow,:) == 1) = 0;
                else
                    
                    %Step 5: Augment path algorithm
                    currCol = iCol; %Initial search column
                    storePath = [iRow, iCol];
                    
                    %Test if there is a starred zero in the current column
                    while any(mask(:,currCol) == 1)
                        %Get the (row) index of the starred zero
                        currRow = find(mask(:,currCol) == 1);
                        
                        storePath = [storePath; currRow, currCol];
                        
                        %Find the primed zero in this row (there will
                        %always be one)
                        currCol = find(mask(currRow,:) == 2);
                        
                        storePath = [storePath; currRow, currCol];
                    end
                    
                    %Unstar each starred zero, star each primed zero in the
                    %searched path
                    indMask = sub2ind([nn,nn],storePath(:,1),storePath(:,2));
                    mask(indMask) = mask(indMask) - 1;
                    
                    %Erase all primes
                    mask(mask == 2) = 0;
                    
                    %Uncover all rows
                    rowCover(:) = 0;
                    
                    %Step 3: Cover the columns with stars
                    colCover(:) = any((mask == 1),1);
                    
                    stop = true;
                    break;
                end
            end
            
            %---Step 6---
            
            %Find the minimum uncovered value
            minUncVal = min(min(redMat(rowCover == 0,colCover== 0)));
            
            %Add the value to every element of each covered row
            redMat(rowCover == 1,:) = redMat(rowCover == 1,:) + minUncVal;
            
            %Subtract it from every element of each uncovered column
            redMat(:,colCover == 0) = redMat(:,colCover == 0) - minUncVal;
        end
        
        if (stop)
            break;
        end
    end
   
end

%Assign the outputs
optimAssign = zeros(nORows,1);
optimCost = 0;

unassigned_cols = 1:nCols;

validRowNum = 1:nORows;
validRowNum(~validRows) = [];

validColNum = 1:nOCols;
validColNum(~validCols) = [];

%Only assign valid workers
for iRow = 1:numel(validRowNum)
    
    assigned_col = colNum(mask(iRow,:) == 1);
    
    %Only assign valid tasks
    if assigned_col > numel(validColNum)
        %Assign the output
        optimAssign(validRowNum(iRow)) = 0;
    else
        optimAssign(validRowNum(iRow)) = validColNum(assigned_col);
        
%         %Calculate the optimized (minimized) cost
        optimCost = optimCost + costMatrix(validRowNum(iRow),validColNum(assigned_col));
        
        unassigned_cols(unassigned_cols == assigned_col) = [];
    end
end
end






