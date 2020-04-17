clc;clear;
% this is the main function for the interferometry, this aim of the code is to %form the virtual shot gathers                                          
% the input data should saved as sac format within one day(24 hours) length
% the time window we chose in this code is one hour , sample intervals is 1ms,
% there are totally 6000 samples , and 24hours is 36000000 samples.
% the flow is : 1. read source  2. read receivers  3. one-bit 4. move mean 
% value 5. move trend 6 ouput virtual shot gather.
% The author : Guofeng Liu and Weijun Su
% contact us at : liugf@cugb.edu.cn
nw=60000;%cross-correlation window size,10minites
tw=3600000;%one hour
n=tw/nw;
AA=zeros(nw,100);% size of the virutal shot gather AA[nx][nt]
S=readsac('003.1.sac'); % read source
[XX2, YY2]=getsacdata(S); % read sac
if length(YY2)==86400001 %pad with zeros¡£
        YY3=YY2;
end
     if length(YY2)<86400001  
      yy=zeros((86400001-length(YY2)),1);
       YY3=[YY2;yy];
    end
     if length(YY2)>86400001
       YY3=YY2(1:86400001,1);
     end
Path='D:\sac1\';% file directory
File=dir(fullfile(Path,'*.sac'));
Len=length(File);     
t=0;
for i=1:7:700 % loop within servral datas
    t=t+1;
   full_path=strcat(Path,File(i).name);% file name
    Read=readsac(full_path);% read sac for receiver
    [XX, YY]=getsacdata(Read);% 
    if length(YY)==86400001%pad with zeros
        YY1=YY;
    end
      if length(YY)<86400001
        yy=zeros((86400001-length(YY)),1);
       YY1=[YY;yy];
      end
     if length(YY)>86400001
       YY1=YY(1:86400001,1);
     end
     T=1;%for one hour data
      Y1=YY1((tw*(T-1)+1):tw*T,1);
   for M=1:tw%one-bit·½·¨
      if Y1(M,1)>0
          Y1(M,1)=1;
      end
      if Y1(M,1)<0
         Y1(M,1)=-1;
      end  
   end
   qq=(mean(Y1));% move mean value
   for M=1:tw
     Y1(M,1)=(Y1(M,1)-qq);
   end
      Y3=YY3((tw*(T-1)+1):tw*T,1);
   for M=1:tw
      if Y3(M,1)>0
          Y3(M,1)=1;
      end
      if Y3(M,1)<0
         Y3(M,1)=-1;
      end  
   end
  q=(mean(Y3));%move mean value
   for M=1:tw
       Y3(M,1)=(Y3(M,1)-q);
   end
       x1=zeros(2*nw-1,1);
        for k=1:n
            a=Y1(nw*(k-1)+1:nw*k,1);% read window size data
            b=Y3((nw*(k-1)+1):nw*k,1);
            x=xcorr(a,b);%cross-correlation
            x1=x1+x; % stack the cross-correlation result
        end
         x2=zeros(nw,1);
          x2=x1(nw:2*nw-1,1)/n;% take the causal part
          x2=detrend(x2);% if necessary, move the trend
          AA(:,t)=AA(:,t)+x2; %save the data to AA[nx][nt]
       %AA(:,t)=AA(:,t)+x1(nw:2*nw-1,1)/n;
       % r=rms(AA(:,t));
       % AA(:,t)=AA(:,t)/r;
  end

 fid=fopen('d1h.out','w');
    for i=1:nw
    for j=1:100
        fprintf(fid,'%f ',AA(i,j));
    end
    fprintf(fid,'\n');
    end
    fclose(fid); %output to binary format 
     
%BB=zeros(nw,100);
 %for nx=1:100
    % BB(:,nx)=AA(nw:2*nw-1,nx);
    % BB(:,nx)=detrend(BB(:,nx));
  %   r=rms(AA(:,nx));
    % AA(:,nx)=AA(:,nx)/r;
 %end
  