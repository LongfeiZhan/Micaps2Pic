clear
clc

sta = importdata('���ݿ�����.txt');
sta = sta.data;
file_p = dir('\��ˮ\*0');
mm =1;
for i = 1 : length(file_p)
    fid = fopen(['\��ˮ\',file_p(i).name]);
    t = file_p(i).name;
    date = [str2num(t(2:5)),str2num(t(6:7)),str2num(t(8:9))]; % ��ȡʱ��
    
    %% ��ȡ�ļ�������
    row = 0;
    while ~feof(fid)   % �Ƿ��ȡ���ļ���β
        row = row + 1;   % �����ۼ�
        line = fgetl(fid);
        if strcmp(line,'STATION_SITUATION')
            r = row;
        end
    end
    %% �Թ�������ݣ�����ȡվ������
    fid = fopen(['\��ˮ\',file_p(i).name]);
    for j = 1 : r
        tex = fgetl(fid);
    end
    for k = r+1 : row-4
        str_line = fgetl(fid);
        data(k-r,1:2) = [str2num(str_line(1:5)),str2num(str_line(7:end))];
    end
    %% ��ȡ91��վ��
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