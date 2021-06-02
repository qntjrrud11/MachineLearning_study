clc,clear,close all
% MLP / MNIST
% Revision date: 2021.05.19
% mnist\trainingData.mat
% images : 28 x 28 x 60000
% labels : 1 x 60000
% sk.boo

% training set (MNIST)
load mnist\trainingData.mat;
X = reshape(images,28^2,[]);% input : 28^2 x 60000
one_hot = diag(ones(1,max(labels)+1));
Y = one_hot(labels+1,:)';% output : 10 x 60000
X = [ones(1,length(X)) ; X]; % bias add
X = (X-mean(X))./std(X);

%number of nodes
in_node_n = length(X(:,1));
hd_node_n = 20;
hd2_node_n = 15;
out_node_n = length(Y(:,1));

%learning rate
lr = 0.2;

%weight matrix
U1 = randn(hd_node_n,in_node_n);
U2 = randn(hd2_node_n,hd_node_n+1);
U3 = randn(out_node_n,hd2_node_n+1);

epo = 1000;
tic
sample_n = 64;
for j=1:epo
    index = 1:length(X);
    o = zeros(size(Y));
    
    sample_index = randperm(length(X));
    X_sample = X(:,sample_index(1:sample_n));
    Y_sample = Y(:,sample_index(1:sample_n));
    
    dU1 = zeros(size(U1));
    dU2 = zeros(size(U2));
    dU3 = zeros(size(U3));
    
    for i=1:sample_n
       %% forward
        hidden_node = [1; Forward_mlp(@Relu,X_sample(:,i),U1)];
        hidden_node = (hidden_node-mean(hidden_node))./std(hidden_node);
        hidden2_node = [1; Forward_mlp(@Relu,hidden_node,U2)];
        hidden2_node = (hidden2_node-mean(hidden2_node))./std(hidden2_node);
        o = Forward_mlp(@exp,hidden2_node,U3)/sum(Forward_mlp(@exp,hidden2_node,U3));
       %% Error
        o_num(i) = find(o==max(o));
        y_num(i) = find(Y_sample(:,i)==1);
        error(i,:) = -sum(Y_sample(:,i).*log(o));
        
       %% error backpropagation
        gradient1 = (Y_sample(:,i) - o);
        dU3 = dU3 -gradient1*hidden2_node';
        gradient2 = (gradient1'*U3(:,2:end))'.*Forward_mlp(@ReluGradient,hidden_node,U2);
        dU2 = dU2 -gradient2*hidden_node';
        gradient3 = (gradient2'*U2(:,2:end))'.*Forward_mlp(@ReluGradient,X_sample(:,i),U1);
        dU1 = dU1 -gradient3*X_sample(:,i)';
    end
    
    %update weight
    U3 = U3 -lr*dU3/sample_n;
    U2 = U2 -lr*dU2/sample_n;
    U1 = U1 -lr*dU1/sample_n;
    
    clc
    tex2 = mean(o_num == y_num);
    tex1 = mean(error);
    mse(j,1) = tex1;
    fprintf("학습 횟수 : %d번\n",j)
    fprintf("학습된 글자 수 : %d 개 (한 번 반복에 64개씩 학습을 진행합니다.)\n",j*sample_n)
    fprintf("학습 데이터 손글씨 인식률 : %0.2f%%\n",round(tex2*100,4))
    fprintf("전체 학습 오차(MSE) : %0.5f\n",round(tex1,4))
    cla
    
    plot(mse);
    axis([0 inf 0 5])
    title("MSE")
    drawnow;
end


toc


%% test
load mnist\testingData.mat;
X = reshape(images,28^2,[]);% input : 28^2 x 10000
one_hot = diag(ones(1,max(labels)+1));
Y = one_hot(labels+1,:)';% output : 10 x 10000
X = [ones(1,length(X)) ; X]; % bias add
X = (X-mean(X))./std(X);

o = zeros(size(Y));

for i=1:length(X)
    %forward
    hidden_node = [1; Forward_mlp(@Relu,X(:,i),U1)];
    hidden2_node = [1; Forward_mlp(@Relu,hidden_node,U2)];
    o(:,i) =Forward_mlp(@exp,hidden2_node,U3)/sum(Forward_mlp(@exp,hidden2_node,U3));
     results(i) =  min( Y(:,i) == (o(:,i) ==max(o(:,i))));
end

[~,max_o] = max(o);
error_epo = round(mean(results)*100,2);
fail = 0;
for i=1:length(X)
    if max_o(i) ~= labels(i)
        fail = fail + 1;
    end
end

fprintf("\n정확도 : %5.4f\n세대 : %6.0f\n",error_epo,epo)
fprintf("test 집합에서 틀린 개수 : %d\n",fail);

%% function
%forward
function z = Forward_mlp(act,x,U)
z = act(U*x);
end


