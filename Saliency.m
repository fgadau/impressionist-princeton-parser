clc
clear
close all
%created by Fabian Gadau for the Prof. Yi Ren's DOI Lab

% number of files you have and the names that they are
% in this case it will parse files 1.off - 10.off into .json files
% that work with the algorithm. These files only need to be placed in the
% workspace.
num = 1;
    
name = strcat(int2str(num),'.off');
ID = importdata(name);

vertexArray = zeros(ID.data(1,1),3);
faceArray = zeros(ID.data(1,2),3);

sal.A = zeros(length(faceArray));

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





