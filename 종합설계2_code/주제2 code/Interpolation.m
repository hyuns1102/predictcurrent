function output = Interpolation(input)
% clc;    clear;
% data = xlsread('а╬гу_keep.xls');
% input = data;

L = length(input(1,:));     H = length(input(:,1));

fprintf('Interpolaion...\n');

for i = 1:L
    XX = input(1:156,i);
    num = length(XX) / 12;      % number of years
    x = [1 31 50 81 121 152 182 213 244 274 305 335] + 15 ;
    x = [x x+365 x+365*2 x+365*3 x+365*4 x+365*5 x+365*6 x+365*7 x+365*8 x+365*9 x+365*10 x+365*11 x+365*12];
    xx = 1:365*num+3;             % number of days
    Int = spline(x,XX,xx);      % interpolation
    X(:,i) = Int;
%     figure(i)
%     plot(x,XX,'r*-',xx,Int,'b-')
end

output = X;
