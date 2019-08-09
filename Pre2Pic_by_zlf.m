clear;
clc;


%----------------------降水累计计算---------------
directory = dir('C:\Users\ZhanLF\Desktop\New folder\');%把所有预报数据放到一个文件夹下
accumulation_data = zeros(118,104);
for i = 3 : length(directory)
    fid = fopen([directory(i,1).folder,'\',directory(i,1).name]);
    tex1 = fgetl(fid);%读第一行头文件
    tex2 = fgetl(fid);%读第二行头文件
    data = fscanf(fid,'%f',[104,118]);
    data = data';%转置，一行为一个纬度上不同经度，自西向东，和原文件同
    data = flipud(data);%读入arcgis需要上下颠倒
    accumulation_data = accumulation_data + data;
end
%--------------------------------------------------------
    
    
    
%--------------------单个文件计算-----------------------
% fid = fopen('C:\Users\ZhanLF\Desktop\New folder\19060520.024','rt'); %输入路径
% tex1 = fgetl(fid);%读第一行头文件
% tex2 = fgetl(fid);%读第二行头文件
% data = fscanf(fid,'%f',[104,118]);
% data = data';%转置，一行为一个纬度上不同经度，自西向东，和原文件同
% data = flipud(data);%读入arcgis需要上下颠倒
%-------------------------------------------------------------------------


lon = 113.45:0.05:118.6;
lat = 30.2:-0.05:24.35;
lat = lat';
[lon_mesh, lat_mesh] = meshgrid(lon,lat);
r = 1;
for i = 1 : 118
    for j = 1 : 104
        point(r,1) = lon_mesh(i,j);
        point(r,2) = lat_mesh(i,j);
        point(r,3) = accumulation_data(i,j);
        r = r + 1;
    end
end

fid1 = fopen('C:\Users\ZhanLF\Desktop\New folder\accumulation_pre.txt','w'); %输出路径
[m,n] = size(point);
for i=1:1:m
    for j=1:1:n
        if j==n
            fprintf(fid1,'%f\n',point(i,j));
        else
            fprintf(fid1,'%f\t',point(i,j));
        end
    end
end
fclose(fid1);


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -----------------------------绘制降水空间分布图--------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

%绘制实况雨量图
% clear
% clc
temp = textread('C:\Users\ZhanLF\Desktop\New folder\accumulation_pre.txt','%f',-1,'headerlines',0);
%temp=reshape(temp,3,31971/3)';%phase1

temp = reshape(temp,3,length(temp)/3)';
x = temp(:,1);
y = temp(:,2);
z = temp(:,3);
z(z<0.1) = 0;
z(z>=0.1&z<10) = 1;
z(z>=10&z<25) = 2;
z(z>=25&z<50) = 3;
z(z>=50&z<100) = 4;
z(z>=100&z<250) = 5;
z(z>=250)=6;

jx = shaperead('F:\Arcgis\GIS_JX_basic_data\JX_GIS\省.shp');

isin = inpolygon(lon_mesh,lat_mesh,jx.X,jx.Y);
zz = griddata(x,y,z,lon_mesh,lat_mesh);

r = 1;
for i = 1 : 118
    for j = 1 : 104
        if isin(i,j) == 1
            lon_in(r,1) = lon_mesh(i,j);
            lat_in(r,1) = lat_mesh(i,j);
            zz_in(r,1) = zz(i,j);
            r = r + 1;
        end
    end
end

zz_in = round(zz_in);

figure
set(gcf,'Position',[100 250 400 350],'color','w');
set(gca,'Position',[.1 .1 0.74 .84]);
cc = [255,255,255;171,255,167;89,191,103;117,189,255;41,45,231;237,45,251;139,46,105]/255;
% [c,h]=contourf(xx,yy,zz,'LineColor','none');%floor(min(min(zz)))
scatter(lon_in,lat_in,10,cc(zz_in+1,:),'fill');
% clabel(c,h)
colormap(cc)
h = colorbar('ytick',[0:7],'yticklabel',{'0','0.1','10','25','50','100','250','  '},'location','EastOutside','box','on'...
    ,'location','EastOutside','box','on','position',[0.87 0.1 0.03 0.84])
caxis([0 7])
hold on

%--------------------------------绘制地图---------------------------------

map_path = shaperead('F:\Arcgis\GIS_JX_basic_data\JX_GIS\地市.shp');

map_X = [map_path(:).X];   % read x of the contour of province
map_Y = [map_path(:).Y];   % read y of the contour of province
plot(map_X,map_Y,'Linestyle','-','linewidth',1,'color',[.5 .5 .5]) %draw political line
% hold on
% map_path = shaperead('D:\data\map\bou2_4l.shp');
% %map_path = shaperead('D:\data\江西\Provices_p.shp');
% map_X = [map_path(:).X];   % read x of the contour of province
% map_Y = [map_path(:).Y];   % read y of the contour of province
% plot(map_X,map_Y,'Linestyle','-','linewidth',1,'color',[.5 .5 .5]) % draw political line
 
hold on
set(gca,'xlim',[113.45 118.6],'XTick',114:1:118,'XTickLabel',['114° ';'115° ';'116° ';'117° ';'118°E'],'xminortick','off');
set(gca,'ylim',[24.35 30.2],'yTick',25:30,'yTickLabel',['25° ';'26° ';'27° ';'28° ';'29° ';'30°N'],'yminortick','off');
set(gca,'FontSize',10,'ticklength',[0.02,0.02],'tickdir','in','box','on');%刻度线长度设置,刻度朝外,半框
print(1, '-dpng', '-r600',['C:\Users\ZhanLF\Desktop\New folder\accumulation_pre.png']);
unit = '(mm)'
annotation('textbox',[0.9 0.9 0.18 0.06],'String',unit,'FontName','Times New Roman','fontsize',10,'FitBoxToText','off','LineStyle','none');




