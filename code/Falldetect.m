function [ state,l,r ] = Falldetect( X,template,t )
    load('X0.mat');
    X = [X0;X];

    Wp = 1/(fs/2); %ͨ����ֹƵ��,����Զ����¶���
    Ws = 15/(fs/2);%�����ֹƵ��,����Զ����¶���
    Rp = 2; %ͨ���ڵ�˥��������Rp,����Զ����¶���
    Rs = 40;%����ڵ�˥����С��Rs������Զ����¶���
    [n,Wn] = buttord(Wp,Ws,Rp,Rs);%������˹�����˲�����С����ѡ����
    [b,a] = butter(n,Wn);%������˹�����˲���
    
    s = zeros(3,length(X(1,1,:)));
    for i=1:3
        for j=1:30
            s(i,:) = s(i,:) + filtfilt(b,a,X(i,j,:))/30;
        end
    end
    e0 = 100000000000000000;
    for i=1:length(X(1,1,:))-299
        e = norm(s(1,i:i+299)-template(1,:),2)+norm(s(2,i:i+299)-template(2,:),2)+norm(s(3,i:i+299)-template(3,:),2);
        if e<t*300
            state = ture;
            if e<=e0
                l0 = i; r0 = i+299;e0 = e;
            else
                l = l0; r = r0;
            end
        end
    end
    if state == false
        X0 = X(:,:,length(X(1,1,:))-299:length(X(1,1,:)));
    end
    save X0;
end

