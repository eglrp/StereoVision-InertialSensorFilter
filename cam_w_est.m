clear,clc,close all
if isempty(imaqfind)~=1
	delete(imaqfind)% 关闭正在占用的摄像头
end

imaqhwinfo;
obj1 = videoinput('winvideo',1,'YUY2_640x480');
set(obj1,'ReturnedColorSpace','rgb');
triggerconfig(obj1,'manual');
fig1=figure(1);
load('cam_w_param.mat');

hImage = imshow(zeros(480,640));
setappdata(hImage,'UpdatePreviewWindowFcn',@update_livehistogram_display);

start(obj1);
% for i = 1:500
i = 1;
while(1)
	snapshot1 = getsnapshot(obj1);
	snapshot2 = getsnapshot(obj1);
% 	subplot(1,2,1)
% 	imagesc(snapshot1);
% 	subplot(1,2,2)
% 	imagesc(snapshot2);
% 	drawnow
	img1 = rgb2gray(snapshot1);
	img2 = rgb2gray(snapshot2);
	points1 = detectSURFFeatures(img1);
	points2 = detectSURFFeatures(img2);
	%Extract the features.计算描述向量
	[f1, vpts1] = extractFeatures(img1, points1);
	[f2, vpts2] = extractFeatures(img2, points2);
	%Retrieve the locations of matched points. The SURF feature vectors are already normalized.
	%进行匹配
	indexPairs = matchFeatures(f1, f2, 'Prenormalized', true) ;
	matched_pts1 = vpts1(indexPairs(:, 1));
	matched_pts2 = vpts2(indexPairs(:, 2));
	if length(matched_pts1)>8
		% 利用本质矩阵的RANSAC方法筛选匹配特征点
		[F,inliersIndex] = estimateFundamentalMatrix(matched_pts1,matched_pts2);
		inliermatch1 = matched_pts1(inliersIndex,:);
		inliermatch2 = matched_pts2(inliersIndex,:);
		% 对于多于8对点以上的特征点
		A = [];
		for i = 1:8
% 		for i = 1:length(inliermatch1)
			p1 = double(inliermatch1(i).Location);
			p2 = double(inliermatch2(i).Location);
			u1 = p1(1);v1 = p1(2);
			u2 = p2(1);v2 = p2(2);
			A(i,:)=[u1*u2 u1*v2 u1 v1*u2 v1*v2 v1 u2 v2 1];
		end
% 		b = zeros(8,1);
% 		y = pinv(A)*b;
		r = rank(A);
		e = null(A,r);
		E = [e(1) e(2) e(3);e(4) e(5) e(6);e(7) e(8) e(9)];
		[U,S,V]=svd(E);
		s = diag(S);
		EE = U*diag([(s(1)+s(2))/2 (s(1)+s(2))/2 0])*V
	end
end
