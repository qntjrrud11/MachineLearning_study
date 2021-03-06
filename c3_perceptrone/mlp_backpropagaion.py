import numpy as np
import matplotlib.pyplot as plt
import time
import random as rd
from sklearn.datasets import load_iris
iris = load_iris()
plt.close()

# 훈련집합
# x = np.array([[0,0], [1,0], [0,1], [1,1]])
# Y = np.array([0,1,1,0])
# X = np.c_[np.ones((len(x),1)),x]

x = iris.data[100:,[0,2]]
Y = iris.target[:100]
X = np.c_[np.ones((len(x),1)),x]

# 파라미터
in_node_n = X[1].size
learning_rate = 0.2
hidden_node_n = 2
out_node_n = 2

def onehot(y,n):
    return np.insert(np.zeros((1,n-1)),y,1)

# 목적함수
def mse(y,o):
    return 0.5*np.sum((y-o)**2)
def cee(y,o):
    return -np.sum(o*np.log(y+1e-7))


# 활성화 함수
def stairs_function(s):
    return np.where(s>=0,1,-1)

def logistic_sig(s,a=1):
    return 1/(1+np.exp(-a*s))

def d_logistic_sig(s,a=1):
    return a*logistic_sig(s,a)*(1-logistic_sig(s,a))

t = 0
plot_x = np.arange(np.min(x[:,:1])-1,np.max(x[:,:1])+1,0.1)
epo=0

    # 가중치 행렬
U1 = np.random.random((in_node_n,hidden_node_n))
U2 = np.random.random((hidden_node_n+1,out_node_n))

start_t = time.time()
i = 0
while True:
    epo+=1
    error = np.zeros(len(Y))
    i = 0
    for x_val, y_val, in zip(X,Y):
        # 전방 계산
        hidden_node = np.insert(logistic_sig(x_val.dot(U1)),0,1)
        out_node = logistic_sig(hidden_node.dot(U2))

        # 오류역전파
        gradient = (y_val-out_node) * d_logistic_sig(hidden_node.dot(U2))
        dU2 = -gradient*hidden_node.reshape(-1,1)
        gradient2 = gradient.dot(U2[1:].T) * d_logistic_sig(x_val.dot(U1))
        dU1 = -gradient2*x_val.reshape(-1,1)

        # 가중치 갱신
        U2 += -learning_rate*dU2
        U1 += -learning_rate*dU1

        error[i] = mse(y_val,out_node)
        i += 1
    # 목적함수를 이용한 오차 확인
    error = np.sum(error)/len(Y)

    if error<=1e-4 or epo > 10000:
        t = time.time()-start_t
        print(error)
        break

# 테스트
test_error=0
for x_val, y_val, in zip(X,Y):
    hidden_node = np.insert(logistic_sig(x_val.dot(U1)),0,1) # 1*4
    out_node = logistic_sig(hidden_node.dot(U2))  # 1*2
    print(np.around(out_node))
    test_error += mse(y_val,out_node)

# U1의 특징공간
for i in range(hidden_node_n):
    plt.plot(plot_x,-U1[0,i]/U1[2,i]-U1[1,i]*plot_x/U1[2,i])
plt.plot(x[:,0],x[:,1],marker='o', linestyle = 'None')
plt.grid()

# 평균 수렴 시간
print("mean time : ",t)
print("test error : ",test_error/len(Y))
plt.show()
