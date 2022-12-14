%function call
list_num = randi(511,1,10000);
prob = [0.5 0.4 0.3 0.2 0.1 0.01 0.001 0.0001];
divisor = [1 0 1 1 1];
Avg_data_err = [];
for p = prob
    N_e= 0; %number of errer
    for i=list_num
        i_binary = flip(de2bi(i));
        [transmitted_codeword] = encoder(i_binary,divisor); %encoding
        recieved_codeword = bsc(transmitted_codeword,p); %pass through  a BSC channel
        [syndrome]=decoder(recieved_codeword,divisor); %calculating syndrome
        if ~all(syndrome<1)
            N_e = N_e + 1 ;
        end    
    end
    Avg_data_err = [Avg_data_err [N_e/10000]]; 
end

plot(prob,Avg_data_err);

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
    %disp("transmitted Codeword :")
    codeword = [data_initial dataword(cont_len-div_len+2:cont_len)];
    %disp(codeword) %print the codeword
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
    %disp("Syndrome :")
    syndrome = codeword(data_len+1:code_len); %calculate the syndrome
    %disp(syndrome)
end