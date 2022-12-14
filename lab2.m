%function call
prompt = "Enter the array of Dataword:";
dataword = input(prompt);
prompt = "Enter the array of Divisor:"; % input both divisor and dataword arrays
divisor = input(prompt);

[transmitted_codeword] = encoder(dataword,divisor); %encoding

p = 0.5; % error probability  
recieved_codeword = bsc(transmitted_codeword,p); %pass through  a BSC channel
disp("recieved codeword :")
disp(recieved_codeword)

decoder(recieved_codeword,divisor); %calculating syndrome

%encoder function
function [codeword,div_len,data_len,dataword,divisor,shift,cont_len,div_initial,data_initial] = encoder(dataword ,divisor )
    div_len = length(divisor);
    data_len = length(dataword); %calculate the length of the divisor and dataword
    data_initial = dataword; %keep the initial dataword
    dataword = [dataword repmat([0],1,(div_len - 1))];
    divisor = [divisor repmat([0],1,(data_len - 1))]; %make dataword and divisor into same length
    div_initial = divisor; %keep the initial divisor
    cont_len = length(divisor);
    while ~(all(dataword(1:data_len)<1))
        dataword = double(xor(dataword,divisor)); %take the xor between dataword and divisor
        if all(dataword(1:data_len)<1)
            shift = [0]; %shift is zero then divisor remain unchange
        else
            shift = find(dataword);
            divisor = [repmat([0],1,(shift(1)-1)) div_initial(1:cont_len-shift(1)+1)]; %shift the divisor
        end
    end    
    disp("transmitted Codeword :")
    codeword = [data_initial dataword(cont_len-div_len+2:cont_len)];
    disp(codeword) %print the codeword
end

%decoder function
function [syndrome,code_len,div_len,div_initial,code_initial,divisor,data_len,shift] = decoder(codeword,divisor)
    code_len = length(codeword);
    div_len = length(divisor); %calculate length of the divisor and codeword
    code_initial = codeword; %keep initial values of the codeword and the divisor
    divisor = [divisor repmat([0],1,(code_len-div_len))]; %shift divisor up to length of the codeword
    div_initial = divisor;
    data_len = code_len-div_len+1;
    while ~(all(codeword(1:data_len)<1))
        codeword = double(xor(codeword,divisor)); %take the xor between two array and convert that to double
        if all(codeword(1:data_len)<1)
            shift = [0]; %shift is zero then divisor remain unchange
        else
            shift = find(codeword); %find position of the non zero values
            divisor = [repmat([0],1,(shift(1)-1)) div_initial(1:code_len-shift(1)+1)]; %shift the divisor 
        end    
    end    
    disp("Syndrome :")
    syndrome = codeword(data_len+1:code_len); %calculate the syndrome
    disp(syndrome)
end