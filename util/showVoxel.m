function showVoxel( Volume )
%SHOWVOXEL �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
[X,Y,Z]=ind2sub(size(Volume),find(Volume(:)));
plot3(X,Y,Z,'.');
axis equal;
xlabel('x');
ylabel('y');
zlabel('z');
end

