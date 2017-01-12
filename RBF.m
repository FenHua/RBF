%基于RBF算法实现曲线的拟合
SamNum=100;%总样本数
TestSamNum=101;%测试样本数
InDim=1;%输入样本维数
ClusterNum=10;%隐藏节点数（聚类数）
Overlap=1.0;%隐藏节点重叠系数
%根据目标函数获得样本输入输出
NoiseVar=0.1;
Noise=NoiseVar*randn(1,SamNum);
SamIn=8*rand(1,SamNum)-4;
SamOutNoNoise=1.1*(1-SamIn+2*SamIn.^2).*exp(-SamIn.^2/2);
SamOut=SamOutNoNoise+Noise;
TestSamIn=-4:0.08:4;
TestSamOut=1.1*(1-TestSamIn+2*TestSamIn.^2).*exp(-TestSamIn.^2/2);
figure;
hold on;
grid;
plot(SamIn,SamOut,'k+');
plot(TestSamIn,TestSamOut,'k--')
xlabel('Input x');
ylabel('Output y');
Centers=SamIn(:,1:ClusterNum);
NumberInClusters=zeros(ClusterNum,1);%各类样本数
IndexInClusters=zeros(ClusterNum,SamNum);%各类所含样本的索引号
while 1
    NumberInClusters=zeros(ClusterNum,1);%各类中的样本数，初始化
    IndexInClusters=zeros(ClusterNum,SamNum);%各类所含样本的索引号
    %按最小距离原则对所有样本进行分类
    for i=1:SamNum
        AllDistance=dist(Centers',SamIn(:,i));
        [MinDist,Pos]=min(AllDistance);
        NumberInClusters(Pos)=NumberInClusters(Pos)+1;
        IndexInClusters(Pos,NumberInClusters(Pos))=i;
    end
    %保存旧的聚类中心
    OldCenters=Centers;
    for i=1:ClusterNum
        Index=IndexInClusters(i,1:NumberInClusters(i));
        Centers(:,i)=mean(SamIn(:,Index)')';
    end
    %判断新旧聚类中心是否一致，是则结束聚类
    EqualNum=sum(sum(Centers==OldCenters));
    if EqualNum==InDim*ClusterNum
        break;
    end
end
%计算各隐藏节点的扩展常数（宽度）
AllDistances=dist(Centers',Centers);%计算隐藏节点数据中心点的距离（矩阵）
Maximum=max(max(AllDistances));%找出其中最大的一个距离
for i=1:ClusterNum
    %将对角线上的0替换为较大值
    AllDistances(i,i)=Maximum+1;
end
Spreads=Overlap*min(AllDistances)';%以隐节点的最小距离作为扩展常数
%计算各隐藏节点的输出权值
Distance=dist(Centers',SamIn);%计算各个样本离类中心的距离
SpreadsMat=repmat(Spreads,1,SamNum);
HiddenUnitOut=radbas(Distance./SpreadsMat);%计算隐节点输出阵
HiddenUnitOutEx=[HiddenUnitOut' ones(SamNum,1)]';%考虑偏移
W2Ex=SamOut*pinv(HiddenUnitOutEx);%求广义输出权值
W2=W2Ex(:,1:ClusterNum);%输出权值
B2=W2Ex(:,ClusterNum+1);%偏移
%测试
TestDistance=dist(Centers',TestSamIn);
TestSpreadsMat=repmat(Spreads,1,TestSamNum);
TestHiddenUnitOut=radbas(TestDistance./TestSpreadsMat);
TestNNOut=W2*TestHiddenUnitOut+B2;
plot(TestSamIn,TestNNOut,'r--');
W2
B2



























