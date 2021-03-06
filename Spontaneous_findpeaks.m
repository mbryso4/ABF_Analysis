[fname1,pname1]=uigetfile({'*.*'},'Select Files','MultiSelect', 'on');

if ~iscell(fname1)
    filetot = 1;
else
    filetot = size(fname1,2);
end
holdtable = [];
dmat = [];
fnames = {};
for aa = 1:filetot
    tic
    if ~iscell(fname1)
        filename = fname1;
        name = filename(1:end-4);
    else
        filename = fname1{1,aa};
        name = filename(1:end-4);
    end
   
    filename = fullfile(pname1,filename);
    display('_________________________________________');
    display(['Loading File "' name '"'])
    [d,si,h] = abfload(filename);
   
    dmat = []; 
   
    for j = 1:size(d,3)
       
        data = d(:,1,j);
        data = data((end-100000):end);
        rmsd = rms(data);
        thresh = 2.5*rmsd;
        offset = 100001;
       
        Wn = 150/25000; %si = 20 == 50,000 Hz sampling rate
        [B,A] = butter(4,Wn, 'high');
        data = filter(B,A,data);
        fpx = (1:1:100001);
        fpy = data;
        invfpy = fpy*-1;
        
        [x] = findpeaksplot(fpx, invfpy, 0.001, thresh, 3, 3);
        
        for i = 1:1
            spikes = length(x);
            holdmat = data;
            holdmat = abs(holdmat);
            holdsum = sum(holdmat);
            dimpulse = holdsum/offset;
            holdmax = max(holdmat);
            
            % dummy variables:
            % dmat(:,1)= filename
            % dmat(:,2)= trace #
            % dmat(:,3)= stimulus #
            % dmat(:,4)= variable
            
        for bb = 1:4
%                 dmat(end+1,1) = aa;
                dmat(end+1,1) = str2num(name), format long g;
                dmat(end,2) = j;
                dmat(end,3) = i;
%                 fnames{end+1,1} = name;
               
               
                switch bb
                    case 1
                        dmat(end,4) = bb;
                        dmat(end,5) = holdsum;
                    case 2
                        dmat(end,4) = bb;
                        dmat(end,5) = dimpulse;
                    case 3
                        dmat(end,4) = bb;
                        dmat(end,5) = holdmax;
                    case 4 
                        dmat(end,4) = bb; 
                        dmat(end,5) = spikes; 
                end
            end
        end        
    end
    
  holdtable(:,:,aa) = dmat;
clear dmat 
    toc
    clear memory 
end 
     
for i = 1:filetot
    if ~iscell(fname1) 
        table = array2table(holdtable(:,:,i), 'VariableNames', {'File', 'Trace', 'Stimulus', 'Variable', 'Value'});
        writetable(table, ['spont' fname1 '.txt'])   
    else 
        table = array2table(holdtable(:,:,i), 'VariableNames', {'File', 'Trace', 'Stimulus', 'Variable', 'Value'});
        writetable(table, ['spont' fname1{1,i} '.txt'])
    end 
end
display( 'Complete')