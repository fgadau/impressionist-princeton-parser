clc
clear
close all
%created by Fabian Gadau for the Prof. Yi Ren's DOI Lab

% number of files you have and the names that they are
% in this case it will parse files 1.off - 10.off into .json files
% that work with the algorithm. These files only need to be placed in the
% workspace.

% the princeton mesh number
num = 381;
    
name = strcat(int2str(num),'.off');
ID = importdata(name);

% get face indices
vertexArray = zeros(ID.data(1,1),3);
faceArray = zeros(ID.data(1,2),3);

Sal.A = zeros(length(vertexArray));

for i = 2:length(ID.data)
    if ID.data(i,1)==3
%        linebreak = i 
       break;
    end
end

for j = 2:i-1
    vertexArray(j-1,:) = ID.data(j,:);
end

k = 1;

for j = i:2:length(ID.data)
    faceArray(k,1) = ID.data(j,2);

    faceArray(k,2) = ID.data(j,3);

    faceArray(k,3) = ID.data(j+1,1);

    k = k+1;
end

facesSortedByVertex = zeros(length(vertexArray),25);
shiftedFaceArray = faceArray + 1;


for i = 1:length(faceArray)
    for j = 1:3
        k = 1;
        while facesSortedByVertex(shiftedFaceArray(i,j),k) ~= 0
            k = k+1;
        end
        facesSortedByVertex(shiftedFaceArray(i,j),k) = i;
    end
end

IndNeighVertices = zeros(length(vertexArray),25);

for i = 1:length(vertexArray)
    j = 1;
    k = 1;
    wDuplicates = zeros(1,100);
    while facesSortedByVertex(i,j) ~= 0

       for a = 1:3
            wDuplicates(k) = ...
                shiftedFaceArray(facesSortedByVertex(i,j),a);
            k = k + 1;
       end
       
        j = j + 1;

    end
    uniqueVertices = unique(wDuplicates);
    c = 1;
    for b = 1:length(uniqueVertices)
        
        if uniqueVertices(b) ~= 0 && uniqueVertices(b) ~= i
            IndNeighVertices(i,c) = uniqueVertices(b);
            c = c+1;
        end
        
    end
    
end

DisNeighVertices = zeros(length(vertexArray),25);
Sal.D = zeros(length(vertexArray), 1);
for i = 1:length(vertexArray)
    j = 1; 
    
    while IndNeighVertices(i,j) ~= 0
        DisNeighVertices(i,j) = 1/(...
          (vertexArray(i,1)-vertexArray( IndNeighVertices(i,j),1) )^2 + ...
          (vertexArray(i,2)-vertexArray( IndNeighVertices(i,j),2) )^2 + ...
          (vertexArray(i,3)-vertexArray( IndNeighVertices(i,j),3) )^2);
%         Sal.D(i) = j;
        j = j + 1;
    end
    
    s = sum(DisNeighVertices(i,:));
    Sal.D(i) = s;
%     
%     for j = 1:min(size(DisNeighVertices))
%         DisNeighVertices(i,j) = DisNeighVertices(i,j)/s;
%     end
%     
end

Sal.L = zeros(length(vertexArray));
Sal.W = zeros(length(vertexArray));

for i = 1:length(Sal.A)
    Sal.L(i,i) = Sal.D(i);
    j = 1;
    while IndNeighVertices(i,j) ~= 0
        Sal.L(i,IndNeighVertices(i,j)) = -DisNeighVertices(i,j);
        Sal.W(i,IndNeighVertices(i,j)) = -DisNeighVertices(i,j);
        j = j + 1;
    end
    
end

[Sal.B, Sal.LambdaDiag] = eig(Sal.L);
Sal.Lambda = zeros(length(Sal.LambdaDiag),1);
for i = 1:length(Sal.LambdaDiag)
    Sal.Lambda(i) = Sal.LambdaDiag(i,i);
end

Sal.Lambda = log10(Sal.Lambda);
%Sal.Lambda(1) = 0;

Sal.A = zeros(length(Sal.Lambda), 1);
%use original normalized values
buffer = 4;
for i = 1:length(Sal.Lambda)
    k = 0;
    for j = i-buffer:i+buffer      
        if j > 0 && j <= length(Sal.Lambda)
            Sal.A(i) = Sal.A(i) + Sal.Lambda(j);
            k = k + 1;
        end
    end
    Sal.A(i) = Sal.A(i)/k;
end


Sal.R = zeros(length(Sal.LambdaDiag));
for i = 1:length(Sal.R)
    Sal.R(i,i) = exp(abs(Sal.A(i) - Sal.Lambda(i)));

end

Sal.S = Sal.B * Sal.R * Sal.B' * Sal.W;

Sal.Results = zeros(length(Sal.LambdaDiag),1);
for i = 1:length(Sal.R)
    Sal.Results(i) =Sal.S(1,i); %sum(Sal.S(i,:));

end


Sal.maxMinLambda = [max(Sal.Results), min(Sal.Results)];

parsed.Results = Sal.Results;
parsed.maxMinLambda = Sal.maxMinLambda;
% 
jsonified = savejson('parsed',parsed);
nameString =  strcat(int2str(num),'topo.json');
fid = fopen(nameString, 'wt');
fprintf(fid, jsonified);
fclose(fid);
% 








