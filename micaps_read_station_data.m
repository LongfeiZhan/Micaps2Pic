clear
clc

sta = importdata('数据库列名.txt');
sta = sta.data;
file_p = dir('\降水\*0');
mm =1;
for i = 1 : length(file_p)
    fid = fopen(['\降水\',file_p(i).name]);
    t = file_p(i).name;
    date = [str2num(t(2:5)),str2num(t(6:7)),str2num(t(8:9))]; % 获取时间
    
    %% 获取文件总行数
    row = 0;
    while ~feof(fid)   % 是否读取到文件结尾
        row = row + 1;   % 行数累加
        line = fgetl(fid);
        if strcmp(line,'STATION_SITUATION')
            r = row;
        end
    end
    %% 略过格点数据，仅读取站点数据
    fid = fopen(['\降水\',file_p(i).name]);
    for j = 1 : r
        tex = fgetl(fid);
    end
    for k = r+1 : row-4
        str_line = fgetl(fid);
        data(k-r,1:2) = [str2num(str_line(1:5)),str2num(str_line(7:end))];
    end
    %% 提取91个站号
    for m = 1 : length(sta)
        for n = 1 : size(data,1)
            if sta(m,1) == data(n,1)
                sta91_p(mm,1) = data(n,1);
                sta91_p(mm,2:4) = date;
                sta91_p(mm,5) = data(n,2);
                mm = mm + 1;
                break
            end
        end
    end
    fclose(fid);
    clear data
end