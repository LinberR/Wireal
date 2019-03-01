 % intercept and feature
 tic;
 path = 'data';
 % 17.10.18 1000HZ
 % 17.12.20 1000Hz 
 date = '/17.12.20/';
 % motion = {'sitdown','standup','liedown','squat','fallface','fallarm'};
 motion = {'sitdown','standup','liedown','squat','fallface','fallarm'};
 name = {'zjh','lbw','lt','zyf','zx','hmm','wyt','zcy','wrz','sly'};
 %name = {'lt','zyf','zx','sly'};
 format = '.dat';
 num = 10;
 
 X = zeros(length(motion)*length(name)*num,18);
 Y = zeros(length(motion)*length(name)*num,1)-ones(length(motion)*length(name)*num,1);
  
 for M = 1:length(motion)
     for N = 1:length(name)
         for I = 1:num
            if ~exist([path,date,char(motion(M)),char(name(N)),num2str(I),format])
                disp([char(motion(M)),char(name(N)),num2str(I),format,' doesn''t exist']);
                continue
            end
            %tic;

            c1 = read_bf_file([path,date,char(motion(M)),char(name(N)),num2str(I),format]);
            
            datalength = length(c1); 
            csi_trace = c1(1:datalength,1);
            % 3001 = 10500 - 7500
            k = 3001;
            package1 = zeros(30,k);
            package2 = zeros(30,k);
            package3 = zeros(30,k);
            fs=1000; %����Ƶ��

            countlack = 0;ff=0;
            amp = zeros(1,datalength);
            for i = 7500:10500
                csi_entry = csi_trace{i};
                csi = get_scaled_csi_sm(csi_entry);
                [u,v,~] = size(csi);
                thr_antenna = reshape(csi,u*v,30).';
                a_antenna = thr_antenna; %�ڶ������߷����Ĳ�ͬ���ز�����2��4�����ز���
                temp = abs(a_antenna);
                package1(:, i-7499) = temp(:, 1);
                package2(:, i-7499) = temp(:, 2);
                package3(:, i-7499) = temp(:, 3); 
            end

            s1 = 0;
            s2 = 0;
            s3 = 0;

            Wp = 1 / (fs / 2); %ͨ����ֹƵ��,����Զ����¶���
            Ws = 15 /(fs / 2);%�����ֹƵ��,����Զ����¶���
            Rp = 2; %ͨ���ڵ�˥��������Rp,����Զ����¶���
            Rs = 40;%����ڵ�˥����С��Rs������Զ����¶���
            [n, Wn] = buttord(Wp, Ws, Rp, Rs);%������˹�����˲�����С����ѡ����
            [b, a] = butter(n, Wn);%������˹�����˲���

            filterdata = ones(30, k);
            for i = 1 : 30
               filterdata(i, :) = filtfilt(b, a, package1(i, :));
            end
            s1 = diff(mean(filterdata));

            filterdata = ones(30, k);
            for i = 1 : 30
               filterdata(i, :) = filtfilt(b, a, package2(i, :));
            end 
            s2 = diff(mean(filterdata));
            
            filterdata = ones(30, k);
            for i = 1 : 30
               filterdata(i, :) = filtfilt(b, a, package3(i, :));
            end
            s3 = diff(mean(filterdata));
            
            %toc;
            %tic;
            % si is the average value of all subcarriers in ith stream
            % from 1 to 18, every 6 blocks represent six features
            % s1 : 1-6
            % s2 : 7-12
            % s3 : 13-18
            for j = 1 : 18;
                switch ceil(j / 6)
                    case 1,t = s1;
                    case 2,t = s2;
                    case 3,t = s3;
                end
                switch rem(j, 6)
                    case 1,X((M-1)*length(name)*num+(N-1)*num+I,j) = std(t);
                    case 2,X((M-1)*length(name)*num+(N-1)*num+I,j) = prctile(t,25);
                    % case 3,X(i,j) = kurtosis(t);
                    % case 4,X(i,j) = skewness(t);
                    case 3,X((M-1)*length(name)*num+(N-1)*num+I,j) = mean(abs(t-mean(t)));
                    case 4,X((M-1)*length(name)*num+(N-1)*num+I,j) = std(diff(t,1));
                    case 5,X((M-1)*length(name)*num+(N-1)*num+I,j) = skewness(t);
                    case 0,X((M-1)*length(name)*num+(N-1)*num+I,j) = entropy(t);
                end
            end
            % if M==5 || M==6
            %   Y((M-1)*length(name)*num+(N-1)*num+I,1) = 1;
            % end
            Y((M-1)*length(name)*num+(N-1)*num+I,1) = M;  
            %toc;
         end
     end
 end
%{
2017.10.18
save X;
save Y;
%}
save('171220te.mat', 'X', 'Y', 'num');
toc;
