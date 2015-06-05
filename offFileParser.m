for num = 1:10
    
    name = strcat(int2str(num),'.off');
    A = importdata(name);
    newName = strcat(name(1),'.json');

    vertexArray = zeros(A.data(1,1),3);
    faceArray = zeros(A.data(1,2),3);



    for i = 2:length(A.data)
        if A.data(i,1)==3
    %        linebreak = i 
           break;
        end
    end


    for j = 2:i-1
        vertexArray(j-1,:) = A.data(j,:);
    end



    k = 1;

    for j = i:2:length(A.data)
        faceArray(k,1) = A.data(j,2);

        faceArray(k,2) = A.data(j,3);

        faceArray(k,3) = A.data(j+1,1);

        k = k+1;
    end

    parsed.vertexArray = vertexArray;
    parsed.faceArray = faceArray;
    parsed.name = newName;


    jsonified = savejson('parsed',parsed);

    fid = fopen(newName, 'wt');
    fprintf(fid, jsonified);
    fclose(fid);

end