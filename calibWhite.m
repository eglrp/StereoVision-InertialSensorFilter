% Auto-generated by cameraCalibrator app on 23-Jun-2018
%-------------------------------------------------------


% Define images to process
imageFileNames = {'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image2.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image6.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image7.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image8.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image9.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image11.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image12.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image14.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image16.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image18.png',...
	'D:\Codes\githubcodes\StereoVision-InertialSensorFilter\wimg\Image19.png',...
	};

% Detect checkerboards in images
[imagePoints, boardSize, imagesUsed] = detectCheckerboardPoints(imageFileNames);
imageFileNames = imageFileNames(imagesUsed);

% Read the first image to obtain image size
originalImage = imread(imageFileNames{1});
[mrows, ncols, ~] = size(originalImage);

% Generate world coordinates of the corners of the squares
squareSize = 25;  % in units of 'millimeters'
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera
[cameraParams, imagesUsed, estimationErrors] = estimateCameraParameters(imagePoints, worldPoints, ...
	'EstimateSkew', false, 'EstimateTangentialDistortion', false, ...
	'NumRadialDistortionCoefficients', 2, 'WorldUnits', 'millimeters', ...
	'InitialIntrinsicMatrix', [], 'InitialRadialDistortion', [], ...
	'ImageSize', [mrows, ncols]);

% View reprojection errors
h1=figure; showReprojectionErrors(cameraParams);

% Visualize pattern locations
h2=figure; showExtrinsics(cameraParams, 'CameraCentric');

% Display parameter estimation errors
displayErrors(estimationErrors, cameraParams);

% For example, you can use the calibration data to remove effects of lens distortion.
undistortedImage = undistortImage(originalImage, cameraParams);

% See additional examples of how to use the calibration data.  At the prompt type:
% showdemo('MeasuringPlanarObjectsExample')
% showdemo('StructureFromMotionExample')
