command = 'mcc -mv -o depouillement -d bin';

%Improve : concatenate arrays to make only one loop
mFiles = dirrec('../src', '.m');

mImages = dirrec('../img', '.*');

for i = 1:1:length(mFiles)
    command = [command ' -a ' mFiles{i}];
end

for j = 1:1:length(mImages)
    command = [command ' -a ' mImages{j}];
end
command = [command ' launcher'];
disp(command);
eval(command);