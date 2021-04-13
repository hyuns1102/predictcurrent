clc;    clear;
fprintf('Loading data ...\n');
data = xlsread('종합.xls');

day_feature = 7;
data_i = DataSet(data,day_feature);

% data = xlsread('종합_keep.xls');
% data_i = Interpolation(data);

L = length(data_i(1,:));    H = length(data_i(:,1));
k = 1;

percent = 0.75;  % Percent of Training Set
training_set = round(H*percent);  

nn = 70;       % 몇 일 전 데이터까지 반영할 것인가

for no = 1:nn
    learning_mode = 2;   % 1.Gradient Descent, 2.Normal Equation
    norm_mode = 1;       % Feature Scaling -> 1.o , 2.x
    
    %--------------------------Feature Scaling-----------------------------
    if norm_mode == 1
        [data_s mu sigma] = featureNormalize(data_i);
        data_n = data_s(1:training_set,:);
    else
        data_n = data_i(1:training_set,:);
    end
    %----------------------------------------------------------------------
    
    ts = length(data_n);    % number of Training Set
    
    %----------------Detemine Feature Vector & Output Vector---------------
    j = 1;
    X = zeros(training_set-no,no*L);
    for i = no+1:ts
        Temp = data_n(i-no:i-1,:)';
        X(j,:) = Temp(:)';
        j = j + 1;
    end
    y = data_i(no+1:ts, 1);
    %----------------------------------------------------------------------
    
    n = length(X(1,:)); % number of features
    m = length(y);      % number of outputs
    
    X = [ones(m, 1) X]; % Add intercept term to X
    
    %---------------------------Linear Regression--------------------------
    if learning_mode == 1
        % fprintf('Running gradient descent ...\n');
        % Choose some alpha value
        alpha = 0.01;
        num_iters = 1000;
        
        % Init Theta and Run Gradient Descent
        theta = zeros(n + 1, 1);
        [theta, J_history] = gradientDescentMulti(X, y, theta, alpha, num_iters);
        theta';
        
        %         % Plot the convergence graph
        %         figure;
        %         plot(1:numel(J_history), J_history, '-b', 'LineWidth', 2);
        %         xlabel('Number of iterations');
        %         ylabel('Cost J');
        %
        %         % Display gradient descent's result
        %         fprintf('Theta computed from gradient descent: \n');
        %         fprintf(' %f \n', theta');
        %         fprintf('\n');
    %---------------------------Normal Equation----------------------------
    else
        theta = pinv(X'*X)*X'*y;
        theta';
    end
    %----------------------------------------------------------------------
    j = 1;
    Test = zeros(H-training_set,no*L);
    for i = training_set + 1:H
        if norm_mode == 1
            Temp = data_s(i-no:i-1,:)';
        else
            Temp = data_i(i-no:i-1,:)';
        end
        Test(j,:) = Temp(:)';
        j = j + 1;
    end  
    %----------------------------Test Error--------------------------------
    Test = [ones(H-training_set,1) Test];       
    price = Test * theta;
    price_r = data_i(training_set + 1:end,1);
    MSE_Test(k) = sum((price-price_r).^2)/(2*(H-training_set));
    %--------------------------Training Error------------------------------
    price2 = X * theta;                         
    MSE_Training(k) = sum((price2-y).^2)/(2*training_set);
    %----------------------------------------------------------------------
    fprintf("no=%d 일 때, Training Error : %.4f, Test Error : %.4f\n",no,MSE_Training(k),MSE_Test(k));
    k = k + 1;
    %-----------------------예측 환율과 실제 환율 비교-----------------------
    a = 1:H-training_set;
    plot(a,price_r,'r*-',a,price,'bo-')
    title('환율 예측 그래프')
    set(gca,'XTick',[1:H-training_set]);
    set(gca,'Xticklabel',char('15.6','7','8','9','10','11','12',...
        '16.1','2','3','4','5','6','7','8','9','10','11','12',...
        '17.1','2','3','4','5','6','7','8','9','10','11','12'))
    set(gca,'YTick',[1080:10:1240]);
    grid on
    xlabel('날짜(월)');  ylabel('환율(원/달러)')
    legend('실제 환율','예측 환율' ,'Location', 'Northeast')
end
% ------------------------------오차 비교-----------------------------------
figure;
no = 1:nn;  no = no*20;
plot(no,MSE_Training,'r*-',no,MSE_Test,'bo-');
grid on
xlabel('feature 개수 (20*no)'); ylabel('Error')
legend('Training Error','Test Error','Location','Best')