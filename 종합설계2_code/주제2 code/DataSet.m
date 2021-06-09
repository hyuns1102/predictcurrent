function output = DataSet(data,num)

for i = 1:num
    data_tmp1 = data(:,i);
    H = length(data_tmp1);
    for j = 1:H
        if isnan(data_tmp1(j)) == 1
            data_tmp1(j) = data_tmp1(j-1);
        end
    end
    X1(:,i) = data_tmp1;
end

data_tmp2 = data(:,num+1:end);
X2 = Interpolation(data_tmp2);
output = [X1 X2];